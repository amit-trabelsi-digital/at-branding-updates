import express from "express";

import { createScore, deleteScore, getAllScores, getScoreById, updateScore } from "../controllers/score-controller";
const router = express.Router();

router.post("/", createScore);
router.get("/", getAllScores);
router.get("/:id", getScoreById);
router.put("/:id", updateScore);
router.delete("/:id", deleteScore);

export default router;
