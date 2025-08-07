import express from "express";
import { trackUser } from "../controllers/track-controller";

const router = express.Router();

router.post("/", trackUser);

export default router;
