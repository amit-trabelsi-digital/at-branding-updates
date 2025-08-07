import express from "express";
import {
  createPersonallityGroup,
  getAllPersonallityGroups,
  updatePersonallityGroup,
  deletePersonallityGroup,
  getPersonallityGroupById,
} from "../controllers/personallity-group-controller";

const router = express.Router();

router.post("/", createPersonallityGroup);
router.get("/", getAllPersonallityGroups);
router.get("/:id", getPersonallityGroupById);
router.put("/:id", updatePersonallityGroup);
router.delete("/:id", deletePersonallityGroup);

export default router;
