import { Request, Response, NextFunction } from "express";
import Lesson from "../models/lesson-model";
import TrainingProgram from "../models/training-program-model";
import LessonExercise from "../models/lesson-exercise-model";
import User from "../models/user-model";
import catchAsync from "../utils/catchAsync";
import AppError from "../utils/appError";
import { TRAINING_PROGRAM_DATA } from "../data/training-program-data";
import mongoose from "mongoose";

// קבלת כל השיעורים (עם query params)
export const getAllLessons = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { trainingProgramId } = req.query;
  
  console.log(`[LESSONS CONTROLLER] getAllLessons called with trainingProgramId: ${trainingProgramId}`.green);
  
  if (!trainingProgramId) {
    return next(new AppError("חסר מזהה תוכנית אימון", 400));
  }
  
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // מציאת התוכנית בנתונים הרדקודים
  const program = TRAINING_PROGRAM_DATA.data.programs.find((p: any) => p._id === trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  console.log(`[LESSONS CONTROLLER] Found program: ${program.title}`.green);
  
  // בדיקת הרשאות גישה לתוכנית
  // const hasAccess = 
  //   program.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   program.accessRules.specificUsers.some((userId: any) => userId === user._id.toString());

        // TODO: remove this after testing
  const hasAccess = true;
  
  if (!hasAccess) {
    console.log(`[LESSONS CONTROLLER] Access denied for user: ${user.email}, subscription: ${user.subscriptionType}`.red);
    return next(new AppError("אין לך הרשאה לצפות בתוכנית זו", 403));
  }
  
  // החזרת השיעורים
  const lessons = program.lessons.sort((a: any, b: any) => a.order - b.order);
  
  console.log(`[LESSONS CONTROLLER] Returning ${lessons.length} lessons`.green);
  
  res.status(200).json({
    status: "success",
    results: lessons.length,
    data: {
      lessons
    }
  });
});

// קבלת שיעור ספציפי
export const getLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const lesson = await Lesson.findById(req.params.id)
    .populate("trainingProgramId", "title category")
    .populate("exercises");
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // בדיקת הרשאות גישה
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // בדיקת גישה לשיעור
  // const hasAccess = 
  //   lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   lesson.accessRules.specificUsers.some(userId => userId.toString() === user._id.toString());
  
    // TODO: remove this after testing
  const hasAccess = true;

  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה לצפות בשיעור זה", 403));
  }
  
  // בדיקת תנאי פתיחה
  if (lesson.accessRules.unlockConditions.requirePreviousCompletion) {
    // בדיקה אם המשתמש השלים את השיעורים הקודמים
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
          (lp: any) => lp.lessonId.toString() === (prevLesson._id as any).toString()
        );
        
        if (!lessonProgress?.completed) {
          return next(new AppError("יש להשלים את השיעורים הקודמים לפני צפייה בשיעור זה", 403));
        }
      }
    }
  }
  
  res.status(200).json({
    status: "success",
    data: {
      lesson
    }
  });
});

// יצירת שיעור חדש
export const createLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  // בדיקת הרשאות - רק יוצר התוכנית או מנהל
  const program = await TrainingProgram.findById(req.body.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה להוסיף שיעורים לתוכנית זו", 403));
  }
  
  // חישוב מספר השיעור הבא
  const lessonsCount = await Lesson.countDocuments({ trainingProgramId: req.body.trainingProgramId });
  
  const lessonData = {
    ...req.body,
    lessonNumber: lessonsCount,
    order: req.body.order || lessonsCount,
    createdBy: user._id,
    lastModifiedBy: user._id
  };
  
  const newLesson = await Lesson.create(lessonData);
  
  // עדכון מספר השיעורים בתוכנית
  program.totalLessons = lessonsCount + 1;
  await program.save();
  
  res.status(201).json({
    status: "success",
    data: {
      lesson: newLesson
    }
  });
});

// עדכון שיעור
export const updateLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const lesson = await Lesson.findById(req.params.id);
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // בדיקת הרשאות
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לערוך שיעור זה", 403));
  }
  
  // עדכון lastModifiedBy
  req.body.lastModifiedBy = user._id;
  
  const updatedLesson = await Lesson.findByIdAndUpdate(
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
      lesson: updatedLesson
    }
  });
});

