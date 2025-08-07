import { Request, Response, NextFunction } from "express";
import LessonExercise, { 
  IQuestionnaireContent, 
  ITextInputContent, 
  IVideoReflectionContent,
  IActionPlanContent,
  IMentalVisualizationContent 
} from "../models/lesson-exercise-model";
import Lesson from "../models/lesson-model";
import TrainingProgram from "../models/training-program-model";
import User from "../models/user-model";
import catchAsync from "../utils/catchAsync";
import AppError from "../utils/appError";

// קבלת תרגיל ספציפי
export const getExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const exercise = await LessonExercise.findById(req.params.id)
    .populate("lessonId", "title shortTitle");
  
  if (!exercise) {
    return next(new AppError("תרגיל לא נמצא", 404));
  }
  
  // בדיקת הרשאות דרך השיעור
  const lesson = await Lesson.findById(exercise.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const hasAccess = 
    lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
    lesson.accessRules.specificUsers.some(userId => userId.toString() === user._id.toString());
  
  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה לצפות בתרגיל זה", 403));
  }
  
  res.status(200).json({
    status: "success",
    data: {
      exercise
    }
  });
});

// יצירת תרגיל חדש
export const createExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  // בדיקת הרשאות - דרך השיעור והתוכנית
  const lesson = await Lesson.findById(req.body.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה להוסיף תרגילים לשיעור זה", 403));
  }
  
  // חישוב מספר התרגיל הבא
  const exercisesCount = await LessonExercise.countDocuments({ lessonId: req.body.lessonId });
  
  const exerciseData = {
    ...req.body,
    exerciseId: req.body.exerciseId || `exercise_${exercisesCount + 1}`,
    "settings.order": req.body.settings?.order || exercisesCount,
    createdBy: user._id,
    lastModifiedBy: user._id
  };
  
  // ולידציה של תוכן התרגיל לפי הסוג
  if (!validateExerciseContent(exerciseData.type, exerciseData.content)) {
    return next(new AppError("תוכן התרגיל לא תואם לסוג התרגיל שנבחר", 400));
  }
  
  const newExercise = await LessonExercise.create(exerciseData);
  
  res.status(201).json({
    status: "success",
    data: {
      exercise: newExercise
    }
  });
});

// עדכון תרגיל
export const updateExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const exercise = await LessonExercise.findById(req.params.id);
  
  if (!exercise) {
    return next(new AppError("תרגיל לא נמצא", 404));
  }
  
  // בדיקת הרשאות
  const lesson = await Lesson.findById(exercise.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לערוך תרגיל זה", 403));
  }
  
  // ולידציה של תוכן התרגיל אם משנים אותו
  if (req.body.content && req.body.type) {
    if (!validateExerciseContent(req.body.type, req.body.content)) {
      return next(new AppError("תוכן התרגיל לא תואם לסוג התרגיל שנבחר", 400));
    }
  }
  
  // עדכון lastModifiedBy
  req.body.lastModifiedBy = user._id;
  
  const updatedExercise = await LessonExercise.findByIdAndUpdate(
    req.params.id,
    req.body,
    {
      new: true,
      runValidators: true
    }
  );
  
  res.status(200).json({
    status: "success",
    data: {
      exercise: updatedExercise
    }
  });
});

// מחיקת תרגיל
export const deleteExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const exercise = await LessonExercise.findById(req.params.id);
  
  if (!exercise) {
    return next(new AppError("תרגיל לא נמצא", 404));
  }
  
  // בדיקת הרשאות
  const lesson = await Lesson.findById(exercise.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה למחוק תרגיל זה", 403));
  }
  
  await LessonExercise.findByIdAndDelete(req.params.id);
  
  res.status(204).json({
    status: "success",
    data: null
  });
});

