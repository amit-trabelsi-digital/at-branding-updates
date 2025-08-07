import express from "express";

import { createLeague, deleteLeague, getAllLeagues, getLeague, updateLeague } from "./../controllers/league-contoller";
const router = express.Router();

router.post("/", createLeague);
router.get("/", getAllLeagues);
router.get("/:id", getLeague);
router.put("/:id", updateLeague);
router.delete("/:id", deleteLeague);

export default router;
