import express from "express";
import {
  createEitanMessage,
  getAllEitanMessages,
  getEitanMessage,
  updateEitanMessage,
  deleteEitanMessage,
} from "../controllers/eitan-message-controller";

const router = express.Router();

router.post("/", createEitanMessage);
router.get("/", getAllEitanMessages);
router.get("/:id", getEitanMessage);
router.put("/:id", updateEitanMessage);
router.delete("/:id", deleteEitanMessage);

export default router;
