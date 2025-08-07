import { Request, Response, NextFunction } from "express";
import User from "../models/user-model";
import TrainingProgram from "../models/training-program-model";
import Lesson from "../models/lesson-model";
import catchAsync from "../utils/catchAsync";
import AppError from "../utils/appError";
import LessonExercise from "../models/lesson-exercise-model";
import "colors";

// קבלת כל ההתקדמות של המשתמש
export const getUserTrainingProgress = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  // טעינת פרטי התוכניות
  const progressWithDetails = await Promise.all(
    (user.mentalTrainingProgress || []).map(async (progress: any) => {
      const program = await TrainingProgram.findById(progress.trainingProgramId)
        .select("title category difficulty estimatedDuration");
      
      return {
        ...progress.toObject ? progress.toObject() : progress,
        programDetails: program
      };
    })
  );
  
  res.status(200).json({
    status: "success",
    results: progressWithDetails.length,
    data: {
      trainingProgress: progressWithDetails
    }
  });
});

// קבלת התקדמות בתוכנית ספציפית
export const getProgramProgress = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const programProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === req.params.programId
  );
  
  if (!programProgress) {
    return next(new AppError("לא נמצאה התקדמות בתוכנית זו", 404));
  }
  
  // טעינת פרטי התוכנית והשיעורים
  const program = await TrainingProgram.findById(req.params.programId);
  const lessons = await Lesson.find({ trainingProgramId: req.params.programId })
    .select("title shortTitle order duration scoring")
    .sort({ order: 1 });
  
  // מיזוג מידע על השיעורים עם ההתקדמות
  const lessonsWithProgress = lessons.map(lesson => {
    const lessonProgress = programProgress.lessonProgress.find(
      (lp: any) => lp.lessonId.toString() === (lesson as any)._id.toString()
    );
    
    return {
      ...(lesson as any).toObject(),
      progress: lessonProgress || {
        completed: false,
        progressPercentage: 0,
        watchTime: 0
      }
    };
  });
  
  res.status(200).json({
    status: "success",
    data: {
      program,
      programProgress: {
        ...programProgress.toObject ? programProgress.toObject() : programProgress,
        lessons: lessonsWithProgress
      }
    }
  });
});

// הרשמה לתוכנית
export const enrollInProgram = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const program = await TrainingProgram.findById(req.params.programId);
  if (!program) {
    return next(new AppError("תוכנית אימון לא נמצאה", 404));
  }
  
  // בדיקת הרשאות גישה
  const hasAccess = 
    program.accessRules.subscriptionTypes.includes(user.subscriptionType) ||
    program.accessRules.specificUsers.some((userId: any) => userId.toString() === user._id.toString());
  
  if (!hasAccess) {
    return next(new AppError("אין לך הרשאה להירשם לתוכנית זו", 403));
  }
  
  // בדיקה אם כבר רשום
  const existingProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === req.params.programId
  );
  
  if (existingProgress) {
    return next(new AppError("אתה כבר רשום לתוכנית זו", 400));
  }
  
  // יצירת רשומת התקדמות חדשה
  const newProgress = {
    trainingProgramId: program._id,
    enrolledAt: new Date(),
    lessonProgress: [],
    exerciseResponses: [],
    overallProgress: 0,
    totalWatchTime: 0,
    lastAccessed: new Date(),
    completed: false,
    earnedPoints: 0
  };
  
  // הוספה למערך ההתקדמות של המשתמש
  if (!user.mentalTrainingProgress) {
    user.mentalTrainingProgress = [];
  }
  user.mentalTrainingProgress.push(newProgress);
  
  // שמירה במסד הנתונים
  const updatedUser = await User.findByIdAndUpdate(
    user._id,
    { mentalTrainingProgress: user.mentalTrainingProgress },
    { new: true }
  );
  
  res.status(201).json({
    status: "success",
    message: "נרשמת בהצלחה לתוכנית האימון",
    data: {
      programProgress: newProgress
    }
  });
});

