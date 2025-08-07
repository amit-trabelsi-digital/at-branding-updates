import express from "express";

import {
  createPushMessage,
  deletePushMessage,
  getAllPushMessages,
  getPushMessage,
  updatePushMessage,
  updateToken,
  pushMessageForUsers,
  pushMessageForOneUser,
} from "../controllers/push-message-controller";
import { userGuard } from "../middlewares/appAuthMiddleware";
const router = express.Router();

router.post("/", createPushMessage);
router.get("/", getAllPushMessages);

router.post("/update-token", userGuard, updateToken); // מעדכן fmc token
router.post("/message-all", pushMessageForUsers);
router.post("/message-user", pushMessageForOneUser);

router.get("/:id", getPushMessage);
router.put("/:id", updatePushMessage);
router.delete("/:id", deletePushMessage);

export default router;