// מחיקת שיעור
export const deleteLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const lesson = await Lesson.findById(req.params.id);
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // בדיקת הרשאות
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה למחוק שיעור זה", 403));
  }
  
  // בדיקה שאין תרגילים מקושרים
  const exercisesCount = await LessonExercise.countDocuments({ lessonId: req.params.id });
  if (exercisesCount > 0) {
    return next(new AppError("לא ניתן למחוק שיעור עם תרגילים. יש למחוק קודם את כל התרגילים", 400));
  }
  
  await Lesson.findByIdAndDelete(req.params.id);
  
  // עדכון מספר השיעורים בתוכנית
  const remainingLessons = await Lesson.countDocuments({ trainingProgramId: lesson.trainingProgramId });
  program.totalLessons = remainingLessons;
  await program.save();
  
  res.status(204).json({
    status: "success",
    data: null
  });
});

// קבלת תרגילי שיעור
export const getLessonExercises = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const lesson = await Lesson.findById(req.params.id);
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // בדיקת הרשאות גישה
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // const hasAccess = 
  //   lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   lesson.accessRules.specificUsers.some(userId => userId.toString() === user._id.toString());

    // TODO: remove this after testing
  const hasAccess = true;
  
  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה לצפות בתרגילי שיעור זה", 403));
  }
  
  const exercises = await LessonExercise.find({ lessonId: req.params.id })
    .sort({ "settings.order": 1 });
  
  res.status(200).json({
    status: "success",
    results: exercises.length,
    data: {
      exercises
    }
  });
});

// התחלת שיעור למשתמש
export const startLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  // בדיקה שה-body לא null או ריק
  if (!req.body) {
    req.body = {};
  }
  
  const lesson = await Lesson.findById(req.params.id);
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const userFromLocals = res.app.locals.user;
  if (!userFromLocals) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // טעינת המשתמש המלא מהמסד נתונים
  const user = await User.findById(userFromLocals._id);
  if (!user) {
    return next(new AppError("משתמש לא נמצא במסד הנתונים", 404));
  }
  
  // בדיקת הרשאות גישה
  // const hasAccess = 
  //   lesson.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   lesson.accessRules.specificUsers.some(userId => userId.toString() === user._id.toString());

    // TODO: remove this after testing
  const hasAccess = true;
  
  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה להתחיל שיעור זה", 403));
  }
  
  // מציאת או יצירת התקדמות בתוכנית
  let programProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === (lesson.trainingProgramId as any).toString()
  );
  
  if (!programProgress) {
    // הרשמה אוטומטית לתוכנית
    const newProgress = {
      trainingProgramId: lesson.trainingProgramId as any,
      enrolledAt: new Date(),
      lessonProgress: [],
      exerciseResponses: [],
      overallProgress: 0,
      totalWatchTime: 0,
      lastAccessed: new Date(),
      completed: false,
      earnedPoints: 0
    };
    
    user.mentalTrainingProgress = user.mentalTrainingProgress || [];
    user.mentalTrainingProgress.push(newProgress);
    programProgress = user.mentalTrainingProgress[user.mentalTrainingProgress.length - 1];
  }
  
  // בדיקה אם השיעור כבר התחיל
  let lessonProgress = programProgress.lessonProgress.find(
    (lp: any) => lp.lessonId.toString() === req.params.id
  );
  
  if (!lessonProgress) {
    // יצירת רשומת התקדמות חדשה לשיעור
    programProgress.lessonProgress.push({
      lessonId: lesson._id as mongoose.Types.ObjectId,
      startedAt: new Date(),
      watchTime: 0,
      progressPercentage: 0,
      completed: false
    });
    
    // עדכון שיעור נוכחי
    programProgress.currentLesson = lesson._id as mongoose.Types.ObjectId;
    programProgress.lastAccessed = new Date();
    
    await user.save();
  }
  
  res.status(200).json({
    status: "success",
    message: "השיעור התחיל בהצלחה",
    data: {
      lessonProgress: programProgress.lessonProgress.find(
        (lp: any) => lp.lessonId.toString() === req.params.id
      )
    }
  });
});

