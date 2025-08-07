import express from "express";
import * as exerciseController from "../controllers/exercise-controller";
import { userGuardWithDB } from "../middlewares/appAuthMiddleware";

const router = express.Router();

// כל ה-routes דורשים אימות משתמש
router.use(userGuardWithDB);

// Routes לתרגילים
router
  .route("/")
  .post(exerciseController.createExercise); // POST /api/exercises

router
  .route("/:id")
  .get(exerciseController.getExercise) // GET /api/exercises/:id
  .put(exerciseController.updateExercise) // PUT /api/exercises/:id
  .delete(exerciseController.deleteExercise); // DELETE /api/exercises/:id

// Routes נוספים
router.post("/:id/submit", exerciseController.submitExercise); // POST /api/exercises/:id/submit
router.get("/:id/stats", exerciseController.getExerciseStats); // GET /api/exercises/:id/stats

// Routes ליצירת סוגי תרגילים ספציפיים
router.post("/questionnaire", exerciseController.createQuestionnaireExercise); // POST /api/exercises/questionnaire
router.post("/text-input", exerciseController.createTextInputExercise); // POST /api/exercises/text-input

export default router; 