// שליחת תשובות לתרגיל
export const submitExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  console.log("[SUBMIT EXERCISE] Starting...".yellow);
  console.log("[SUBMIT EXERCISE] Exercise ID:", req.params.id);
  console.log("[SUBMIT EXERCISE] Request body:", JSON.stringify(req.body, null, 2));
  
  const { responses, timeSpent } = req.body;
  
  const exercise = await LessonExercise.findById(req.params.id);
  if (!exercise) {
    return next(new AppError("תרגיל לא נמצא", 404));
  }
  
  const lesson = await Lesson.findById(exercise.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // בדיקת הרשאות גישה
  const hasAccess = true; // ביטול זמני של בדיקת הרשאות לצורך פיתוח
    // lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
    // (lesson.accessRules.specificUsers && lesson.accessRules.specificUsers.some(userId => userId.toString() === user._id.toString()));
  
  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה לשלוח תשובות לתרגיל זה", 403));
  }
  
  // מציאת התקדמות בתוכנית
  const programProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === lesson.trainingProgramId.toString()
  );
  
  if (!programProgress) {
    return next(new AppError("יש להתחיל את התוכנית לפני שליחת תשובות", 400));
  }
  
  // בדיקה אם כבר יש תשובה לתרגיל
  const existingResponseIndex = programProgress.exerciseResponses.findIndex(
    (resp: any) => resp.lessonId.toString() === exercise.lessonId.toString() && 
            resp.exerciseId === exercise.exerciseId
  );
  
  // חישוב ציון
  const score = calculateScore(exercise, responses);
  
  const exerciseResponse = {
    lessonId: exercise.lessonId,
    exerciseId: exercise.exerciseId,
    completed: true,
    completedAt: new Date(),
    responses,
    timeSpent: timeSpent || 0,
    score
  };
  
  if (existingResponseIndex !== -1) {
    // עדכון תשובה קיימת
    programProgress.exerciseResponses[existingResponseIndex] = exerciseResponse;
  } else {
    // הוספת תשובה חדשה
    programProgress.exerciseResponses.push(exerciseResponse);
    
    // הוספת נקודות רק בפעם הראשונה
    programProgress.earnedPoints += score || 0;
  }
  
  programProgress.lastAccessed = new Date();

  // Load the full user object to use the save method
  const userToSave = await User.findById(user._id);
  if (!userToSave) {
    return next(new AppError("User not found for saving", 404));
  }

  // Find the specific progress object on the retrieved user and update it
  const progressToUpdate = userToSave.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === lesson.trainingProgramId.toString()
  );

  if (progressToUpdate) {
    if (existingResponseIndex !== -1) {
      progressToUpdate.exerciseResponses[existingResponseIndex] = exerciseResponse;
    } else {
      progressToUpdate.exerciseResponses.push(exerciseResponse);
      progressToUpdate.earnedPoints += score || 0;
    }
    progressToUpdate.lastAccessed = new Date();
  } else {
    // This case should ideally not happen if the logic is correct
    // But as a fallback, we can add a new progress object
    if (!userToSave.mentalTrainingProgress) {
      userToSave.mentalTrainingProgress = [];
    }
    userToSave.mentalTrainingProgress.push(programProgress);
  }
  
  await userToSave.save();
  
  res.status(200).json({
    status: "success",
    data: {
      exerciseResponse,
      earnedPoints: programProgress.earnedPoints
    }
  });
});

// יצירת תרגיל שאלון
export const createQuestionnaireExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { lessonId, title, description, settings, content } = req.body;
  
  // ולידציה של תוכן השאלון
  if (!content.questions || !Array.isArray(content.questions) || content.questions.length === 0) {
    return next(new AppError("שאלון חייב להכיל לפחות שאלה אחת", 400));
  }
  
  const exerciseData = {
    lessonId,
    type: "questionnaire",
    title,
    description,
    settings,
    content,
    createdBy: res.app.locals.user._id,
    lastModifiedBy: res.app.locals.user._id
  };
  
  req.body = exerciseData;
  return createExercise(req, res, next);
});

