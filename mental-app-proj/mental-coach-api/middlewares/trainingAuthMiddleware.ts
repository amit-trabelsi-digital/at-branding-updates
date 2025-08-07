import { Request, Response, NextFunction } from "express";
import TrainingProgram from "../models/training-program-model";
import Lesson from "../models/lesson-model";
import LessonExercise from "../models/lesson-exercise-model";
import AppError from "../utils/appError";

// בדיקת גישה לתוכנית אימון
export const checkProgramAccess = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = res.app.locals.user;
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }
    
    const programId = req.params.id || req.params.programId;
    if (!programId) {
      return next();
    }
    
    const program = await TrainingProgram.findById(programId);
    if (!program) {
      return next(new AppError("תוכנית אימון לא נמצאה", 404));
    }
    
    // בדיקת הרשאות גישה
    const hasAccess = 
      program.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
      program.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
    
    if (!hasAccess) {
      return next(new AppError("אין לך הרשאה לגשת לתוכנית זו", 403));
    }
    
    // שמירת התוכנית ב-locals לשימוש בהמשך
    res.locals.program = program;
    next();
  } catch (error) {
    next(error);
  }
};

// בדיקת הרשאות יוצר/מנהל לתוכנית
export const checkProgramOwnership = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = res.app.locals.user;
    const userRole = res.app.locals.role;
    
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }
    
    const programId = req.params.id || req.params.programId;
    if (!programId) {
      return next();
    }
    
    const program = res.locals.program || await TrainingProgram.findById(programId);
    if (!program) {
      return next(new AppError("תוכנית אימון לא נמצאה", 404));
    }
    
    // בדיקה שהמשתמש הוא היוצר או מנהל
    if (program.createdBy.toString() !== user._id.toString() && userRole < 3) {
      return next(new AppError("אין לך הרשאה לבצע פעולה זו", 403));
    }
    
    res.locals.program = program;
    next();
  } catch (error) {
    next(error);
  }
};

// בדיקת הרשאות מדריך
export const checkInstructorRole = (req: Request, res: Response, next: NextFunction) => {
  const userRole = res.app.locals.role;
  
  if (!userRole || userRole < 2) { // בהנחה ש-2 זה רמת מדריך
    return next(new AppError("רק מדריכים יכולים לבצע פעולה זו", 403));
  }
  
  next();
};

// בדיקת גישה לשיעור
export const checkLessonAccess = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = res.app.locals.user;
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }
    
    const lessonId = req.params.id || req.params.lessonId;
    if (!lessonId) {
      return next();
    }
    
    const lesson = await Lesson.findById(lessonId);
    if (!lesson) {
      return next(new AppError("שיעור לא נמצא", 404));
    }
    
    // בדיקת הרשאות גישה
    const hasAccess = 
      lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
      lesson.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
    
    if (!hasAccess) {
      return next(new AppError("אין לך הרשאה לגשת לשיעור זה", 403));
    }
    
    // בדיקת תנאי פתיחה
    if (lesson.accessRules.unlockConditions.requirePreviousCompletion) {
      const userProgress = user.mentalTrainingProgress?.find(
        (prog: any) => prog.trainingProgramId.toString() === lesson.trainingProgramId.toString()
      );
      
      if (userProgress) {
        const previousLessons = await Lesson.find({
          trainingProgramId: lesson.trainingProgramId,
          order: { $lt: lesson.order }
        });
        
        for (const prevLesson of previousLessons) {
          const lessonProgress = userProgress.lessonProgress.find(
            (lp: any) => lp.lessonId.toString() === (prevLesson as any)._id.toString()
          );
          
          if (!lessonProgress?.completed) {
            return next(new AppError("יש להשלים את השיעורים הקודמים לפני גישה לשיעור זה", 403));
          }
        }
      }
    }
    
    res.locals.lesson = lesson;
    next();
  } catch (error) {
    next(error);
  }
};

// בדיקת הרשאות לתרגיל
export const checkExerciseAccess = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = res.app.locals.user;
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }
    
    const exerciseId = req.params.id || req.params.exerciseId;
    if (!exerciseId) {
      return next();
    }
    
    const exercise = await LessonExercise.findById(exerciseId);
    if (!exercise) {
      return next(new AppError("תרגיל לא נמצא", 404));
    }
    
    // בדיקת גישה דרך השיעור
    const lesson = await Lesson.findById(exercise.lessonId);
    if (!lesson) {
      return next(new AppError("שיעור לא נמצא", 404));
    }
    
    const hasAccess = 
      lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
      lesson.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
    
    if (!hasAccess) {
      return next(new AppError("אין לך הרשאה לגשת לתרגיל זה", 403));
    }
    
    res.locals.exercise = exercise;
    res.locals.lesson = lesson;
    next();
  } catch (error) {
    next(error);
  }
};

// בדיקת הרשמה לתוכנית
export const checkProgramEnrollment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = res.app.locals.user;
    if (!user) {
      return next(new AppError("משתמש לא נמצא", 404));
    }
    
    const programId = req.params.programId || req.params.id;
    if (!programId) {
      return next();
    }
    
    const programProgress = user.mentalTrainingProgress?.find(
      (prog: any) => prog.trainingProgramId.toString() === programId
    );
    
    if (!programProgress) {
      return next(new AppError("אינך רשום לתוכנית זו", 403));
    }
    
    res.locals.programProgress = programProgress;
    next();
  } catch (error) {
    next(error);
  }
};

// בדיקת מגבלת זמן לתרגיל
export const checkExerciseTimeLimit = (req: Request, res: Response, next: NextFunction) => {
  const exercise = res.locals.exercise;
  const startTime = req.body.startTime;
  
  if (exercise && exercise.settings.timeLimit && startTime) {
    const elapsedTime = (Date.now() - new Date(startTime).getTime()) / 1000; // בשניות
    
    if (elapsedTime > exercise.settings.timeLimit) {
      return next(new AppError("חרגת מזמן המוקצב לתרגיל", 400));
    }
  }
  
  next();
};

// לוגים למעקב אחר פעילות
export const logTrainingActivity = (activityType: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = res.app.locals.user;
    const timestamp = new Date();
    
    console.log(`[Training Activity] ${timestamp.toISOString()} - User: ${user?.email || 'Unknown'} - Activity: ${activityType} - Path: ${req.path}`);
    
    // כאן אפשר להוסיף שמירה למסד נתונים של לוגים אם נרצה
    
    next();
  };
}; 