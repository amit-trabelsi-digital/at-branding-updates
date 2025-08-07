import { Request, Response, NextFunction } from "express";
import firebase from "firebase-admin";
import Otp from "../models/otp-model";
import User from "../models/user-model";
import twilioService from "../services/twilio-service";
import AppError from "../utils/appError";
import catchAsync from "../utils/catchAsync";
import "colors";

// Helper function to get client IP
const getClientIp = (req: Request): string => {
  return (req.headers['x-forwarded-for'] as string) || 
         (req.headers['x-real-ip'] as string) || 
         req.socket.remoteAddress || 
         'unknown';
};

/**
 * Send OTP to phone number
 */
export const sendOTP = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { phoneNumber, email } = req.body;

  if (!phoneNumber) {
    return next(new AppError("מספר טלפון חובה", 400));
  }

  // Format phone number
  const formattedPhone = twilioService.formatPhoneNumber(phoneNumber);
  
  if (!twilioService.isValidPhoneNumber(formattedPhone)) {
    return next(new AppError("מספר טלפון לא תקין", 400));
  }

  // Check if email is provided and user exists
  let user = null;
  if (email) {
    user = await User.findOne({ email });
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }

    // Check if SMS auth is allowed for this user
    const allowedMethods = user.allowedAuthMethods || {
      email: false,
      sms: true,
      google: true
    };

    if (!allowedMethods.sms) {
      return next(new AppError("התחברות עם SMS לא מאושרת למשתמש זה", 403));
    }
  } else {
    // Check if phone number exists in any user
    // Try multiple formats for phone number matching
    const phoneVariants = [
      formattedPhone, // +972501234567
      formattedPhone.replace('+972', '0'), // 0501234567
      formattedPhone.replace('+972', ''), // 501234567
      formattedPhone.substring(1), // 972501234567
    ];
    
    user = await User.findOne({
      $or: [
        { firebasePhoneNumber: { $in: phoneVariants } },
        { phoneNumber: { $in: phoneVariants } },
        { phone: { $in: phoneVariants } }
      ]
    });
    
    if (!user) {
      console.log("Phone not found. Tried variants:", phoneVariants);
      console.log("Formatted phone:", formattedPhone);
      return next(new AppError("מספר טלפון לא רשום במערכת", 404));
    }

    // Check if SMS auth is allowed
    const allowedMethods = user.allowedAuthMethods || {
      email: false,
      sms: true,
      google: true
    };

    if (!allowedMethods.sms) {
      return next(new AppError("התחברות עם SMS לא מאושרת למשתמש זה", 403));
    }
  }

  // Check for existing OTP (rate limiting)
  const existingOtp = await Otp.findOne({
    phoneNumber: formattedPhone,
    isVerified: false,
    expiresAt: { $gt: new Date() }
  });

  if (existingOtp) {
    const timeSinceCreated = Date.now() - existingOtp.createdAt.getTime();
    const minimumWaitTime = 60000; // 1 minute

    if (timeSinceCreated < minimumWaitTime) {
      const waitSeconds = Math.ceil((minimumWaitTime - timeSinceCreated) / 1000);
      return next(new AppError(`אנא המתן ${waitSeconds} שניות לפני שליחת קוד חדש`, 429));
    }

    // Delete old OTP
    await existingOtp.deleteOne();
  }

  // Generate new OTP
  const otpCode = twilioService.generateOTP();
  
  // Save OTP to database
  const otp = await Otp.create({
    phoneNumber: formattedPhone,
    email: user.email,
    code: otpCode,
    purpose: "login",
    ipAddress: getClientIp(req),
    userAgent: req.headers['user-agent']
  });

  console.log(`[OTP] Generated OTP for ${formattedPhone}: ${otpCode}`.yellow);

  // Send OTP via Twilio
  const smsSent = await twilioService.sendOTP(phoneNumber, otpCode);
  
  if (!smsSent) {
    await otp.deleteOne();
    
    // In development, return the OTP code for testing
    if (process.env.NODE_ENV === "development") {
      console.log(`[OTP] Development mode - OTP code: ${otpCode}`.cyan);
      return res.status(200).json({
        success: true,
        message: "קוד אימות נשלח (מצב פיתוח)",
        development: true,
        testCode: otpCode,
        phoneNumber: formattedPhone,
        expiresIn: 300 // 5 minutes in seconds
      });
    }
    
    return next(new AppError("שגיאה בשליחת SMS. אנא נסה שוב מאוחר יותר", 500));
  }

  res.status(200).json({
    success: true,
    message: "קוד אימות נשלח בהצלחה",
    phoneNumber: formattedPhone,
    expiresIn: 300 // 5 minutes in seconds
  });
});

/**
 * Verify OTP and create Firebase custom token
 */
