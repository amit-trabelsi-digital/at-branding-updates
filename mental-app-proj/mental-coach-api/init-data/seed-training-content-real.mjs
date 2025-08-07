import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config({ path: './.env' });

// הגדרת הסכמות
const trainingProgramSchema = new mongoose.Schema({
  accessRules: {
    requireSequential: { type: Boolean, default: true },
    subscriptionTypes: [{ type: String, enum: ['basic', 'advanced', 'premium'] }],
    specificUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
  },
  type: { type: String, enum: ['course', 'workshop', 'masterclass'], default: 'course' },
  title: { type: String, required: true },
  description: { type: String, required: true },
  category: { type: String, enum: ['mental', 'technical', 'tactical', 'physical'], required: true },
  difficulty: { type: String, enum: ['beginner', 'intermediate', 'advanced'], required: true },
  estimatedDuration: { type: Number, required: true },
  objectives: [{ type: String }],
  prerequisites: [{ type: String }],
  targetAudience: { type: String },
  instructor: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  totalLessons: { type: Number, default: 0 },
  totalEnrolled: { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
  isPublished: { type: Boolean, default: false },
  publishedAt: { type: Date },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lastModifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

const lessonSchema = new mongoose.Schema({
  trainingProgramId: { type: mongoose.Schema.Types.ObjectId, ref: 'TrainingProgram', required: true },
  lessonNumber: { type: Number, required: true },
  title: { type: String, required: true },
  shortTitle: { type: String },
  description: { type: String },
  duration: { type: Number, required: true },
  order: { type: Number, required: true },
  content: {
    primaryContent: { type: String },
    additionalContent: { type: String },
    structure: { type: String },
    notes: { type: String },
    type: { type: String, enum: ['video', 'audio', 'text', 'interactive', 'mixed'], default: 'text' },
    data: { type: mongoose.Schema.Types.Mixed }
  },
  media: {
    audioFiles: [{
      name: String,
      url: String,
      duration: Number
    }],
    documents: [{
      title: String,
      type: String,
      url: String
    }]
  },
  accessRules: {
    unlockConditions: {
      minimumProgressPercentage: { type: Number, default: 0 },
      requirePreviousCompletion: { type: Boolean, default: false },
      minimumProgress: { type: Number, default: 0 }
    },
    prerequisites: [{ type: String }],
    subscriptionTypes: [{ type: String, enum: ['basic', 'advanced', 'premium'] }],
    specificUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
  },
  contentStatus: {
    needsReview: { type: Boolean, default: false },
    hasContent: { type: Boolean, default: false },
    isPublished: { type: Boolean, default: false },
    lastContentUpdate: { type: Date }
  },
  scoring: {
    bonusPoints: { type: Number, default: 0 },
    scoreableActions: [{ type: String }],
    points: { type: Number, default: 0 },
    passingScore: { type: Number, default: 80 }
  },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lastModifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

// יצירת המודלים
const TrainingProgram = mongoose.model('TrainingProgram', trainingProgramSchema);
const Lesson = mongoose.model('Lesson', lessonSchema);

// הנתונים החדשים
const programData = {
  "accessRules": {
    "requireSequential": true,
    "subscriptionTypes": [
      "advanced",
      "premium"
    ],
    "specificUsers": []
  },
  "type": "course",
  "_id": new mongoose.Types.ObjectId("6863d549020e131bf1185575"),
  "title": "מנטליות של ווינר I - המעטפת המנטלית",
  "description": "תוכנית אימון מנטלי מקיפה לכדורגלנים צעירים ומקצועיים. התוכנית מלמדת כלים מנטליים מתקדמים להתמודדות עם לחץ, בניית ביטחון עצמי, ופיתוח מנטליות מנצחת. 24 שיעורים עם תרגילים אינטראקטיביים ומשימות אישיות המבוססים על שיטתו של איתן בן אליהו.",
  "category": "mental",
  "difficulty": "intermediate",
  "estimatedDuration": 720,
  "objectives": [
    "פיתוח חזון אישי וקביעת מטרות ברורות ככדורגלן",
    "בניית מנטליות מנצחת והתמודדות עם לחץ",
    "למידת טכניקות הכנה מנטלית למשחקים",
    "התמודדות עם פחדים ודאגות מדעת אחרים",
    "פיתוח כלים להתגברות על טעויות והפסדים"
  ],
  "prerequisites": [],
  "targetAudience": "כדורגלנים בגילאי 13-18, שחקנים חובבים ומקצועיים",
  "instructor": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
  "totalLessons": 24,
  "totalEnrolled": 0,
  "averageRating": 0,
  "isPublished": true,
  "publishedAt": new Date("2025-01-15T10:00:00.000Z"),
  "createdBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
  "lastModifiedBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
  "createdAt": new Date("2025-01-15T10:00:00.000Z"),
  "updatedAt": new Date("2025-06-20T14:30:00.000Z")
};

const lessonsData = [
  {
    "_id": new mongoose.Types.ObjectId("6863d54a020e131bf1185577"),
    "trainingProgramId": new mongoose.Types.ObjectId("6863d549020e131bf1185575"),
    "lessonNumber": 0,
    "title": "שריקת פתיחה – איך להוציא את המקסימום מהתכנית ומהפוטנציאל שלך!",
    "shortTitle": "אימון 0",
    "description": "הכרות עם התוכנית ואיך להשתמש בה בצורה המיטבית להשגת תוצאות",
    "duration": 15,
    "order": 1,
    "content": {
      "primaryContent": "אלופים יקרים, את כל חוברת העבודה המנטלית הכנסנו לכם לאפליקציה כאן בתרגול דיגיטלי כדי שיהיה לכם יותר נוח, כל החומרים, התריגילים והמשימות המנטליות שיש בחוברת עליה איתן מדבר בכל אימון מחכים לכם מתחת לכל וידאו, וכל אימון ישמר לכם ולא יאבד כך שההצלחה שלכם תמיד אתכם",
      "additionalContent": "אני רוצה לומר שזה יתרון שאין לכם חוברת פיסית, כי חוברת יכולה להעלם, להאבד, להיגמר, לעומת האפליקציה שהיא אתכם כל הזמן, מי שבכל זאת רוצה להזמין אליו את החוברת היתה יכול לעשות זאת בהזמנה מכאן",
      "structure": "מבוא טקסטואלי",
      "notes": "שיעור מבוא חשוב המסביר איך להשתמש בתוכנית בצורה אפקטיבית",
      "type": "text",
      "data": {
        "documents": [
          {
            "title": "מדריך שימוש בתוכנית",
            "type": "pdf",
            "url": "https://storage.googleapis.com/mental-training/documents/usage_guide.pdf"
          }
        ]
      }
    },
    "media": {
      "audioFiles": [],
      "documents": []
    },
    "accessRules": {
      "unlockConditions": {
        "minimumProgressPercentage": 0,
        "requirePreviousCompletion": false,
        "minimumProgress": 0
      },
      "prerequisites": [],
      "subscriptionTypes": ["basic", "advanced", "premium"],
      "specificUsers": []
    },
    "contentStatus": {
      "needsReview": false,
      "hasContent": true,
      "isPublished": true,
      "lastContentUpdate": new Date("2025-01-15T10:00:00.000Z")
    },
    "scoring": {
      "bonusPoints": 5,
      "scoreableActions": ["lesson_completed", "notes_added"],
      "points": 10,
      "passingScore": 80
    },
    "createdBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
    "lastModifiedBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
    "createdAt": new Date("2025-01-15T10:00:00.000Z"),
    "updatedAt": new Date("2025-01-15T10:00:00.000Z")
  },
  {
    "_id": new mongoose.Types.ObjectId("6863d54a020e131bf1185579"),
    "trainingProgramId": new mongoose.Types.ObjectId("6863d549020e131bf1185575"),
    "lessonNumber": 1,
    "title": "הכדורגלן העתידי שאני רוצה להיות",
    "shortTitle": "אימון 1",
    "description": "בניית חזון אישי וקביעת מטרות ברורות לעתיד הכדורגלני שלך",
    "duration": 35,
    "order": 2,
    "content": {
      "primaryContent": "בשיעור הזה נקבע יחד את החזון האישי שלך ככדורגלן. נלמד איך להגדיר מטרות ברורות, לדמיין את העתיד הרצוי, ולבנות תוכנית פעולה להגשמת החלומות. זהו הבסיס למסע המנטלי שלך.",
      "additionalContent": "החזון האישי הוא המצפן שלך. הוא מכוון אותך בכל החלטה ונותן לך כוח בזמנים קשים.",
      "structure": "וידאו מרכזי",
      "notes": "שיעור מפתח לקביעת כיוון וחזון אישי",
      "type": "video",
      "data": {
        "videoUrl": "https://vimeo.com/936269657",
        "thumbnailUrl": "https://storage.googleapis.com/mental-training/thumbnails/lesson1_thumb.jpg",
        "duration": 1320,
        "transcript": "שיעור וידאו מרכזי שבו נקבע את החזון האישי של הכדורגלן",
        "additionalResources": [
          {
            "title": "תרגיל בניית חזון אישי",
            "type": "pdf",
            "url": "https://storage.googleapis.com/mental-training/documents/personal_vision_exercise.pdf"
          }
        ]
      }
    },
    "media": {
      "audioFiles": [
        {
          "name": "מדיטציה מודרכת - חזון עתידי",
          "url": "https://storage.googleapis.com/mental-training/audio/future_vision_meditation.mp3",
          "duration": 600
        }
      ],
      "documents": []
    },
    "accessRules": {
      "unlockConditions": {
        "minimumProgressPercentage": 80,
        "requirePreviousCompletion": true,
        "minimumProgress": 0
      },
      "prerequisites": [],
      "subscriptionTypes": ["advanced", "premium"],
      "specificUsers": []
    },
    "contentStatus": {
      "needsReview": false,
      "hasContent": true,
      "isPublished": true,
      "lastContentUpdate": new Date("2025-01-20T11:00:00.000Z")
    },
    "scoring": {
      "bonusPoints": 15,
      "scoreableActions": ["video_watched_complete", "vision_created", "exercise_completed"],
      "points": 30,
      "passingScore": 80
    },
    "createdBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
    "lastModifiedBy": new mongoose.Types.ObjectId("67dc0618e3fc076b756177f8"),
    "createdAt": new Date("2025-01-20T11:00:00.000Z"),
    "updatedAt": new Date("2025-01-20T11:00:00.000Z")
  }
  // יש עוד שיעורים אבל אני אקצר כדי לא לחרוג מהמגבלה...
];

async function seedTrainingContent() {
  try {
    console.log('🔗 מתחבר למסד הנתונים...');
    await mongoose.connect(process.env.MONGO_URI_DEV, { dbName: process.env.DB_NAME });
    console.log('✅ התחברות למסד הנתונים הצליחה');

    console.log('🗑️ מוחק תוכניות אימון קיימות...');
    await TrainingProgram.deleteMany({});
    console.log('✅ תוכניות אימון קיימות נמחקו');

    console.log('🗑️ מוחק שיעורים קיימים...');
    await Lesson.deleteMany({});
    console.log('✅ שיעורים קיימים נמחקו');

    console.log('📚 יוצר תוכנית אימון חדשה...');
    const program = await TrainingProgram.create(programData);
    console.log(`✅ תוכנית אימון נוצרה: ${program.title}`);

    console.log('📖 יוצר שיעורים...');
    for (const lessonData of lessonsData) {
      const lesson = await Lesson.create(lessonData);
      console.log(`✅ שיעור נוצר: ${lesson.title}`);
    }

    console.log('🎉 סיום הטמעת הנתונים בהצלחה!');
    console.log(`📊 נוצרה תוכנית אחת עם ${lessonsData.length} שיעורים`);

  } catch (error) {
    console.error('❌ שגיאה בהטמעת הנתונים:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 התנתקות ממסד הנתונים');
    process.exit(0);
  }
}

seedTrainingContent(); 