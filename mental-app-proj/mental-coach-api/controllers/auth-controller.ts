import _ from "lodash";
import firebase from "firebase-admin";
import User from "./../models/user-model";
import { Request, Response, NextFunction } from "express";
import AppError from "./../utils/appError";

export const signUp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { password, email, phone } = req.body;
    console.log(email);
    const duplicateEmail = await User.findOne({ email: email });
    console.log(duplicateEmail);
    if (duplicateEmail) {
      return next(new AppError("אימייל זה כבר קיים", 409));
    }

    const fireUser = await firebase.auth().createUser({
      displayName: email ? email.split("@")[0] : email,
      email: email,
      password: password,
    });

    const role = 3;
    await firebase.auth().setCustomUserClaims(fireUser.uid, {
      role,
    });
    const user = (await User.create({ phone, email, uid: fireUser.uid, role })).toObject();
    res.status(200).send({ ...user, role });
  } catch (err: any) {
    console.log(err);
    res.status(400).send({ message: err.message, code: err.code });
  }
};

export const generalLogin = async (req: Request, res: Response, next: NextFunction) => {
  const data = _.pick(req.body, "email");
  // console.log(data);
  const dbUser = await User.findOne({ email: data.email }).lean();
  if (!dbUser) {
    return next(new AppError("Incorrect email or password", 409));
  }
  res.status(200).send(dbUser);
};
``;

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log("Login : user");
    console.log(res.app.locals.user);
    res.send(res.app.locals.user);
  } catch (err) {
    console.error(err);
    res.sendStatus(400);
  }
};

export const checkAuthMethod = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, authMethod } = req.body;
    
    if (!email || !authMethod) {
      return next(new AppError("Email and auth method are required", 400));
    }

    const user = await User.findOne({ email });
    
    if (!user) {
      return next(new AppError("User not found", 404));
    }

    // Check if user is admin (role 0) - required for admin panel access
    const isAdmin = user.role === 0;
    
    const allowedMethods = user.allowedAuthMethods || {
      email: false,
      sms: true,
      google: true
    };

    const isAllowed = allowedMethods[authMethod as keyof typeof allowedMethods];
    
    if (!isAllowed) {
      return next(new AppError(`Authentication method '${authMethod}' is not allowed for this user`, 403));
    }

    res.status(200).json({ 
      allowed: true,
      authMethod,
      isAdmin,
      firebasePhoneNumber: authMethod === 'sms' ? user.firebasePhoneNumber : undefined
    });
  } catch (error) {
    console.error("Error checking auth method:", error);
    res.status(500).json({ message: "Failed to check auth method", error });
  }
};
