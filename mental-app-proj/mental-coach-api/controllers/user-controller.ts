import { NextFunction, Request, Response } from "express";
import User, { IUser } from "../models/user-model"; // Adjust the path to your User model
import AppError from "./../utils/appError";
import admin from "firebase-admin";
import { getAuth } from "firebase-admin/auth";
import mongoose from "mongoose";
import { adminVerificationFunction } from "../middlewares/appAuthMiddleware";
import { IUserMatch, IUserTraining } from "../models/user-match-training-model";
import { findSoonestMatch } from "../utils/helpers";

interface Params {
  id: string;
}

// Create a new user
export const createUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    // default role is 3 - user

    let defaultRole = 3;

    // Extract and validate input data

    const { firstName, lastName, phone, email, password, nickName, age, position, bio, strongLeg, league, team, role, allowedAuthMethods }: IUser = req.body;

    if (!firstName || !email) {
      return next(new AppError("חסרים פרטי הרשמה", 400));
    }

    // *ONLY ADMIN CAN SET ROLE* - Only if User passing role, check if the user is admin and assign it
    let isCreatingAdmin = false;
    if (role !== undefined) {
      const isAdmin = await adminVerificationFunction(req.headers.authorization);
      if (isAdmin) {
        defaultRole = role;
        // Check if creating an admin user (role 0)
        if (role === 0) {
          isCreatingAdmin = true;
        }
      } else {
        return next(new AppError("Not authorized to pass role in user object", 401));
      }
    }

    const existEmail = await User.findOne({ email: email });
    if (existEmail) {
      return next(new AppError("חשבון עם האימייל הזה קיים במערכת", 400));
    }
    // Assign default role
    const _role = defaultRole;

    // Generate random password if not provided (for SMS/Google only users)
    // Firebase requires at least 6 characters
    const generateRandomPassword = () => {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
      let randomPassword = '';
      for (let i = 0; i < 12; i++) {
        randomPassword += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return randomPassword + 'Aa1!'; // Ensure it has uppercase, lowercase, number and special char
    };
    
    const finalPassword = password || generateRandomPassword();

    // Create Firebase user
    const firebaseUser = await getAuth().createUser({ email, password: finalPassword });

    // Set custom claims for the Firebase user
    await getAuth().setCustomUserClaims(firebaseUser.uid, { role: _role });

    // Prepare the user object for MongoDB
    const user = {
      firstName,
      lastName,
      phone,
      nickName,
      email,
      uid: firebaseUser.uid,
      role: _role,
      age,
      position,
      bio,
      strongLeg,
      league,
      team,
      allowedAuthMethods: isCreatingAdmin ? {
        email: false,
        sms: true,
        google: true
      } : (allowedAuthMethods || {
        email: false,
        sms: true,
        google: true
      })
    };

    // Save user to MongoDB
    const newUser = new User(user);
    await newUser.save();

    // Respond with success
    res.status(201).json({ message: "User created successfully", user: newUser });
  } catch (error: any) {
    console.error("Error creating user:", error);
    console.error("Error code:", error.code);
    console.error("Error message:", error.message);
    
    // Check if Firebase user creation was successful and clean up if needed
    if (error.code === "auth/email-already-exists") {
      return next(new AppError("חשבון עם האימייל הזה קיים במערכת", 400));
    }
    
    if (error.code === "auth/invalid-password") {
      return next(new AppError("סיסמה לא תקינה", 400));
    }
    
    if (error.code === "auth/weak-password") {
      return next(new AppError("הסיסמה חלשה מדי", 400));
    }

    // If Firebase user was created but MongoDB save failed, clean up Firebase user
    if (error instanceof mongoose.Error && req.body?.uid) {
      try {
        await getAuth().deleteUser(req.body.uid);
      } catch (firebaseError) {
        console.error("Error cleaning up Firebase user:", firebaseError);
      }
    }

    // Respond with generic server error
    return next(new AppError("נשכל ביצירת משתמש", 500));
  }
};

// Get all users
export const getUsers = async (req: Request, res: Response) => {
  try {
    console.log("INSIDE GET USERS");
    // role is a unselected field, so we need to explicitly select it
    const users = await User.find({});
    console.log(users);
    res.status(200).json(users);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Failed to fetch users", error });
  }
};

// Get a single user by ID
export const getUserById = async (req: Request<Params>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params; // req.params.id is a string
    const user = await User.findById(id);

    if (!user) {
      return next(new AppError("User not found", 404));
    }

    res.status(200).json({ user });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({ message: "Failed to fetch user", error });
  }
};

