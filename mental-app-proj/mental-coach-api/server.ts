import express, { NextFunction, Request } from "express";
import mongoose from "mongoose";
import hpp from "hpp";
import morgan from "morgan";
import mongoSanitize from "express-mongo-sanitize";
import cors from "cors";
import dotenv from "dotenv";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import AppError from "./utils/appError";
import globalErrorHandler from "./controllers/error-controller";
import "colors";
import corsOptions, { handlePreflight } from "./config/cors.config";

// import productRoutes from "./routes/productRoutes.js";
dotenv.config({ path: "./.env" });

import "./lib/firebase";
import authRoutes from "./routes/authRoutes";
import userRoutes from "./routes/userRoutes";
import matchRoutes from "./routes/matchRoutes";
import leagueRoutes from "./routes/leagueRoutes";
import teamRoutes from "./routes/teamRoutes";
import goalRoutes from "./routes/goalRoutes";
import actionRoutes from "./routes/actionRoutes";
import pushMessages from "./routes/pushMessagesRoutes";
import eitanMessages from "./routes/eitanMessagesRoutes";
import caseRoutes from "./routes/caseRoutes";
import generalRoutes from "./routes/generlRoutes";
import scoreRoutes from "./routes/scoreRoutes";
import personallityGroupRoutes from "./routes/personallityGroupRoutes";
import matchJoinRoutes from "./routes/matchJoinRoutes";
import trackActivityRoutes from "./routes/trackRoutes";
import subscriptionRoutes from "./routes/subscriptionRoutes";
import trainingProgramRoutes from "./routes/trainingProgramRoutes";
import lessonRoutes from "./routes/lessonRoutes";
import exerciseRoutes from "./routes/exerciseRoutes";
import userProgressRoutes from "./routes/userProgressRoutes";
import supportRoutes from "./routes/supportRoutes";
import infoRoutes from "./routes/infoRoutes";
import otpRoutes from "./routes/otpRoutes";
import externalApiRoutes from "./routes/externalApiRoutes";

const app = express();

const PORT = process.env.PORT || 3000;

// Middleware לטיפול בבעיות JSON parsing
app.use(express.json({
  verify: (req: any, res, buf) => {
    try {
      JSON.parse(buf.toString());
    } catch (e) {
      // אם ה-JSON לא תקין, נשמור body ריק
      req.body = {};
      console.log('[JSON PARSE WARNING] Invalid JSON received, using empty object'.yellow);
    }
  }
}));

// הוספת middleware לוגים כללי אחרי body parser
app.use((req: Request, res, next: NextFunction) => {
  console.log(`\n${"=".repeat(50)}`.cyan);
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`.yellow);
  console.log(`Headers:`, req.headers);
  console.log(`Query:`, req.query);
  console.log(`Body:`, req.body);
  console.log(`${"=".repeat(50)}`.cyan);
  next();
});
app.use(morgan(process.env.NODE_ENV === "development" ? "short" : "tiny"));
const limiter = rateLimit({
  max: 1000, // Limit each IP to 100 requests per `window`
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers`
});
app.use(limiter);
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginOpenerPolicy: { policy: "unsafe-none" },
    crossOriginEmbedderPolicy: false,
  }),
);
app.use(hpp());
app.use(mongoSanitize());

// הוספת middleware לטיפול ב-preflight requests
app.use(handlePreflight);

// הגדרות CORS מודולריות
app.use(cors(corsOptions));

app.use(express.urlencoded({ limit: "8mb", extended: true }));

