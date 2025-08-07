import express from "express";
import { createTeam, deleteTeam, getAllTeams, getTeam, updateTeam } from "../controllers/team-controller";

const router = express.Router();

router.post("/", createTeam);
router.get("/", getAllTeams);
router.get("/:id", getTeam);
router.put("/:id", updateTeam);
router.delete("/:id", deleteTeam);

export default router;