export const verifyOTP = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { phoneNumber, code } = req.body;

  if (!phoneNumber || !code) {
    return next(new AppError("מספר טלפון וקוד אימות חובה", 400));
  }

  // Format phone number
  const formattedPhone = twilioService.formatPhoneNumber(phoneNumber);
  
  console.log("Verifying OTP for phone:", formattedPhone);

  // Find OTP record
  const otp = await Otp.findOne({
    phoneNumber: formattedPhone,
    isVerified: false,
    expiresAt: { $gt: new Date() }
  }).sort({ createdAt: -1 });

  if (!otp) {
    console.log("No OTP found for:", formattedPhone);
    console.log("Looking for OTPs in DB...");
    const allOtps = await Otp.find({}).select('phoneNumber code expiresAt isVerified').limit(5);
    console.log("Recent OTPs:", allOtps);
    return next(new AppError("קוד אימות לא נמצא או פג תוקף", 404));
  }

  // Verify OTP code
  const isValid = otp.verifyCode(code);
  await otp.save();

  if (!isValid) {
    if (otp.attempts >= 3) {
      await otp.deleteOne();
      return next(new AppError("יותר מדי ניסיונות שגויים. אנא בקש קוד חדש", 429));
    }
    return next(new AppError(`קוד שגוי. נותרו ${3 - otp.attempts} ניסיונות`, 401));
  }

  // Find user by phone number or email
  // Try multiple formats for phone number matching
  const phoneVariants = [
    formattedPhone, // +972501234567
    formattedPhone.replace('+972', '0'), // 0501234567
    formattedPhone.replace('+972', ''), // 501234567
    formattedPhone.substring(1), // 972501234567
  ];
  
  let user = await User.findOne({
    $or: [
      { firebasePhoneNumber: { $in: phoneVariants } },
      { phoneNumber: { $in: phoneVariants } },
      { phone: { $in: phoneVariants } },
      { email: otp.email }
    ]
  });

  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }

  // Check if we have Firebase UID
  let firebaseUid = user.uid;
  
  if (!firebaseUid) {
    try {
      // Try to get Firebase user by phone number
      const firebaseUser = await firebase.auth().getUserByPhoneNumber(formattedPhone);
      firebaseUid = firebaseUser.uid;
      
      // Update user with Firebase UID
      user.uid = firebaseUid;
      await user.save();
    } catch (error) {
      console.log(`[OTP] Firebase user not found for phone ${formattedPhone}, creating new`.yellow);
      
      // Create Firebase user
      try {
        const newFirebaseUser = await firebase.auth().createUser({
          phoneNumber: formattedPhone,
          displayName: user.firstName + " " + user.lastName,
          email: user.email,
          emailVerified: true
        });
        
        firebaseUid = newFirebaseUser.uid;
        
        // Set custom claims
        await firebase.auth().setCustomUserClaims(firebaseUid, {
          role: user.role || 3,
          mongoId: (user._id as any).toString()
        });
        
        // Update user with Firebase UID
        user.uid = firebaseUid;
        await user.save();
      } catch (createError: any) {
        console.error("[OTP] Failed to create Firebase user:".red, createError);
        return next(new AppError("שגיאה ביצירת משתמש במערכת האימות", 500));
      }
    }
  }

  // Create custom token
  let customToken;
  try {
    console.log(`[OTP] Creating custom token for Firebase UID: ${firebaseUid}`.cyan);
    customToken = await firebase.auth().createCustomToken(firebaseUid, {
      phoneNumber: formattedPhone,
      mongoId: (user._id as any).toString(),
      role: user.role || 3,
      loginMethod: "sms"
    });
    console.log(`[OTP] Custom token created successfully`.green);
  } catch (tokenError: any) {
    console.error("[OTP] Failed to create custom token:".red, tokenError);
    return next(new AppError("שגיאה ביצירת טוקן אימות", 500));
  }

  // Mark OTP as used
  await otp.deleteOne();

  // Return success with custom token and user data
  res.status(200).json({
    success: true,
    message: "אימות הושלם בהצלחה",
    customToken: customToken,
    token: customToken, // Keep for backward compatibility
    user: {
      _id: user._id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      firebasePhoneNumber: user.firebasePhoneNumber,
      role: user.role,
      setProfileComplete: user.setProfileComplete,
      setGoalAndProfileComplete: user.setGoalAndProfileComplete,
      subscriptionType: user.subscriptionType
    }
  });
});

/**
 * Resend OTP
 */
export const resendOTP = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { phoneNumber } = req.body;

  if (!phoneNumber) {
    return next(new AppError("מספר טלפון חובה", 400));
  }

  // Delete any existing OTPs for this number
  const formattedPhone = twilioService.formatPhoneNumber(phoneNumber);
  await Otp.deleteMany({ phoneNumber: formattedPhone });

  // Call sendOTP with the same request
  return sendOTP(req, res, next);
});

/**
 * Check OTP service status
 */
export const checkOTPServiceStatus = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const status = twilioService.getStatus();
  
  res.status(200).json({
    success: true,
    service: "Twilio SMS OTP",
    status: status.initialized ? "active" : "inactive",
    hasCredentials: status.hasCredentials,
    environment: process.env.NODE_ENV
  });
});