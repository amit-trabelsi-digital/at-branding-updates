import express from "express";
import { createCase, getAllCases, updateCase, deleteCase, getCaseById } from "../controllers/case-controller";

const router = express.Router();

router.post("/", createCase);
router.get("/", getAllCases);
router.get("/:id", getCaseById);
router.put("/:id", updateCase);
router.delete("/:id", deleteCase);

export default router;