// יצירת תרגיל קלט טקסט
export const createTextInputExercise = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { lessonId, title, description, settings, content } = req.body;
  
  // ולידציה של תוכן הקלט
  if (!content.prompts || !Array.isArray(content.prompts) || content.prompts.length === 0) {
    return next(new AppError("תרגיל קלט טקסט חייב להכיל לפחות הנחיה אחת", 400));
  }
  
  const exerciseData = {
    lessonId,
    type: "text_input",
    title,
    description,
    settings,
    content,
    createdBy: res.app.locals.user._id,
    lastModifiedBy: res.app.locals.user._id
  };
  
  req.body = exerciseData;
  return createExercise(req, res, next);
});

// פונקציות עזר

// ולידציה של תוכן התרגיל
function validateExerciseContent(type: string, content: any): boolean {
  switch (type) {
    case "questionnaire":
      return content && Array.isArray(content.questions) && content.questions.length > 0;
    case "text_input":
      return content && Array.isArray(content.prompts) && content.prompts.length > 0;
    case "video_reflection":
      return content && content.videoUrl && Array.isArray(content.questions);
    case "action_plan":
      return content && Array.isArray(content.sections) && content.sections.length > 0;
    case "mental_visualization":
      return content && Array.isArray(content.steps) && content.steps.length > 0;
    default:
      return false;
  }
}

// חישוב ציון לתרגיל
function calculateScore(exercise: any, responses: any): number {
  let score = 0;
  
  switch (exercise.type) {
    case "questionnaire":
      const content = exercise.content as IQuestionnaireContent;
      content.questions.forEach((question, index) => {
        if (question.questionType === "single_choice" || question.questionType === "multiple_choice") {
          const userAnswer = responses.answers?.[index];
          if (userAnswer && question.options) {
            const correctOptions = question.options.filter(opt => opt.isCorrect);
            const isCorrect = correctOptions.some(opt => opt.optionId === userAnswer.optionId);
            if (isCorrect) {
              score += question.points || exercise.settings.points / content.questions.length;
            }
          }
        } else {
          // לשאלות פתוחות או סקאלה - נותנים את מלוא הניקוד אם ענו
          if (responses.answers?.[index]) {
            score += question.points || exercise.settings.points / content.questions.length;
          }
        }
      });
      break;
      
    case "text_input":
    case "video_reflection":
    case "action_plan":
    case "mental_visualization":
      // לתרגילים אלו נותנים את מלוא הניקוד אם השלימו
      if (responses && Object.keys(responses).length > 0) {
        score = exercise.settings.points;
      }
      break;
  }
  
  return Math.round(score);
}

// קבלת סטטיסטיקות תרגיל
export const getExerciseStats = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const exercise = await LessonExercise.findById(req.params.id);
  
  if (!exercise) {
    return next(new AppError("תרגיל לא נמצא", 404));
  }
  
  // בדיקת הרשאות - רק יוצר התוכנית או מנהל
  const lesson = await Lesson.findById(exercise.lessonId);
  const program = await TrainingProgram.findById(lesson?.trainingProgramId);
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || !program || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לצפות בסטטיסטיקות תרגיל זה", 403));
  }
  
  // חישוב סטטיסטיקות
  const usersWithResponses = await User.find({
    "mentalTrainingProgress.exerciseResponses": {
      $elemMatch: {
        lessonId: exercise.lessonId,
        exerciseId: exercise.exerciseId
      }
    }
  });
  
  let totalResponses = 0;
  let totalScore = 0;
  let totalTimeSpent = 0;
  
  usersWithResponses.forEach(user => {
    user.mentalTrainingProgress?.forEach(progress => {
      progress.exerciseResponses.forEach(response => {
        if (response.lessonId.toString() === exercise.lessonId.toString() && 
            response.exerciseId === exercise.exerciseId) {
          totalResponses++;
          totalScore += response.score || 0;
          totalTimeSpent += response.timeSpent || 0;
        }
      });
    });
  });
  
  res.status(200).json({
    status: "success",
    data: {
      stats: {
        totalResponses,
        averageScore: totalResponses > 0 ? (totalScore / totalResponses).toFixed(2) : 0,
        averageTimeSpent: totalResponses > 0 ? Math.round(totalTimeSpent / totalResponses) : 0,
        completionRate: `${totalResponses} משתמשים השלימו את התרגיל`
      }
    }
  });
}); 