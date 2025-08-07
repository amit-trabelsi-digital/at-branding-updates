import { NextFunction, Response, Request } from "express";
import AppError from "../utils/appError";
import fs from "fs";
import path from "path";

// Create a directory for logs if it doesn't exist
const logsDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// File paths
const userScoresPath = path.join(logsDir, "user-scores.json");

// Function to get daily log file path
const getDailyLogPath = () => {
  const now = new Date();
  const dateString = now.toISOString().split("T")[0]; // Format: YYYY-MM-DD
  return path.join(logsDir, `user-tracking-${dateString}.log`);
};

// Initialize or load userScores
let userScores: Record<string, number> = {};
try {
  if (fs.existsSync(userScoresPath)) {
    const data = fs.readFileSync(userScoresPath, "utf8");
    userScores = JSON.parse(data);
  }
} catch (error) {
  console.error("Error loading user scores:", error);
}

export const trackUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId, action, timestamp, metadata = {} } = req.body;
    console.log(userId);

    if (!userId || !action) {
      return next(new AppError("User ID and action are required", 400));
    }

    // Create log entry
    const logEntry = {
      userId,
      action,
      timestamp: timestamp || new Date().toISOString(),
      ip: req.ip,
    };

    // Get today's log file path
    const todayLogPath = getDailyLogPath();

    // Write to daily log file
    fs.appendFileSync(todayLogPath, JSON.stringify(logEntry) + "\n", "utf8");

    // Update score (example logic: +10 points per action)
    if (!userScores[userId]) {
      userScores[userId] = 0;
    }
    userScores[userId] += 10;

    // Save updated scores
    fs.writeFileSync(userScoresPath, JSON.stringify(userScores, null, 2), "utf8");

    // Send response
    res.status(200).json({
      success: true,
      message: "Action tracked successfully",
      currentScore: userScores[userId],
    });
  } catch (error) {
    console.error("Error tracking user activity:", error);
    next(new AppError("Failed to track user activity", 500));
  }
};

// You might want to add an endpoint to retrieve user scores
export const getUserScore = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return next(new AppError("User ID is required", 400));
    }

    const score = userScores[userId] || 0;

    res.status(200).json({
      userId,
      score,
    });
  } catch (error) {
    next(new AppError("Failed to retrieve user score", 500));
  }
};
