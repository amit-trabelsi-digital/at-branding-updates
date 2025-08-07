import express from "express";
import {
  createUser,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  forgotPassword,
  updateUserByToken,
  updateTrainingById,
  updateMatchById,
} from "../controllers/user-controller";
import { adminGuard, userGuard, userGuardWithDB } from "../middlewares/appAuthMiddleware";
import { deviceCheckMiddleware } from "../middlewares/deviceCheckMiddleware";
const router = express.Router();

router.post("/", deviceCheckMiddleware, createUser);
router.get("/", adminGuard, getUsers);
router.post("/forgot-password", forgotPassword);
router.put("/update", userGuardWithDB, updateUserByToken);
router.put("/update-match/:matchId", userGuardWithDB, updateMatchById);
router.put("/update-training/:trainingId", userGuard, updateTrainingById);
router.get("/:id", getUserById);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

export default router;