// עדכון התקדמות בשיעור (פונקציה כללית)
export const updateLessonProgress = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { progressPercentage, watchTime, userNotes } = req.body;
  
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const lesson = await Lesson.findById(req.params.lessonId);
  if (!lesson) {
    return next(new AppError("שיעור לא נמצא", 404));
  }
  
  // מציאת התקדמות בתוכנית
  const programProgressIndex = user.mentalTrainingProgress?.findIndex(
    (prog: any) => prog.trainingProgramId.toString() === lesson.trainingProgramId.toString()
  );
  
  if (programProgressIndex === -1) {
    return next(new AppError("לא נמצאה הרשמה לתוכנית זו", 404));
  }
  
  const programProgress = user.mentalTrainingProgress[programProgressIndex];
  
  // מציאת או יצירת התקדמות בשיעור
  let lessonProgressIndex = programProgress.lessonProgress.findIndex(
    (lp: any) => lp.lessonId.toString() === req.params.lessonId
  );
  
  if (lessonProgressIndex === -1) {
    // יצירת רשומת התקדמות חדשה לשיעור
    programProgress.lessonProgress.push({
      lessonId: lesson._id,
      startedAt: new Date(),
      watchTime: 0,
      progressPercentage: 0,
      completed: false
    });
    lessonProgressIndex = programProgress.lessonProgress.length - 1;
  }
  
  // עדכון הנתונים
  const lessonProgress = programProgress.lessonProgress[lessonProgressIndex];
  
  if (progressPercentage !== undefined) {
    lessonProgress.progressPercentage = Math.min(100, Math.max(0, progressPercentage));
  }
  
  if (watchTime !== undefined) {
    lessonProgress.watchTime += watchTime;
    programProgress.totalWatchTime += watchTime;
  }
  
  if (userNotes !== undefined) {
    lessonProgress.userNotes = userNotes;
  }
  
  // בדיקה אם השיעור הושלם
  if (lessonProgress.progressPercentage >= 100 && !lessonProgress.completed) {
    lessonProgress.completed = true;
    lessonProgress.completedAt = new Date();
    
    // הוספת נקודות
    programProgress.earnedPoints += lesson.scoring.points;
    
    // חישוב התקדמות כוללת
    const totalLessons = await Lesson.countDocuments({ trainingProgramId: lesson.trainingProgramId });
    const completedLessons = programProgress.lessonProgress.filter((lp: any) => lp.completed).length;
    programProgress.overallProgress = Math.round((completedLessons / totalLessons) * 100);
    
    // בדיקה אם התוכנית הושלמה
    if (programProgress.overallProgress >= 100 && !programProgress.completed) {
      programProgress.completed = true;
      programProgress.completedAt = new Date();
    }
  }
  
  // עדכון זמן גישה אחרון
  programProgress.lastAccessed = new Date();
  programProgress.currentLesson = lesson._id;
  
  // שמירה במסד הנתונים
  await User.findByIdAndUpdate(
    user._id,
    { mentalTrainingProgress: user.mentalTrainingProgress }
  );
  
  res.status(200).json({
    status: "success",
    data: {
      lessonProgress: lessonProgress,
      programProgress: {
        overallProgress: programProgress.overallProgress,
        earnedPoints: programProgress.earnedPoints,
        completed: programProgress.completed
      }
    }
  });
});

// קבלת דוח התקדמות מפורט
export const getDetailedProgressReport = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const report = {
    totalPrograms: user.mentalTrainingProgress?.length || 0,
    completedPrograms: 0,
    activePrograms: 0,
    totalWatchTime: 0,
    totalEarnedPoints: 0,
    programsDetails: [] as any[]
  };
  
  // עיבוד כל תוכנית
  for (const progress of (user.mentalTrainingProgress || [])) {
    const program = await TrainingProgram.findById(progress.trainingProgramId)
      .select("title category difficulty");
    
    const totalLessons = await Lesson.countDocuments({ 
      trainingProgramId: progress.trainingProgramId 
    });
    
    const completedLessons = progress.lessonProgress.filter((lp: any) => lp.completed).length;
    
    const programDetail = {
      program,
      enrolledAt: progress.enrolledAt,
      lastAccessed: progress.lastAccessed,
      overallProgress: progress.overallProgress,
      totalLessons,
      completedLessons,
      totalWatchTime: progress.totalWatchTime,
      earnedPoints: progress.earnedPoints,
      completed: progress.completed,
      completedAt: progress.completedAt
    };
    
    report.programsDetails.push(programDetail);
    
    // עדכון סטטיסטיקות כלליות
    if (progress.completed) {
      report.completedPrograms++;
    } else {
      report.activePrograms++;
    }
    
    report.totalWatchTime += progress.totalWatchTime;
    report.totalEarnedPoints += progress.earnedPoints;
  }
  
  res.status(200).json({
    status: "success",
    data: {
      report
    }
  });
});

// איפוס התקדמות בתוכנית
export const resetProgramProgress = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const programProgressIndex = user.mentalTrainingProgress?.findIndex(
    (prog: any) => prog.trainingProgramId.toString() === req.params.programId
  );
  
  if (programProgressIndex === -1) {
    return next(new AppError("לא נמצאה התקדמות בתוכנית זו", 404));
  }
  
  // איפוס ההתקדמות
  user.mentalTrainingProgress[programProgressIndex] = {
    trainingProgramId: user.mentalTrainingProgress[programProgressIndex].trainingProgramId,
    enrolledAt: user.mentalTrainingProgress[programProgressIndex].enrolledAt,
    lessonProgress: [],
    exerciseResponses: [],
    overallProgress: 0,
    totalWatchTime: 0,
    lastAccessed: new Date(),
    completed: false,
    earnedPoints: 0
  };
  
  // שמירה במסד הנתונים
  await User.findByIdAndUpdate(
    user._id,
    { mentalTrainingProgress: user.mentalTrainingProgress }
  );
  
  res.status(200).json({
    status: "success",
    message: "ההתקדמות בתוכנית אופסה בהצלחה",
    data: {
      programProgress: user.mentalTrainingProgress[programProgressIndex]
    }
  });
});

