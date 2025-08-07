import express from "express";

import { createGoal, deleteGoal, getAllGoals, getGoalById, updateGoal } from "../controllers/goal-controller";
const router = express.Router();

router.post("/", createGoal);
router.get("/", getAllGoals);
router.get("/:id", getGoalById);
router.put("/:id", updateGoal);
router.delete("/:id", deleteGoal);

export default router;
