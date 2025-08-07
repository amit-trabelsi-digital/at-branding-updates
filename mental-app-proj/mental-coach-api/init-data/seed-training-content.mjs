#!/usr/bin/env node

import mongoose from "mongoose";
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import inquirer from "inquirer";

// הגדרת __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// טעינת משתני סביבה
dotenv.config({ path: join(__dirname, "../.env") });

// חיבור למסד נתונים - שימוש באותם משתנים כמו השרת
const MONGO_URI = process.env.MONGO_URI_DEV || "mongodb://localhost:27017/";
const DB_NAME = process.env.DB_NAME || "dev";

// ייבוא המודלים
const TrainingProgram = mongoose.model("TrainingProgram", new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  category: { type: String, enum: ["mental", "technical", "tactical", "physical"], required: true },
  difficulty: { type: String, enum: ["beginner", "intermediate", "advanced"], required: true },
  estimatedDuration: Number,
  objectives: [String],
  prerequisites: [String],
  targetAudience: String,
  instructor: {
    name: String,
    title: String,
    bio: String,
    imageUrl: String
  },
  accessRules: {
    subscriptionTypes: [String],
    specificUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }]
  },
  totalLessons: { type: Number, default: 0 },
  totalEnrolled: { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
  isPublished: { type: Boolean, default: false },
  publishedAt: Date,
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  lastModifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
}, { timestamps: true }));

const Lesson = mongoose.model("Lesson", new mongoose.Schema({
  trainingProgramId: { type: mongoose.Schema.Types.ObjectId, ref: "TrainingProgram", required: true },
  lessonNumber: Number,
  title: { type: String, required: true },
  shortTitle: String,
  description: String,
  duration: Number,
  order: { type: Number, required: true },
  content: {
    type: { type: String, enum: ["video", "audio", "document", "mixed"], required: true },
    data: mongoose.Schema.Types.Mixed
  },
  exercises: [{ type: mongoose.Schema.Types.ObjectId, ref: "LessonExercise" }],
  accessRules: {
    subscriptionTypes: [String],
    specificUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    unlockConditions: {
      requirePreviousCompletion: { type: Boolean, default: false },
      minimumProgress: { type: Number, default: 0 }
    }
  },
  contentStatus: {
    hasContent: { type: Boolean, default: true },
    isPublished: { type: Boolean, default: false }
  },
  scoring: {
    points: { type: Number, default: 100 },
    passingScore: { type: Number, default: 80 }
  },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  lastModifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
}, { timestamps: true }));

const LessonExercise = mongoose.model("LessonExercise", new mongoose.Schema({
  lessonId: { type: mongoose.Schema.Types.ObjectId, ref: "Lesson", required: true },
  exerciseId: { type: String, required: true, unique: true },
  type: {
    type: String,
    enum: ["questionnaire", "text_input", "video_reflection", "action_plan", "mental_visualization"],
    required: true
  },
  title: { type: String, required: true },
  description: String,
  instructions: String,
  settings: {
    order: { type: Number, default: 0 },
    mandatory: { type: Boolean, default: false },
    points: { type: Number, default: 0 },
    timeLimit: Number,
    allowRetake: { type: Boolean, default: true },
    showCorrectAnswers: { type: Boolean, default: false }
  },
  content: mongoose.Schema.Types.Mixed,
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  lastModifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
}, { timestamps: true }));

const User = mongoose.model("User", new mongoose.Schema({
  email: String,
  uid: String
}));