// Update user by ID
export const updateUser = async (req: Request<Params>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedData = req.body;

    // Check if firebasePhoneNumber is being updated
    if (updatedData.firebasePhoneNumber) {
      const user = await User.findById(id);
      if (!user) {
        return next(new AppError("User not found", 404));
      }

      // Update phone number in Firebase Auth if user has a uid
      if (user.uid) {
        try {
          const auth = getAuth();
          await auth.updateUser(user.uid, {
            phoneNumber: updatedData.firebasePhoneNumber
          });
          console.log(`Updated Firebase phone number for user ${user.uid} to ${updatedData.firebasePhoneNumber}`);
        } catch (firebaseError: any) {
          console.error("Error updating Firebase phone number:", firebaseError);
          // Don't fail the whole update if Firebase update fails
          // but log the error
          if (firebaseError.code === 'auth/invalid-phone-number') {
            return next(new AppError("Invalid phone number format. Must be E.164 format (e.g., +972501234567)", 400));
          }
        }
      }
    }

    const updatedUser = await User.findByIdAndUpdate(id, updatedData, {
      new: true,
      runValidators: true,
    });

    if (!updatedUser) {
      return next(new AppError("User not found", 404));
    }

    res.status(200).json({ message: "User updated successfully", user: updatedUser });
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({ message: "Failed to update user", error });
  }
};

export const updateUserByToken = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { uid } = res.app.locals;
    const updatedData = req.body;
    console.log("=-====================================== req.body", updatedData);

    if (!uid) {
      return next(new AppError("Problem with user token", 404));
    }

    const updatedUser = await User.findOneAndUpdate({ uid: uid }, updatedData, {
      new: true,
      runValidators: true,
    });

    if (!updatedUser) {
      return next(new AppError("User not found", 404));
    }

    const dataForClient = { ...updatedUser.toObject(), role: res.app.locals.role };
    console.log(dataForClient);
    res.status(200).json(dataForClient);
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({ message: "Failed to update user", error });
  }
};
export const updateMatchById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { uid } = res.app.locals;
    const updatedMatchData = req.body;
    const { matchId } = req.params;

    if (!uid) {
      return next(new AppError("Problem with user token", 404));
    }

    if (!matchId) {
      return next(new AppError("Match ID is required", 400));
    }
    console.log(matchId);
    // Use $set with dot notation to update only the provided fields
    const updatedUser = await User.findOneAndUpdate(
      { uid: uid, "matches._id": matchId },
      {
        $set: Object.entries(updatedMatchData).reduce<Record<string, any>>((acc, [key, value]) => {
          acc[`matches.$[match].${key}`] = value;
          return acc;
        }, {}),
      },
      {
        new: true,
        runValidators: true,
        arrayFilters: [{ "match._id": matchId }],
      },
    );

    if (!updatedUser) {
      return next(new AppError("User not found or match doesn't exist for this user", 404));
    }

    let newOpenMatch;
    if (updatedMatchData.hasOwnProperty("isOpen") && updatedMatchData.isOpen === false) {
      let upcomingItem = null;
      let soonestMatch = findSoonestMatch(req.app.locals.user.matches);
      let soonestTraining = findSoonestMatch(req.app.locals.user.trainings);

      if (soonestMatch && soonestTraining) {
        upcomingItem =
          soonestMatch.date < soonestTraining.date ? { type: "match", item: soonestMatch } : { type: "training", item: soonestTraining };
      } else if (soonestMatch) {
        upcomingItem = { type: "match", item: soonestMatch };
      } else if (soonestTraining) {
        upcomingItem = { type: "training", item: soonestTraining };
      }

      if (upcomingItem && upcomingItem.item) {
        upcomingItem.item.isOpen = true;
        const updatedNewItem = await User.findOneAndUpdate(
          { uid: uid, "matches._id": upcomingItem?.item._id },
          {
            $set: Object.entries(upcomingItem.item).reduce<Record<string, any>>((acc, [key, value]) => {
              acc[`matches.$[match].${key}`] = value;
              return acc;
            }, {}),
          },
          {
            new: true,
            runValidators: true,
            arrayFilters: [{ "match._id": upcomingItem?.item._id }],
          },
        );

        console.log("updatedNewItem", updatedNewItem);
        newOpenMatch = updatedNewItem?.matches?.find((match) => match._id === upcomingItem?.item._id);
      }
    }

    const updatedMatch = updatedUser.matches?.find((match) => match._id.toString() === matchId);
    // במידה והמשחק נסגר ונפתח משחק חדש אני מחזיר את החדש, ולא את מה שעודכן, מה שעודכן יתעדכן בקליינט בסיכום משחק

    console.log("OpenNEW MATCH", newOpenMatch);
    const dataForClient = newOpenMatch ? newOpenMatch : updatedMatch;
    res.status(200).json(dataForClient);
  } catch (error) {
    console.error("Error updating match:", error);
    next(new AppError(`Failed to update match: ${error instanceof Error ? error.message : "Unknown error"}`, 500));
  }
};
export const updateTrainingById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { uid } = res.app.locals;
    const updatedTrainingData = req.body;
    const { trainingId } = req.params;

    if (!uid) {
      return next(new AppError("Problem with user token", 404));
    }

    if (!trainingId) {
      return next(new AppError("Training ID is required", 400));
    }

    // Use $set with dot notation to update only the provided fields
    const updatedUser = await User.findOneAndUpdate(
      { uid: uid, "trainings._id": trainingId },
      {
        $set: Object.entries(updatedTrainingData).reduce<Record<string, any>>((acc, [key, value]) => {
          acc[`trainings.$[training].${key}`] = value;
          return acc;
        }, {}),
      },
      {
        new: true,
        runValidators: true,
        arrayFilters: [{ "training._id": trainingId }],
      },
    );

    if (!updatedUser) {
      return next(new AppError("User not found or match doesn't exist for this user", 404));
    }

    const updatedTraining = updatedUser.trainings?.find((training) => training._id.toString() === trainingId);
    console.log("updatedTraining".red, updatedTraining);
    res.status(200).json(updatedTraining);
  } catch (error) {
    console.error("Error updating match:", error);
    next(new AppError(`Failed to update match: ${error instanceof Error ? error.message : "Unknown error"}`, 500));
  }
};

