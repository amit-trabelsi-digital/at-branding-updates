import express from "express";
import {
  sendOTP,
  verifyOTP,
  resendOTP,
  checkOTPServiceStatus
} from "../controllers/otp-controller";

const router = express.Router();

// Public routes (no authentication required)
router.post("/send", sendOTP);
router.post("/verify", verifyOTP);
router.post("/resend", resendOTP);

// Service status check
router.get("/status", checkOTPServiceStatus);

export default router;