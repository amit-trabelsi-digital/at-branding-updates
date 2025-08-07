import { Request, Response, NextFunction } from "express";

interface CustomRequest extends Request {
  deviceType?: "android" | "ios" | "web";
  isValidApp?: boolean;
}

export const deviceCheckMiddleware = (req: CustomRequest, res: Response, next: NextFunction) => {
  const userAgent = req.headers["user-agent"]?.toLowerCase();
  const appToken = req.headers["x-app-token"]; // Custom header from your Flutter app

  // Verify if request is from your app
  const VALID_APP_TOKEN = process.env.APP_TOKEN; // Store this in environment variables
  console.log(appToken);
  console.log(VALID_APP_TOKEN);
  req.isValidApp = appToken === VALID_APP_TOKEN;

  if (!userAgent) {
    req.deviceType = "web";
    return next();
  }

  // Check for Android
  if (userAgent.includes("android")) {
    req.deviceType = "android";
  }
  // Check for iOS devices
  else if (userAgent.includes("iphone") || userAgent.includes("ipad") || userAgent.includes("ipod")) {
    req.deviceType = "ios";
  }
  // Default to web
  else {
    req.deviceType = "web";
  }
  console.log("req.deviceType", req.deviceType.yellow);

  next();
};
