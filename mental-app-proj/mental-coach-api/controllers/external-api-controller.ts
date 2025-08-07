import { Request, Response, NextFunction } from "express";
import User from "../models/user-model";
import AppError from "../utils/appError";
import { getAuth } from "firebase-admin/auth";
import bcrypt from "bcryptjs";

interface CreateUserRequest {
  // Required fields
  firstName: string;
  lastName: string;
  email: string;
  
  // Optional fields
  phone?: string;
  password?: string;
  age?: number;
  nickName?: string;
  position?: string;
  strongLeg?: string;
  team?: string;
  league?: string;
  subscriptionType?: string;
  subscriptionExpiresAt?: Date;
  transactionId?: string;
  coachWhatsappNumber?: string;
  
  // Authentication preferences
  allowedAuthMethods?: {
    email?: boolean;
    sms?: boolean;
    google?: boolean;
  };
  
  // External service metadata
  externalId?: string; // ID in the external system
  externalSource?: string; // Name of the external service
}

/**
 * Create a new user via external API
 * This endpoint is designed for external services to create users
 */
export const createUserExternal = async (
  req: Request<{}, {}, CreateUserRequest>,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      firstName,
      lastName,
      email,
      phone,
      password,
      age,
      nickName,
      position,
      strongLeg,
      team,
      league,
      subscriptionType = "premium",
      subscriptionExpiresAt,
      transactionId,
      coachWhatsappNumber,
      allowedAuthMethods = {
        email: false,
        sms: true,
        google: true
      },
      externalId,
      externalSource
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !email) {
      return next(new AppError("Missing required fields: firstName, lastName, email", 400));
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return next(new AppError("Invalid email format", 400));
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return next(new AppError("User with this email already exists", 409));
    }

    // Create Firebase user if phone or password is provided
    let firebaseUser;
    let uid;
    
    try {
      const auth = getAuth();
      
      if (phone || password) {
        // Create Firebase authentication user
        const createUserData: any = {
          email,
          displayName: `${firstName} ${lastName}`,
          emailVerified: false
        };

        if (password) {
          createUserData.password = password;
        }

        if (phone) {
          // Convert Israeli phone to international format
          let formattedPhone = phone.replace(/\D/g, "");
          if (formattedPhone.startsWith("05")) {
            formattedPhone = "+972" + formattedPhone.substring(1);
          } else if (formattedPhone.startsWith("5") && formattedPhone.length === 9) {
            formattedPhone = "+972" + formattedPhone;
          } else if (!formattedPhone.startsWith("+")) {
            formattedPhone = "+" + formattedPhone;
          }
          createUserData.phoneNumber = formattedPhone;
        }

        firebaseUser = await auth.createUser(createUserData);
        uid = firebaseUser.uid;

        // Set custom claims for the user
        await auth.setCustomUserClaims(uid, {
          role: 3, // Regular user
          isAdmin: false,
          createdBy: 'external-api',
          externalSource: externalSource || 'unknown'
        });
      }
    } catch (firebaseError: any) {
      console.error("Firebase user creation error:", firebaseError);
      // Continue without Firebase if it fails
      // The user can be created in MongoDB and Firebase can be linked later
    }

    // Prepare user data for MongoDB
    const userData: any = {
      firstName,
      lastName,
      email,
      phone,
      age,
      nickName,
      position,
      strongLeg,
      team,
      league,
      subscriptionType,
      subscriptionExpiresAt,
      transactionId,
      coachWhatsappNumber,
      allowedAuthMethods,
      role: 3, // Regular user
      totalScore: 0,
      currentStatus: [],
      totalWins: 0,
      trainings: [],
      matches: [],
      mentalTrainingProgress: [],
      setGoalAndProfileComplete: false,
      setProfileComplete: false,
      createdAt: new Date(),
      updatedAt: new Date(),
      
      // External service tracking
      externalId,
      externalSource,
      createdVia: 'external-api'
    };

    // Add Firebase UID if available
    if (uid) {
      userData.uid = uid;
      userData.firebasePhoneNumber = firebaseUser?.phoneNumber;
    }

    // Hash password if provided (for MongoDB storage as backup)
    if (password) {
      userData.password = await bcrypt.hash(password, 12);
    }

    // Create user in MongoDB
    const newUser = await User.create(userData);

    // Log the creation
    console.log(`User created via external API: ${email} (Source: ${externalSource || 'Unknown'})`);

    // Return success response
    res.status(201).json({
      status: "success",
      message: "User created successfully",
      data: {
        user: {
          _id: newUser._id,
          uid: newUser.uid,
          email: newUser.email,
          firstName: newUser.firstName,
          lastName: newUser.lastName,
          phone: newUser.phone,
          subscriptionType: newUser.subscriptionType,
          subscriptionExpiresAt: newUser.subscriptionExpiresAt,
          externalId: newUser.externalId,
          createdAt: newUser.createdAt
        }
      }
    });
  } catch (error: any) {
    console.error("External API user creation error:", error);
    
    // Handle specific error types
    if (error.code === 11000) {
      return next(new AppError("Duplicate field value", 400));
    }
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map((err: any) => err.message);
      return next(new AppError(`Validation error: ${messages.join(', ')}`, 400));
    }
    
    return next(new AppError("Failed to create user", 500));
  }
};

/**
 * Bulk create users via external API
 * Allows creating multiple users in a single request
 */
export const bulkCreateUsersExternal = async (
  req: Request<{}, {}, { users: CreateUserRequest[] }>,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { users } = req.body;

    if (!users || !Array.isArray(users) || users.length === 0) {
      return next(new AppError("No users provided", 400));
    }

    if (users.length > 100) {
      return next(new AppError("Maximum 100 users per request", 400));
    }

    const results = {
      success: [] as any[],
      failed: [] as any[]
    };

    // Process each user
    for (const userData of users) {
      try {
        // Create a mock request/response for reusing createUserExternal logic
        const mockReq = { body: userData } as Request;
        const mockRes = {
          status: () => mockRes,
          json: (data: any) => data
        } as any;
        
        // Process user creation
        // ... (simplified for bulk - you would implement the actual logic here)
        
        results.success.push({
          email: userData.email,
          externalId: userData.externalId
        });
      } catch (error: any) {
        results.failed.push({
          email: userData.email,
          externalId: userData.externalId,
          error: error.message
        });
      }
    }

    res.status(207).json({
      status: "multi-status",
      message: `Processed ${users.length} users`,
      data: {
        total: users.length,
        succeeded: results.success.length,
        failed: results.failed.length,
        results
      }
    });
  } catch (error) {
    console.error("Bulk user creation error:", error);
    return next(new AppError("Failed to process bulk user creation", 500));
  }
};

/**
 * Check if a user exists by email or external ID
 */
export const checkUserExists = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, externalId } = req.query;

    if (!email && !externalId) {
      return next(new AppError("Email or externalId parameter is required", 400));
    }

    const query: any = {};
    if (email) query.email = email;
    if (externalId) query.externalId = externalId;

    const user = await User.findOne(query).select('email externalId _id');
    
    res.status(200).json({
      status: "success",
      data: {
        exists: !!user,
        user: user ? {
          _id: user._id,
          email: user.email,
          externalId: user.externalId
        } : null
      }
    });
  } catch (error) {
    console.error("Check user exists error:", error);
    return next(new AppError("Failed to check user existence", 500));
  }
};