// Delete user by ID
export const deleteUser = async (req: Request<Params>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params; // req.params.id is a string

    const deletedUser = await User.findByIdAndDelete(id);
    if (!deletedUser) {
      return next(new AppError("User not found", 404));
    }

    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({ message: "Failed to delete user", error });
  }
};

export const forgotPassword = async (req: Request, res: Response, next: NextFunction) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) {
    return next(new AppError("there is no user with this email", 404));
  }
  try {
    // 2) Generate the random reset token
    const resetLink = await admin.auth().generatePasswordResetLink(user.email, {
      url: "https://yourapp.page.link/reset", //  Dynamic link לשנות את הקישור
      handleCodeInApp: true,
    });

    // await new Email(user, resetLink).sendPasswordReset();
    user.passwordResetDateMethod(); // setting date when update reset

    res.status(200).json({
      status: "success",
      message: "Token sent to email!",
    });
  } catch (err) {
    await user.save({ validateBeforeSave: false });
    res.status(500).json({
      status: "fail",
      message: "There was an error with the Email sending, please try again",
    });
  }
};

// 2. Ensuring the Link Opens the App
// To ensure the reset link opens the app, you can use Firebase Dynamic Links.

// Steps to Configure Firebase Dynamic Links for Password Reset
// Set Up Dynamic Links in Firebase:

// Go to Firebase Console → Dynamic Links → Get Started.
// Create a dynamic link domain (e.g., yourapp.page.link).
// Configure the behavior for both the app and fallback web URL.
// Generate the Password Reset Link: When generating the link via firebase-admin or Firebase Auth, specify:

// url: A page within the app to handle the password reset.
// handleCodeInApp: true: Ensures the link opens in the app.
// Example:

// javascript
// Copy code
// const resetLink = await admin.auth().generatePasswordResetLink(userEmail, {
//   url: "https://yourapp.page.link/reset",
//   handleCodeInApp: true,
// });
// Deep Linking in the App:

// Use the Linking API or Firebase Dynamic Links SDK in your React Native app to handle the link and extract the reset code (oobCode).
// Navigate the user to the reset password screen.
// Example:

// javascript
// Copy code
// import dynamicLinks from "@react-native-firebase/dynamic-links";

// useEffect(() => {
//   const unsubscribe = dynamicLinks().onLink((link) => {
//     if (link.url.includes("reset")) {
//       const actionCode = new URLSearchParams(link.url).get("oobCode");
//       navigation.navigate("ResetPassword", { actionCode });
//     }
//   });

//   return () => unsubscribe();
// }, []);
// Fallback Web Page:

// If the app is not installed, ensure the fallback URL in the dynamic link leads to a web page where users can reset their password.
