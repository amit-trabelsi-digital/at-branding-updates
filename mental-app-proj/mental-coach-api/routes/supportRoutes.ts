import express from "express";
import { sendSupportRequest } from "../controllers/support-controller";
import { appAuthMiddleware } from "../middlewares/appAuthMiddleware";

const router = express.Router();

// שליחת בקשת תמיכה - דורש אימות משתמש
router.post("/support", appAuthMiddleware(3), sendSupportRequest);

export default router;