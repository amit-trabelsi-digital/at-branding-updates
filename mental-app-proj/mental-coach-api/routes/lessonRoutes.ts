import express from "express";
import * as lessonController from "../controllers/lesson-controller";
import { userGuardWithDB } from "../middlewares/appAuthMiddleware";

const router = express.Router();

// כל ה-routes דורשים אימות משתמש
router.use(userGuardWithDB);

// Routes לשיעורים
router
  .route("/")
  .get(lessonController.getAllLessons) // GET /api/lessons (with query params)
  .post(lessonController.createLesson); // POST /api/lessons

// PUT /api/lessons/reorder - עדכון סדר השיעורים
// חשוב! חייב להיות לפני ה-routes עם :id
router.put("/reorder", lessonController.updateLessonsOrder);

router
  .route("/:id")
  .get(lessonController.getLesson) // GET /api/lessons/:id
  .put(lessonController.updateLesson) // PUT /api/lessons/:id
  .delete(lessonController.deleteLesson); // DELETE /api/lessons/:id

// Routes נוספים
router.get("/:id/exercises", lessonController.getLessonExercises); // GET /api/lessons/:id/exercises
router.post("/:id/start", lessonController.startLesson); // POST /api/lessons/:id/start
router.get("/:id/start", lessonController.startLesson); // POST /api/lessons/:id/start
router.put("/:id/progress", lessonController.updateLessonProgress); // PUT /api/lessons/:id/progress
router.patch("/:id/publish", lessonController.togglePublishLesson); // PATCH /api/lessons/:id/publish

export default router; 