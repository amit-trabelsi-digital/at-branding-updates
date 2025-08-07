import express from "express";
import * as trainingProgramController from "../controllers/training-program-controller";
import { userGuardWithDB } from "../middlewares/appAuthMiddleware";
import "colors";

console.log(`[ROUTES] Loading training program routes`.cyan);

const router = express.Router();

// הוספת לוג לכל בקשה שמגיעה לראוטר
router.use((req, res, next) => {
  console.log(`[TRAINING ROUTES] Request received: ${req.method} ${req.path}`.yellow);
  next();
});

// כל ה-routes דורשים אימות משתמש
router.use(userGuardWithDB);

// Routes לתוכניות אימון
router
  .route("/")
  .get(trainingProgramController.getAllTrainingPrograms) // GET /api/training-programs
  .post(trainingProgramController.createTrainingProgram); // POST /api/training-programs

router
  .route("/:id")
  .get(trainingProgramController.getTrainingProgram) // GET /api/training-programs/:id
  .put(trainingProgramController.updateTrainingProgram) // PUT /api/training-programs/:id
  .patch(trainingProgramController.updateTrainingProgram) // PATCH /api/training-programs/:id
  .delete(trainingProgramController.deleteTrainingProgram); // DELETE /api/training-programs/:id

// Routes נוספים
router.get("/:id/lessons", trainingProgramController.getProgramLessons); // GET /api/training-programs/:id/lessons
router.patch("/:id/publish", trainingProgramController.togglePublishProgram); // PATCH /api/training-programs/:id/publish
router.get("/:id/stats", trainingProgramController.getProgramStats); // GET /api/training-programs/:id/stats

export default router; 