// קבלת השיעור הבא להמשך
export const getNextLesson = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = res.app.locals.user;
  if (!user) {
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  const programProgress = user.mentalTrainingProgress?.find(
    (prog: any) => prog.trainingProgramId.toString() === req.params.programId
  );
  
  if (!programProgress) {
    return next(new AppError("לא נמצאה התקדמות בתוכנית זו", 404));
  }
  
  // מציאת כל השיעורים בתוכנית
  const lessons = await Lesson.find({ trainingProgramId: req.params.programId })
    .sort({ order: 1 });
  
  // מציאת השיעור הבא שלא הושלם
  let nextLesson: any = null;
  
  for (const lesson of lessons) {
    const lessonProgress = programProgress.lessonProgress.find(
      (lp: any) => lp.lessonId.toString() === (lesson as any)._id.toString()
    );
    
    if (!lessonProgress || !lessonProgress.completed) {
      nextLesson = lesson;
      break;
    }
  }
  
  if (!nextLesson) {
    return res.status(200).json({
      status: "success",
      message: "כל השיעורים בתוכנית הושלמו",
      data: {
        nextLesson: null,
        programCompleted: true
      }
    });
  }
  
  res.status(200).json({
    status: "success",
    data: {
      nextLesson,
      programCompleted: false
    }
  });
}); 

// קבלת כל התשובות של המשתמש לתרגילים
export const getUserExerciseResponses = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  console.log("[GET USER EXERCISE RESPONSES] Starting...".yellow);
  
  const user = res.app.locals.user;
  console.log("[GET USER EXERCISE RESPONSES] User:", user?.email, user?._id);
  
  if (!user) {
    console.log("[GET USER EXERCISE RESPONSES] User not found!".red);
    return next(new AppError("משתמש לא נמצא", 404));
  }
  
  console.log("[GET USER EXERCISE RESPONSES] Mental Training Progress:", user.mentalTrainingProgress?.length || 0);
  
  // איסוף כל התשובות מכל התוכניות
  const allResponses = [];
  
  try {
    for (const progress of (user.mentalTrainingProgress || [])) {
      console.log("[GET USER EXERCISE RESPONSES] Processing program:", progress.trainingProgramId);
      console.log("[GET USER EXERCISE RESPONSES] Exercise responses in program:", progress.exerciseResponses?.length || 0);
      
      if (!progress.exerciseResponses || progress.exerciseResponses.length === 0) {
        continue;
      }
      
      const program = await TrainingProgram.findById(progress.trainingProgramId)
        .select("title category");
      
      for (const response of progress.exerciseResponses) {
        console.log("[GET USER EXERCISE RESPONSES] Processing response:", JSON.stringify(response, null, 2));
        
        try {
          // טעינת פרטי השיעור והתרגיל
          const lesson = await Lesson.findById(response.lessonId)
            .select("title shortTitle lessonNumber");
          
          const exercise = await LessonExercise.findOne({ exerciseId: response.exerciseId })
            .select("title description type content");
          
          console.log("[GET USER EXERCISE RESPONSES] Looking for exercise:", response.exerciseId);
          console.log("[GET USER EXERCISE RESPONSES] Found exercise:", exercise?._id);
          
          if (lesson && exercise) {
            allResponses.push({
              programTitle: program?.title || "תוכנית לא ידועה",
              programCategory: program?.category || "",
              lessonTitle: lesson.title,
              lessonNumber: lesson.lessonNumber,
              exerciseTitle: exercise.title,
              exerciseType: exercise.type,
              exerciseContent: exercise.content,
              responses: response.responses,
              completedAt: response.completedAt,
              score: response.score,
              timeSpent: response.timeSpent
            });
          }
        } catch (innerError) {
          console.log("[GET USER EXERCISE RESPONSES] Error processing individual response:", innerError);
          // ממשיכים לתשובה הבאה
        }
      }
    }
  } catch (error) {
    console.log("[GET USER EXERCISE RESPONSES] Error in main loop:", error);
  }
  
  console.log("[GET USER EXERCISE RESPONSES] Total responses found:", allResponses.length);
  
  // מיון לפי תאריך השלמה
  allResponses.sort((a, b) => 
    new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
  );
  
  res.status(200).json({
    status: "success",
    results: allResponses.length,
    data: {
      responses: allResponses
    }
  });
}); 