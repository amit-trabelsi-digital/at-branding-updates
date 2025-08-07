import { Request, Response, NextFunction } from "express";
import mongoose from "mongoose";
import TrainingProgram from "../models/training-program-model";
import Lesson from "../models/lesson-model";
import User from "../models/user-model";
import catchAsync from "../utils/catchAsync";
import AppError from "../utils/appError";
import "colors";

// קבלת כל תוכניות האימון
export const getAllTrainingPrograms = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  console.log(`[CONTROLLER] getAllTrainingPrograms called`.blue);
  console.log(`Query params:`, req.query);
  console.log(`User from locals:`, res.app.locals.user?.email || "No user");
  
  // שליפת התוכניות מהמסד הנתונים
  const programs = await TrainingProgram.find({ isPublished: true })
    .select('-__v')
    .sort({ createdAt: -1 });
  
  console.log(`[CONTROLLER] Found ${programs.length} programs in database`.green);
  
  res.status(200).json({
    status: "success",
    results: programs.length,
    data: {
      programs
    }
  });
});

// קבלת תוכנית ספציפית
export const getTrainingProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  console.log(`[CONTROLLER] getTrainingProgram called for ID: ${req.params.id}`.blue);
  
  // מציאת התוכנית במסד הנתונים
  const program = await TrainingProgram.findById(req.params.id).select('-__v');
  
  if (!program) {
    console.log(`[ERROR] Program not found with ID: ${req.params.id}`.red);
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  console.log(`[CONTROLLER] Found program: ${program.title}`.green);
  
  // בדיקת הרשאות גישה
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  console.log(`[CONTROLLER] User subscription: ${user.subscriptionType}`.yellow);
  console.log(`[CONTROLLER] Program subscription types:`, program.accessRules.subscriptionTypes);
  
  // ביטול זמני של בדיקת הרשאות - כל המשתמשים יכולים לראות את התוכנית
  // const hasAccess = 
  //   program.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   program.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
  
  // TODO: remove this after testing
  const hasAccess = true;
  
  if (!hasAccess) {
    console.log(`[CONTROLLER] Access denied for user: ${user.email}`.red);
    return next(new AppError("אין לך הרשאה לצפות בתוכנית זו", 403));
  }
  
  console.log(`[CONTROLLER] Access granted, returning program`.green);
  
  res.status(200).json({
    status: "success",
    data: {
      program
    }
  });
});

// יצירת תוכנית חדשה
export const createTrainingProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  // רק מדריכים יכולים ליצור תוכניות
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || userRole < 2) { // בהנחה ש-2 זה רמת מדריך
    return next(new AppError("רק מדריכים יכולים ליצור תוכניות אימון", 403));
  }
  
  const programData = {
    ...req.body,
    instructor: user._id,
    createdBy: user._id,
    lastModifiedBy: user._id
  };
  
  const newProgram = await TrainingProgram.create(programData);
  
  res.status(201).json({
    status: "success",
    data: {
      program: newProgram
    }
  });
});

// עדכון תוכנית
export const updateTrainingProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const program = await TrainingProgram.findById(req.params.id);
  
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  // בדיקה שהמשתמש הוא היוצר או מנהל
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לערוך תוכנית זו", 403));
  }
  
  // עדכון lastModifiedBy
  req.body.lastModifiedBy = user._id;
  
  const updatedProgram = await TrainingProgram.findByIdAndUpdate(
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
      program: updatedProgram
    }
  });
});

// מחיקת תוכנית
export const deleteTrainingProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const program = await TrainingProgram.findById(req.params.id);
  
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  // בדיקה שהמשתמש הוא היוצר או מנהל
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה למחוק תוכנית זו", 403));
  }
  
  // בדיקה שאין שיעורים מקושרים
  const lessonsCount = await Lesson.countDocuments({ trainingProgramId: req.params.id });
  if (lessonsCount > 0) {
    return next(new AppError("לא ניתן למחוק תוכנית עם שיעורים. יש למחוק קודם את כל השיעורים", 400));
  }
  
  await TrainingProgram.findByIdAndDelete(req.params.id);
  
  res.status(204).json({
    status: "success",
    data: null
  });
});