// עדכון התקדמות בשיעור
export const updateLessonProgress = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { watchTime, progressPercentage, userNotes, completed } = req.body;
  
  const lesson = await Lesson.findById(req.params.id);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  const userFromLocals = res.app.locals.user;
  if (!userFromLocals) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // טעינת המשתמש המלא מהמסד נתונים
  const user = await User.findById(userFromLocals._id);
  if (!user) {
    return next(new AppError("משתמש לא נמצא במסד הנתונים", 404));
  }
  
  // מציאת התקדמות בתוכנית
  const programProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === (lesson.trainingProgramId as any).toString()
  );
  
  if (!programProgress) {
    return next(new AppError("לא נמצאה התקדמות בתוכנית זו", 404));
  }
  
  // מציאת התקדמות בשיעור
  const lessonProgressIndex = programProgress.lessonProgress.findIndex(
    (lp: any) => lp.lessonId.toString() === req.params.id
  );
  
  if (lessonProgressIndex === -1) {
    return next(new AppError("יש להתחיל את השיעור לפני עדכון ההתקדמות", 400));
  }
  
  // עדכון ההתקדמות
  if (watchTime !== undefined) {
    programProgress.lessonProgress[lessonProgressIndex].watchTime = watchTime;
    programProgress.totalWatchTime += watchTime;
  }
  
  if (progressPercentage !== undefined) {
    programProgress.lessonProgress[lessonProgressIndex].progressPercentage = progressPercentage;
  }
  
  if (userNotes !== undefined) {
    programProgress.lessonProgress[lessonProgressIndex].userNotes = userNotes;
  }
  
  if (completed === true && !programProgress.lessonProgress[lessonProgressIndex].completed) {
    programProgress.lessonProgress[lessonProgressIndex].completed = true;
    programProgress.lessonProgress[lessonProgressIndex].completedAt = new Date();
    
    // הוספת נקודות
    programProgress.earnedPoints += lesson.scoring.points;
    
    // חישוב התקדמות כוללת
    const totalLessons = await Lesson.countDocuments({ trainingProgramId: lesson.trainingProgramId });
    const completedLessons = programProgress.lessonProgress.filter((lp: any) => lp.completed).length;
    programProgress.overallProgress = Math.round((completedLessons / totalLessons) * 100);
    
    // בדיקה אם התוכנית הושלמה
    if (programProgress.overallProgress === 100) {
      programProgress.completed = true;
      programProgress.completedAt = new Date();
    }
  }
  
  programProgress.lastAccessed = new Date();
  await user.save();
  
  res.status(200).json({
    status: "success",
    data: {
      lessonProgress: programProgress.lessonProgress[lessonProgressIndex],
      overallProgress: programProgress.overallProgress,
      earnedPoints: programProgress.earnedPoints
    }
  });
});

// פרסום/ביטול פרסום שיעור
export const togglePublishLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const lesson = await Lesson.findById(req.params.id);
  
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // בדיקת הרשאות
  const program = await TrainingProgram.findById(lesson.trainingProgramId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לשנות סטטוס פרסום של שיעור זה", 403));
  }
  
  // בדיקה שיש תוכן לפני פרסום
  if (!lesson.contentStatus.isPublished && !lesson.contentStatus.hasContent) {
    return next(new AppError("לא ניתן לפרסם שיעור ללא תוכן", 400));
  }
  
  lesson.contentStatus.isPublished = !lesson.contentStatus.isPublished;
  lesson.lastModifiedBy = user._id;
  await lesson.save();
  
  res.status(200).json({
    status: "success",
    data: {
      lesson
    }
  });
});

// עדכון סדר השיעורים
export const updateLessonsOrder = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { programId, lessonsOrder } = req.body;
  
  if (!programId || !lessonsOrder || !Array.isArray(lessonsOrder)) {
    return next(new AppError("נתונים חסרים או לא תקינים", 400));
  }
  
  // בדיקת הרשאות
  const program = await TrainingProgram.findById(programId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לערוך סדר השיעורים", 403));
  }
  
  // עדכון סדר השיעורים
  const updatePromises = lessonsOrder.map((lessonOrder: { lessonId: string, order: number }) => {
    return Lesson.findByIdAndUpdate(
      lessonOrder.lessonId,
      { 
        order: lessonOrder.order,
        lastModifiedBy: user._id
      },
      { new: true }
    );
  });
  
  try {
    const updatedLessons = await Promise.all(updatePromises);
    
    res.status(200).json({
      status: "success",
      message: "סדר השיעורים עודכן בהצלחה",
      data: {
        lessons: updatedLessons
      }
    });
  } catch (error) {
    return next(new AppError("שגיאה בעדכון סדר השיעורים", 500));
  }
}); 