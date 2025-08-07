import { NextFunction, Request, Response } from "express";
import firebase from "firebase-admin";
import User from "../models/user-model";
import _ from "lodash";
import { DecodedIdToken } from "firebase-admin/auth";
import ErrorModel from "../models/error.model";
import AppError from "../utils/appError";
import Email from "../utils/react-email";
import "colors";

export const appAuthMiddleware = (maxRole = 3, options = { passDbUser: false, checkForOpenMatches: false }) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    console.log(`[AUTH MIDDLEWARE] Starting authentication for ${req.method} ${req.originalUrl}`.magenta);
    try {
      let dbUser;
      let needRefreshToken = false;
      const authHeader = req.headers.authorization;
      console.log(`[AUTH] Auth header present: ${!!authHeader}`.magenta);
      
      if (!authHeader) throw new Error("Unauthorized");
      
      // הסרת ה-Bearer prefix אם קיים
      const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;
      console.log(`[AUTH] Token length: ${token.length}`.magenta);
      
      const decodedToken: DecodedIdToken = await firebase.auth().verifyIdToken(token);
      const { uid, role, email } = decodedToken;
      console.log(`[AUTH] Decoded token - UID: ${uid}, Role: ${role}, Email: ${email}`.magenta);
      console.log(role);
      const mongoUserExist = await User.exists({ email });
      if (role !== undefined && uid && !mongoUserExist) {
        const data = _.pick(decodedToken, ["email", "name"]);
        dbUser = await User.create({ ...data, uid: decodedToken.uid });
        await new Email({ email: email, name: "אלוף" }).sendWelcome();
      }

      if (role === undefined && uid) {
        needRefreshToken = true;
        const newRole = 3;
        const data = _.pick(decodedToken, ["email", "name"]);
        await firebase.auth().setCustomUserClaims(decodedToken.uid, {
          role: newRole,
        });
        decodedToken.role = newRole;
        if (!mongoUserExist) {
          dbUser = await User.create({ ...data, uid: decodedToken.uid });
        } else {
          dbUser = await User.findByIdAndUpdate(mongoUserExist._id, { uid: decodedToken.uid }, { new: true }).populate("team league");
        }
      }

      if (role > maxRole) throw Error(`user role is too big`);

      res.app.locals.uid = uid;
      console.log("asdasdasdasdasd================================", decodedToken.role);
      res.app.locals.role = decodedToken.role || 3;

      if (options.passDbUser && !dbUser) {
        console.log(`[AUTH] Fetching DB user for UID: ${uid}`.magenta);
        dbUser = await User.findOne({ uid }).populate("team league");
        if (!dbUser) {
          console.log(`[AUTH ERROR] DB user not found for UID: ${uid}`.red);
          throw new Error();
        }
        console.log(`[AUTH] User found with mentalTrainingProgress: ${dbUser.mentalTrainingProgress?.length || 0}`.magenta);
      }

      if (dbUser) {
        dbUser.matches = dbUser.matches?.filter((match) => match.visible === true) || [];
        dbUser.trainings = dbUser.trainings?.filter((training) => training.visible === true) || [];
      }

      if (dbUser) {
        console.log("full user send");
        console.log(`[AUTH] Setting user in locals: ${dbUser.email}`.magenta);
        res.app.locals.user = {
          ...dbUser.toObject(),
          role: decodedToken.role || 3,
          needRefreshToken,
        };
      } else {
        console.log(`[AUTH ERROR] No DB user to set in locals`.red);
        next(new AppError("User not found", 404));
      }

      console.log(`[AUTH] Authentication successful, proceeding to next middleware`.green);
      next();
    } catch (err) {
      console.error(`[AUTH ERROR] Authentication failed:`.red, err);
      res.status(401).send({ message: "Unauthorized" });
    }
  };
};

const adminVerificationFunction = async (authorization: string | undefined): Promise<boolean> => {
  try {
    const authHeader = authorization;
    if (!authHeader) throw new Error("Unauthorized");

    // הסרת ה-Bearer prefix אם קיים
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;
    
    const decodedToken: DecodedIdToken = await firebase.auth().verifyIdToken(token);
    const { role } = decodedToken;
    console.log("Inside admin verification function");
    console.log(role);
    if (role == 0) {
      return true;
    }
    // If user passed AuthHeader authentication and he is not admin, its probably hacking
    await ErrorModel.create({
      errorType: "security-error",
      errorMsg: `Propeply hacker trying to access to admin settings, userInfo:  ${
        (decodedToken.email, decodedToken.uid, decodedToken.role)
      }`,
    });
    return false;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const adminGuard = appAuthMiddleware(0, { passDbUser: true, checkForOpenMatches: false });
const userGuard = appAuthMiddleware(3);
const userGuardWithDB = appAuthMiddleware(3, { passDbUser: true, checkForOpenMatches: false });
const userGuardForLogin = appAuthMiddleware(3, { passDbUser: true, checkForOpenMatches: false });

export { adminGuard, userGuard, userGuardWithDB, adminVerificationFunction, userGuardForLogin };

// if (options.checkForOpenMatches) {
//   // בודק אם אין למשתמש משחקים פתוחים ואין לו אימונים פתוחים ופותח את הקרוב ביותר

//   const hasOpenMatch = dbUser.matches && Array.isArray(dbUser.matches) && dbUser.matches.some((match) => match.isOpen === true);
//   const hasOpenTraining =
//     dbUser.trainings && Array.isArray(dbUser.trainings) && dbUser.trainings.some((training) => training.isOpen === true);

//   if (!hasOpenMatch && !hasOpenTraining) {
//     // Find the soonest upcoming match
//     let soonestMatch: IUserMatch | IUserTraining | null = null;
//     if (dbUser.matches && Array.isArray(dbUser.matches)) {
//       soonestMatch = findSoonestMatch(dbUser.matches);
//       console.log("soonestTraining".yellow, soonestMatch);
//     }
//     // Find the soonest upcoming training
//     let soonestTraining: IUserMatch | IUserTraining | null = null;
//     if (dbUser.trainings && Array.isArray(dbUser.trainings)) {
//       soonestTraining = findSoonestMatch(dbUser.trainings);
//       console.log("soonestTraining".yellow, soonestTraining);
//     }
//     // Compare soonest match with soonest training to determine overall soonest event
//     let upcomingItem = null;
//     if (soonestMatch && soonestTraining) {
//       // Compare dates to see which event is sooner
//       upcomingItem =
//         soonestMatch.date < soonestTraining.date
//           ? { type: "match", item: soonestMatch }
//           : { type: "training", item: soonestTraining };
//     } else if (soonestMatch) {
//       upcomingItem = { type: "match", item: soonestMatch };
//     } else if (soonestTraining) {
//       upcomingItem = { type: "training", item: soonestTraining };
//     }

//     if (upcomingItem?.type === "match" && dbUser && dbUser.matches) {
//       const matchIndex = dbUser.matches.findIndex((match) => match._id === upcomingItem.item._id);
//       if (matchIndex !== -1) {
//         dbUser.matches[matchIndex].isOpen = true;
//         await dbUser.save();
//       }
//     }

//     if (upcomingItem?.type === "training" && dbUser && dbUser.trainings) {
//       const trainingIndex = dbUser.trainings.findIndex((training) => training._id === upcomingItem.item._id);
//       if (trainingIndex !== -1) {
//         dbUser.trainings[trainingIndex].isOpen = true;
//         await dbUser.save();
//       }
//     }
//   }
// }