app.use("/api/users", userRoutes);
app.use("/api/matches", matchRoutes);
app.use("/api/leagues", leagueRoutes);
app.use("/api/teams", teamRoutes);
app.use("/api/pushMessages", pushMessages);
app.use("/api/eitanMessages", eitanMessages);
app.use("/api/cases", caseRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/otp", otpRoutes);
app.use("/api/general", generalRoutes);
app.use("/api/goals", goalRoutes);
app.use("/api/actions", actionRoutes);
app.use("/api/scores", scoreRoutes);
app.use("/api/personallity-groups", personallityGroupRoutes);
app.use("/api/match-joins", matchJoinRoutes);
app.use("/api/track-activity", trackActivityRoutes);
app.use("/api/subscription", subscriptionRoutes);
app.use("/api", supportRoutes);
app.use("/api/info", infoRoutes);

// External API Routes - For third-party services
app.use("/api/external", externalApiRoutes);

// Routes למערכת הקורסים הדיגיטליים
app.use("/api/training-programs", (req: Request, res, next: NextFunction) => {
  console.log(`[ROUTE HANDLER] /api/training-programs - ${req.method} ${req.path}`.green);
  next();
}, trainingProgramRoutes);
app.use("/api/lessons", lessonRoutes);
app.use("/api/exercises", exerciseRoutes);
app.use("/api/user", userProgressRoutes);

// נקודת קצה לבדיקת בריאות השרת
app.get("/", async (req: Request, res) => {
  try {
    // בדיקת חיבור למסד הנתונים
    const dbState = mongoose.connection.readyState;
    const dbStatus = dbState === 1 ? "מחובר" : "לא מחובר";
    
    const healthCheck = {
      status: "תקין",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || "development",
      database: {
        status: dbStatus,
        name: process.env.DB_NAME || "לא הוגדר",
        state: dbState // 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
      },
      server: {
        port: PORT,
        uptime: process.uptime(),
        memoryUsage: process.memoryUsage()
      }
    };
    
    res.status(200).json(healthCheck);
  } catch (error) {
    res.status(503).json({
      status: "שגיאה",
      error: error instanceof Error ? error.message : "שגיאה לא ידועה",
      timestamp: new Date().toISOString()
    });
  }
});

// טיפול ב-favicon.ico
app.get("/favicon.ico", (req: Request, res) => {
  res.status(204).end();
});

// נקודת קצה לבדיקת בריאות ב-API
app.get("/api/health", async (req: Request, res) => {
  try {
    const dbState = mongoose.connection.readyState;
    const dbStatus = dbState === 1 ? "connected" : "disconnected";
    
    res.status(200).json({
      status: "ok",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || "development",
      database: {
        status: dbStatus,
        name: process.env.DB_NAME || "not configured",
        state: dbState
      },
      server: {
        port: PORT,
        uptime: Math.floor(process.uptime()),
        memory: {
          used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
        }
      }
    });
  } catch (error) {
    res.status(503).json({
      status: "error",
      error: error instanceof Error ? error.message : "Unknown error",
      timestamp: new Date().toISOString()
    });
  }
});

// הוספת redirects לנתיבים שמגיעים בלי /api
app.use("/training-programs*", (req: Request, res) => {
  const newUrl = `/api${req.originalUrl}`;
  console.log(`[REDIRECT] 301 Redirecting ${req.originalUrl} to ${newUrl}`.yellow);
  res.redirect(301, newUrl);
});

app.use("/lessons*", (req: Request, res) => {
  const newUrl = `/api${req.originalUrl}`;
  console.log(`[REDIRECT] 301 Redirecting ${req.originalUrl} to ${newUrl}`.yellow);
  res.redirect(301, newUrl);
});

app.use("/exercises*", (req: Request, res) => {
  const newUrl = `/api${req.originalUrl}`;
  console.log(`[REDIRECT] 301 Redirecting ${req.originalUrl} to ${newUrl}`.yellow);
  res.redirect(301, newUrl);
});

// תפיסת כל הנתיבים שלא נמצאו
app.all("*", (req: Request, res, next: NextFunction) => {
  console.log(`[404 ERROR] Route not found: ${req.method} ${req.originalUrl}`.red);
  console.log(`Available routes:`.yellow);
  console.log(`- / (health check)`);
  console.log(`- /api/health`);
  console.log(`- /api/training-programs`);
  console.log(`- /api/lessons`);
  console.log(`- /api/exercises`);
  console.log(`- /api/user`);
  console.log(`- /api/users`);
  console.log(`- /api/matches`);
  console.log(`- /api/leagues`);
  console.log(`- /api/teams`);
  console.log(`- /api/pushMessages`);
  console.log(`- /api/eitanMessages`);
  console.log(`- /api/cases`);
  console.log(`- /api/auth`);
  console.log(`- /api/general`);
  console.log(`- /api/goals`);
  console.log(`- /api/actions`);
  console.log(`- /api/scores`);
  console.log(`- /api/personallity-groups`);
  console.log(`- /api/match-joins`);
  console.log(`- /api/track-activity`);
  console.log(`- /api/subscription`);
  next(new AppError(`Can't find ${req.originalUrl} at this Server!`, 500));
});

mongoose
  .connect(process.env.MONGO_URI_DEV || "mongodb://localhost:27017/", { dbName: process.env.DB_NAME })
  .then(() => {
    console.log("Connected to mongoose".green), console.log(`DB: ${process.env.DB_NAME}`.green);
  })
  .catch((err) => {
    console.log(err);
  });

app.use(globalErrorHandler);
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

// '0001 , Click , move to lesson'
// '0002 , click , purchase'
// '0003 , click , play audio'
// '0004 , click , save profile'
// '0005 , Click , Create Account'
// '0006 , Click , Login'
// '0007 , Click , Save Profile'
// '0008 , Click , Sign Up'
// '0009 , Click , Select Date'
// '0010 , Click , Add Match'
// '0012 , Click , Submit Match Investigation'
// '0013 , Click , Submit Match Summery'
// '0014 , Click , Set prepare match'
// '0015 , Click , Add Match In Schedule'
// '0016 , Click , Go To Prepare For Match'
// '0017 , Click , Prepare Match In xl match card'
// '0018 , Click , Match Investigation In xl match card'
// '0019 , Click , Add Game In xl match card disabled'
// '0020 , Click , I Got It In Notify'
// '0021 , Click , Retry Video'
