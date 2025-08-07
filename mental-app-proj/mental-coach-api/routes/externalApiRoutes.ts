import { Router } from "express";
import {
  createUserExternal,
  bulkCreateUsersExternal,
  checkUserExists
} from "../controllers/external-api-controller";
import {
  authenticateExternalApi,
  rateLimitExternalApi
} from "../middlewares/externalApiAuthMiddleware";

const router = Router();

// Apply authentication to all routes
router.use(authenticateExternalApi);

// Apply rate limiting
router.use(rateLimitExternalApi(100, 60000)); // 100 requests per minute

/**
 * @route   POST /api/external/users
 * @desc    Create a new user
 * @access  External API with valid API key
 */
router.post("/users", createUserExternal);

/**
 * @route   POST /api/external/users/bulk
 * @desc    Create multiple users in bulk
 * @access  External API with valid API key
 */
router.post("/users/bulk", bulkCreateUsersExternal);

/**
 * @route   GET /api/external/users/exists
 * @desc    Check if a user exists by email or external ID
 * @access  External API with valid API key
 */
router.get("/users/exists", checkUserExists);

/**
 * @route   GET /api/external/health
 * @desc    Health check endpoint for external API
 * @access  External API with valid API key
 */
router.get("/health", (req, res) => {
  res.status(200).json({
    status: "success",
    message: "External API is operational",
    timestamp: new Date().toISOString(),
    version: "1.0.0"
  });
});

export default router;