// קבלת שיעורי תוכנית
export const getProgramLessons = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  console.log(`[TRAINING CONTROLLER] getProgramLessons called for ID: ${req.params.id}`.blue);
  
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // מציאת התוכנית במסד הנתונים
  const program = await TrainingProgram.findById(req.params.id);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  console.log(`[TRAINING CONTROLLER] Found program: ${program.title}`.green);
  
  // שליפת השיעורים מהמסד הנתונים
  const lessons = await Lesson.find({ trainingProgramId: new mongoose.Types.ObjectId(req.params.id) })
    .sort({ order: 1 })
    .select('-__v'); // מסיר את שדה הגרסה
  
  console.log(`[TRAINING CONTROLLER] Found ${lessons.length} lessons in database`.green);
  
  // בדיקת הרשאות גישה - כעת רק לצורך הצגת הזמינות
  // בתקופת הבדיקות - כל המשתמשים יכולים לגשת
  // const hasAccess = 
  //   program.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
  //   program.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
  
  // TODO: remove this after testing - כרגע כולם מקבלים גישה
  const hasAccess = true;
  
  // החזרת רשימת השיעורים עם כל המידע (למערכת הניהול)
  // במערכת הניהול - מחזירים את כל המידע
  const lessonsFullInfo = lessons.map((lesson: any) => ({
    _id: lesson._id,
    id: lesson._id, // עבור תאימות עם הפרונט
    title: lesson.title,
    shortTitle: lesson.shortTitle,
    description: lesson.description,
    duration: lesson.duration,
    order: lesson.order,
    lessonNumber: lesson.lessonNumber,
    trainingProgramId: lesson.trainingProgramId,
    content: lesson.content,
    media: lesson.media,
    contentStatus: lesson.contentStatus,
    scoring: lesson.scoring,
    accessRules: lesson.accessRules,
    isPublished: lesson.contentStatus?.isPublished || false,
    createdAt: lesson.createdAt,
    updatedAt: lesson.updatedAt,
    createdBy: lesson.createdBy,
    lastModifiedBy: lesson.lastModifiedBy,
    exercises: lesson.exercises || [],
    hasAccess: hasAccess // בתקופת הבדיקות - true לכולם
  }));
  
  console.log(`[TRAINING CONTROLLER] Returning ${lessonsFullInfo.length} lessons full info`.green);
  
  res.status(200).json({
    status: "success",
    results: lessonsFullInfo.length,
    data: {
      lessons: lessonsFullInfo
    }
  });
});

// פרסום/ביטול פרסום תוכנית
export const togglePublishProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const program = await TrainingProgram.findById(req.params.id);
  
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  // בדיקה שהמשתמש הוא היוצר או מנהל
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לשנות סטטוס פרסום של תוכנית זו", 403));
  }
  
  // בדיקה שיש לפחות שיעור אחד לפני פרסום
  if (!program.isPublished) {
    const lessonsCount = await Lesson.countDocuments({ 
      trainingProgramId: req.params.id,
      "contentStatus.isPublished": true
    });
    
    if (lessonsCount === 0) {
      return next(new AppError("לא ניתן לפרסם תוכנית ללא שיעורים מפורסמים", 400));
    }
  }
  
  program.isPublished = !program.isPublished;
  program.lastModifiedBy = user._id;
  await program.save();
  
  res.status(200).json({
    status: "success",
    data: {
      program
    }
  });
});

// קבלת סטטיסטיקות תוכנית
export const getProgramStats = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const program = await TrainingProgram.findById(req.params.id);
  
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  // בדיקה שהמשתמש הוא היוצר או מנהל
  const user = res.app.locals.user;
  const userRole = res.app.locals.role;
  
  if (!user || (program.createdBy.toString() !== user._id.toString() && userRole < 3)) {
    return next(new AppError("אין לך הרשאה לצפות בסטטיסטיקות תוכנית זו", 403));
  }
  
  // חישוב סטטיסטיקות
  const enrolledUsers = await User.countDocuments({
    "mentalTrainingProgress.trainingProgramId": req.params.id
  });
  
  const completedUsers = await User.countDocuments({
    "mentalTrainingProgress": {
      $elemMatch: {
        trainingProgramId: req.params.id,
        completed: true
      }
    }
  });
  
  const totalLessons = await Lesson.countDocuments({ trainingProgramId: req.params.id });
  const publishedLessons = await Lesson.countDocuments({ 
    trainingProgramId: req.params.id,
    "contentStatus.isPublished": true
  });
  
  res.status(200).json({
    status: "success",
    data: {
      stats: {
        enrolledUsers,
        completedUsers,
        completionRate: enrolledUsers > 0 ? (completedUsers / enrolledUsers * 100).toFixed(2) : 0,
        totalLessons,
        publishedLessons,
        publishProgress: totalLessons > 0 ? (publishedLessons / totalLessons * 100).toFixed(2) : 0
      }
    }
  });
}); 