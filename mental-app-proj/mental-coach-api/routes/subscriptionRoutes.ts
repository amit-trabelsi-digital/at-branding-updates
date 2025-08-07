import express from "express";
import {
  createSubscription,
  getSubscriptionById,
  getAllSubscriptions,
  updateSubscriptionById,
  deleteSubscriptionById,
} from "../controllers/subscription-controller";
import { adminGuard, userGuardWithDB } from "../middlewares/appAuthMiddleware";
const router = express.Router();

router.post("/", userGuardWithDB, createSubscription);

router.use(adminGuard);

router.get("/:id", getSubscriptionById);
router.get("/", getAllSubscriptions);
router.put("/:id", updateSubscriptionById);
router.delete("/:id", deleteSubscriptionById);

export default router;
