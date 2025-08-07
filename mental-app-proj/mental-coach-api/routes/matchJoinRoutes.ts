import express from "express";
import {
  createMatchJoin,
  getAllMatchJoins,
  getMatchJoin,
  updateMatchJoin,
  deleteMatchJoin,
  getMatchJoinsByMatch,
  getAllMatchJoinsByUser,
} from "../controllers/match-join-controller";
import { adminGuard, userGuard, userGuardWithDB } from "../middlewares/appAuthMiddleware";

const router = express.Router();

router.get("/", adminGuard, getAllMatchJoins);
router.post("/", userGuard, createMatchJoin);

router.get("/user", userGuardWithDB, getAllMatchJoinsByUser);
router.route("/:id").get(getMatchJoin).patch(updateMatchJoin).delete(deleteMatchJoin);

router.get("/match/:matchId", getMatchJoinsByMatch);

export default router;