async function seedTrainingContent() {
  try {
    // חיבור למסד נתונים
    await mongoose.connect(MONGO_URI, { dbName: DB_NAME });
    console.log("✅ מחובר למסד נתונים");

    // מציאת משתמש מנהל (או יצירת משתמש דמה)
    let adminUser = await User.findOne({ email: "amit@trabelsi.me" });
    if (!adminUser) {
      console.log("❌ לא נמצא משתמש מנהל. יוצר משתמש דמה...");
      adminUser = await User.create({
        email: "admin@mentalcoach.com",
        uid: "admin123"
      });
    }

    console.log(`👤 משתמש מנהל: ${adminUser.email}`);

    // יצירת תוכנית אימון מנטלי
    const program = await TrainingProgram.create({
      title: "אימון מנטלי לכדורגלנים צעירים",
      description: "תוכנית מקיפה לפיתוח כישורים מנטליים חיוניים לכדורגלנים. התוכנית כוללת טכניקות להתמודדות עם לחץ, בניית ביטחון עצמי, שיפור ריכוז וחשיבה חיובית.",
      category: "mental",
      difficulty: "beginner",
      estimatedDuration: 120, // דקות
      objectives: [
        "פיתוח חוסן מנטלי להתמודדות עם לחץ במשחקים",
        "בניית ביטחון עצמי ואמונה ביכולות האישיות",
        "שיפור הריכוז והפוקוס במהלך המשחק",
        "למידת טכניקות ויזואליזציה להצלחה",
        "פיתוח חשיבה חיובית וגישה מנצחת"
      ],
      prerequisites: [],
      targetAudience: "כדורגלנים בגילאי 12-18",
      instructor: {
        name: "ד״ר יוסי כהן",
        title: "פסיכולוג ספורט מוסמך",
        bio: "בעל ניסיון של 15 שנה בעבודה עם ספורטאים מקצועיים. עבד עם נבחרות ישראל בכדורגל ועם קבוצות מהליגה הלאומית.",
        imageUrl: "https://example.com/instructor.jpg"
      },
      accessRules: {
        subscriptionTypes: ["basic", "advanced", "premium"],
        specificUsers: []
      },
      totalLessons: 5,
      isPublished: true,
      publishedAt: new Date(),
      createdBy: adminUser._id,
      lastModifiedBy: adminUser._id
    });

    console.log(`✅ נוצרה תוכנית: ${program.title}`);

    // יצירת שיעורים
    const lessons = [
      {
        title: "מבוא לאימון מנטלי בכדורגל",
        shortTitle: "מבוא",
        description: "הכרת עולם האימון המנטלי והחשיבות שלו בכדורגל המודרני",
        duration: 20,
        order: 1,
        content: {
          type: "video",
          data: {
            videoUrl: "https://example.com/lesson1.mp4",
            thumbnailUrl: "https://example.com/thumb1.jpg",
            duration: 1200, // 20 דקות בשניות
            transcript: "ברוכים הבאים לקורס האימון המנטלי לכדורגלנים צעירים..."
          }
        }
      },
      {
        title: "ניהול לחץ ומתח במשחקים",
        shortTitle: "ניהול לחץ",
        description: "טכניקות מעשיות להתמודדות עם לחץ לפני ובמהלך משחקים חשובים",
        duration: 25,
        order: 2,
        content: {
          type: "video",
          data: {
            videoUrl: "https://example.com/lesson2.mp4",
            thumbnailUrl: "https://example.com/thumb2.jpg",
            duration: 1500,
            additionalResources: [
              {
                title: "מדריך תרגילי נשימה",
                type: "pdf",
                url: "https://example.com/breathing.pdf"
              }
            ]
          }
        }
      },
      {
        title: "בניית ביטחון עצמי",
        shortTitle: "ביטחון עצמי",
        description: "פיתוח ביטחון עצמי ואמונה ביכולות האישיות שלך כשחקן",
        duration: 30,
        order: 3,
        content: {
          type: "mixed",
          data: {
            videoUrl: "https://example.com/lesson3.mp4",
            duration: 1800,
            documents: [
              {
                title: "יומן ביטחון עצמי",
                type: "pdf",
                url: "https://example.com/confidence-journal.pdf"
              }
            ]
          }
        }
      },
      {
        title: "טכניקות ויזואליזציה",
        shortTitle: "ויזואליזציה",
        description: "למידה ותרגול של טכניקות ויזואליזציה להצלחה במגרש",
        duration: 25,
        order: 4,
        content: {
          type: "audio",
          data: {
            audioUrl: "https://example.com/visualization.mp3",
            duration: 1500,
            transcript: "תרגיל ויזואליזציה מודרך..."
          }
        }
      },
      {
        title: "חשיבה חיובית וגישה מנצחת",
        shortTitle: "חשיבה חיובית",
        description: "פיתוח גישה מנטלית חיובית ומנצחת",
        duration: 20,
        order: 5,
        content: {
          type: "video",
          data: {
            videoUrl: "https://example.com/lesson5.mp4",
            thumbnailUrl: "https://example.com/thumb5.jpg",
            duration: 1200
          }
        }
      }
    ];

    const createdLessons = [];
    for (const lessonData of lessons) {
      const lesson = await Lesson.create({
        ...lessonData,
        trainingProgramId: program._id,
        lessonNumber: lessonData.order - 1,
        accessRules: {
          subscriptionTypes: ["basic", "advanced", "premium"],
          specificUsers: [],
          unlockConditions: {
            requirePreviousCompletion: lessonData.order > 1,
            minimumProgress: 0
          }
        },
        contentStatus: {
          hasContent: true,
          isPublished: true
        },
        scoring: {
          points: 100,
          passingScore: 80
        },
        createdBy: adminUser._id,
        lastModifiedBy: adminUser._id
      });
      
      createdLessons.push(lesson);
      console.log(`✅ נוצר שיעור: ${lesson.title}`);
    }

    // יצירת תרגילים לשיעורים
    const exercises = [
      // תרגילים לשיעור 1 - מבוא
      {
        lessonIndex: 0,
        exercises: [
          {
            type: "questionnaire",
            title: "בחן את הידע שלך - אימון מנטלי",
            description: "ענה על השאלות הבאות כדי לבדוק את הבנתך",
            content: {
              questions: [
                {
                  questionId: "q1",
                  questionText: "מהו אימון מנטלי בהקשר של כדורגל?",
                  questionType: "single_choice",
                  options: [
                    { optionId: "a", text: "אימון פיזי אינטנסיבי", isCorrect: false },
                    { optionId: "b", text: "פיתוח כישורים נפשיים ומנטליים", isCorrect: true },
                    { optionId: "c", text: "לימוד טקטיקה בלבד", isCorrect: false },
                    { optionId: "d", text: "צפייה במשחקים", isCorrect: false }
                  ],
                  points: 20,
                  required: true
                },
                {
                  questionId: "q2",
                  questionText: "אילו יתרונות יש לאימון מנטלי?",
                  questionType: "multiple_choice",
                  options: [
                    { optionId: "a", text: "שיפור הביצועים בלחץ", isCorrect: true },
                    { optionId: "b", text: "הגברת הביטחון העצמי", isCorrect: true },
                    { optionId: "c", text: "שיפור מהירות הריצה", isCorrect: false },
                    { optionId: "d", text: "שיפור הריכוז", isCorrect: true }
                  ],
                  points: 30,
                  required: true
                }
              ]
            }
          }
        ]
      },
      // תרגילים לשיעור 2 - ניהול לחץ
      {
        lessonIndex: 1,
        exercises: [
          {
            type: "text_input",
            title: "זיהוי מצבי לחץ אישיים",
            description: "תאר מצבים בהם אתה חש לחץ במשחק",
            content: {
              prompts: [
                {
                  promptId: "p1",
                  text: "תאר מצב במשחק האחרון שבו הרגשת לחץ. מה גרם ללחץ?",
                  maxLength: 500,
                  required: true
                },
                {
                  promptId: "p2",
                  text: "איך הלחץ השפיע על הביצועים שלך?",
                  maxLength: 300,
                  required: true
                },
                {
                  promptId: "p3",
                  text: "מה היית עושה אחרת כדי להתמודד עם הלחץ?",
                  maxLength: 400,
                  required: false
                }
              ]
            }
          },
          {
            type: "action_plan",
            title: "תוכנית אישית לניהול לחץ",
            description: "בנה תוכנית אישית להתמודדות עם לחץ",
            content: {
              sections: [
                {
                  sectionId: "triggers",
                  title: "זיהוי טריגרים ללחץ",
                  prompts: [
                    "רשום 3 מצבים שגורמים לך ללחץ במשחק",
                    "מה הסימנים הפיזיים שאתה חש בלחץ?"
                  ]
                },
                {
                  sectionId: "techniques",
                  title: "טכניקות התמודדות",
                  prompts: [
                    "בחר 2 טכניקות נשימה שתתרגל",
                    "מתי תתרגל אותן?"
                  ]
                }
              ]
            }
          }
        ]
      },
      // תרגילים לשיעור 3 - ביטחון עצמי
      {
        lessonIndex: 2,
        exercises: [
          {
            type: "video_reflection",
            title: "ניתוח ביצועים אישיים",
            description: "צפה בסרטון של עצמך משחק ונתח את הביצועים",
            content: {
              videoUrl: "https://example.com/upload-your-video",
              questions: [
                {
                  questionId: "vq1",
                  text: "מה היו הרגעים החזקים שלך במשחק?",
                  type: "text"
                },
                {
                  questionId: "vq2",
                  text: "באילו רגעים הפגנת ביטחון עצמי?",
                  type: "text"
                },
                {
                  questionId: "vq3",
                  text: "מה תעשה כדי לחזק את הביטחון העצמי שלך?",
                  type: "text"
                }
              ],
              allowVideoUpload: true
            }
          }
        ]
      },
      // תרגילים לשיעור 4 - ויזואליזציה
      {
        lessonIndex: 3,
        exercises: [
          {
            type: "mental_visualization",
            title: "תרגיל ויזואליזציה - פנדל מנצח",
            description: "תרגל ויזואליזציה של ביצוע פנדל מוצלח",
            content: {
              steps: [
                {
                  stepId: "s1",
                  title: "הכנה",
                  description: "מצא מקום שקט, שב בנוחות וסגור את העיניים",
                  duration: 60
                },
                {
                  stepId: "s2",
                  title: "דמיין את המגרש",
                  description: "דמיין את עצמך עומד בנקודת הפנדל, תחוש את הדשא מתחת לרגליים",
                  duration: 120
                },
                {
                  stepId: "s3",
                  title: "ביצוע הבעיטה",
                  description: "דמיין את עצמך רץ לכדור, בועט בדיוק ורואה את הכדור נכנס לשער",
                  duration: 180
                }
              ],
              audioGuidance: "https://example.com/visualization-audio.mp3",
              reflectionPrompts: [
                "איך הרגשת במהלך התרגיל?",
                "כמה ברור היה הדימוי המנטלי?"
              ]
            }
          }
        ]
      },
      // תרגילים לשיעור 5 - חשיבה חיובית
      {
        lessonIndex: 4,
        exercises: [
          {
            type: "questionnaire",
            title: "הערכת חשיבה חיובית",
            description: "בדוק את רמת החשיבה החיובית שלך",
            content: {
              questions: [
                {
                  questionId: "pq1",
                  questionText: "כשאני מפספס הזדמנות להבקיע, אני...",
                  questionType: "scale",
                  scaleMin: 1,
                  scaleMax: 5,
                  scaleLabels: {
                    "1": "מתייאש לגמרי",
                    "5": "מתמקד בהזדמנות הבאה"
                  },
                  points: 20,
                  required: true
                },
                {
                  questionId: "pq2",
                  questionText: "לפני משחק חשוב אני חושב בעיקר על...",
                  questionType: "single_choice",
                  options: [
                    { optionId: "a", text: "מה יקרה אם אכשל", isCorrect: false },
                    { optionId: "b", text: "איך אצליח ואתרום לקבוצה", isCorrect: true },
                    { optionId: "c", text: "שלא אעשה טעויות", isCorrect: false }
                  ],
                  points: 30,
                  required: true
                }
              ]
            }
          },
          {
            type: "text_input",
            title: "יומן חשיבה חיובית",
            description: "התחל לנהל יומן חשיבה חיובית",
            content: {
              prompts: [
                {
                  promptId: "jp1",
                  text: "רשום 3 דברים חיוביים שקרו לך היום באימון/משחק",
                  maxLength: 500,
                  required: true
                },
                {
                  promptId: "jp2",
                  text: "איזו מחשבה חיובית תיקח איתך למשחק הבא?",
                  maxLength: 200,
                  required: true
                }
              ]
            }
          }
        ]
      }
    ];

    // יצירת התרגילים
    let exerciseCounter = 1;
    for (const lessonExercises of exercises) {
      const lesson = createdLessons[lessonExercises.lessonIndex];
      
      for (const exerciseData of lessonExercises.exercises) {
        const exercise = await LessonExercise.create({
          lessonId: lesson._id,
          exerciseId: `exercise_${exerciseCounter}`,
          type: exerciseData.type,
          title: exerciseData.title,
          description: exerciseData.description,
          instructions: "השלם את התרגיל בקצב שלך. קח את הזמן לחשוב על התשובות.",
          settings: {
            order: exerciseCounter,
            mandatory: exerciseCounter === 1, // רק התרגיל הראשון חובה
            points: 50,
            timeLimit: exerciseData.type === "questionnaire" ? 600 : null, // 10 דקות לשאלון
            allowRetake: true,
            showCorrectAnswers: exerciseData.type === "questionnaire"
          },
          content: exerciseData.content,
          createdBy: adminUser._id,
          lastModifiedBy: adminUser._id
        });
        
        console.log(`✅ נוצר תרגיל: ${exercise.title} (${exercise.type})`);
        exerciseCounter++;
      }
    }

    console.log("\n🎉 התוכן נוצר בהצלחה!");
    console.log(`📚 נוצרה תוכנית אחת: ${program.title}`);
    console.log(`📖 נוצרו ${createdLessons.length} שיעורים`);
    console.log(`✏️ נוצרו ${exerciseCounter - 1} תרגילים`);

    // שאלה למשתמש
    const { createMore } = await inquirer.prompt([
      {
        type: "confirm",
        name: "createMore",
        message: "האם ליצור תוכנית נוספת?",
        default: false
      }
    ]);

    if (createMore) {
      console.log("\n🚀 יצירת תוכנית מתקדמת...");
      
      const advancedProgram = await TrainingProgram.create({
        title: "אימון מנטלי מתקדם - מנהיגות וביצועי שיא",
        description: "תוכנית מתקדמת לשחקנים מנוסים המעוניינים להגיע לרמת ביצועים גבוהה ולפתח כישורי מנהיגות",
        category: "mental",
        difficulty: "advanced",
        estimatedDuration: 180,
        objectives: [
          "פיתוח מנהיגות בקבוצה",
          "טכניקות מתקדמות לביצועי שיא",
          "ניהול רגשות במצבי קיצון",
          "בניית חוסן מנטלי לטווח ארוך"
        ],
        prerequisites: ["השלמת קורס אימון מנטלי בסיסי"],
        targetAudience: "שחקנים מנוסים וקפטנים",
        instructor: {
          name: "ד״ר יוסי כהן",
          title: "פסיכולוג ספורט מוסמך",
          bio: "בעל ניסיון של 15 שנה בעבודה עם ספורטאים מקצועיים",
          imageUrl: "https://example.com/instructor.jpg"
        },
        accessRules: {
          subscriptionTypes: ["advanced", "premium"],
          specificUsers: []
        },
        totalLessons: 3,
        isPublished: true,
        publishedAt: new Date(),
        createdBy: adminUser._id,
        lastModifiedBy: adminUser._id
      });
      
      console.log(`✅ נוצרה תוכנית מתקדמת: ${advancedProgram.title}`);
    }

  } catch (error) {
    console.error("❌ שגיאה:", error);
  } finally {
    await mongoose.disconnect();
    console.log("\n👋 מנותק ממסד הנתונים");
  }
}

// הרצת הסקריפט
seedTrainingContent(); 