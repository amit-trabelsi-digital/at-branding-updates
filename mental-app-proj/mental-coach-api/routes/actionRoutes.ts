import express from "express";

import { createAction, deleteAction, getAllActions, getActionById, updateAction } from "../controllers/action-controller";
const router = express.Router();

router.post("/", createAction);
router.get("/", getAllActions);
router.get("/:id", getActionById);
router.put("/:id", updateAction);
router.delete("/:id", deleteAction);

export default router;
