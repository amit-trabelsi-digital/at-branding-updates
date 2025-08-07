import express from "express";
import { createMatch, createTraining, deleteMatch, getAllMatchs, getMatchById, updateMatch } from "../controllers/match-controller";
import { adminGuard, userGuard, userGuardWithDB } from "../middlewares/appAuthMiddleware";

const router = express.Router();

router.post("/", userGuardWithDB, createMatch);
router.post("/training", userGuardWithDB, createTraining);
router.get("/", getAllMatchs);
router.get("/:id", getMatchById);
router.put("/:id", updateMatch);
router.delete("/:id", deleteMatch);

// Only admin can access the following routes
router.use(adminGuard);
router.route("/admin").post(createMatch).get(getAllMatchs);
router.route("/admin/:id").get(getMatchById).put(updateMatch).delete(deleteMatch);

export default router;
