import express from "express";
import * as userProgressController from "../controllers/user-progress-controller";
import { userGuardWithDB } from "../middlewares/appAuthMiddleware";

const router = express.Router();

// כל ה-routes דורשים אימות משתמש
router.use(userGuardWithDB);

// Routes להתקדמות המשתמש
router.get("/training-progress", userProgressController.getUserTrainingProgress); // GET /api/user/training-progress
router.get("/training-progress/:programId", userProgressController.getProgramProgress); // GET /api/user/training-progress/:programId
router.post("/enroll/:programId", userProgressController.enrollInProgram); // POST /api/user/enroll/:programId
router.put("/lesson-progress/:lessonId", userProgressController.updateLessonProgress); // PUT /api/user/lesson-progress/:lessonId

// Routes נוספים
router.get("/progress-report", userProgressController.getDetailedProgressReport); // GET /api/user/progress-report
router.post("/reset-progress/:programId", userProgressController.resetProgramProgress); // POST /api/user/reset-progress/:programId
router.get("/next-lesson/:programId", userProgressController.getNextLesson); // GET /api/user/next-lesson/:programId
router.get("/exercise-responses", userProgressController.getUserExerciseResponses); // GET /api/user/exercise-responses

export default router; 