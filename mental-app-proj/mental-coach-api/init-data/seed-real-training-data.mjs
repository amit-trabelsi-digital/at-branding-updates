import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { ALL_LESSONS } from './training-lessons-data.mjs';

dotenv.config({ path: './.env' });

// הגדרת הסכמות בקצרה
const trainingProgramSchema = new mongoose.Schema({}, { strict: false, timestamps: true });
const lessonSchema = new mongoose.Schema({}, { strict: false, timestamps: true });

const TrainingProgram = mongoose.model('TrainingProgram', trainingProgramSchema);
const Lesson = mongoose.model('Lesson', lessonSchema);

async function seedData() {
  try {
    console.log('🔗 מתחבר למסד הנתונים...');
    await mongoose.connect(process.env.MONGO_URI_DEV, { dbName: process.env.DB_NAME });
    console.log('✅ התחברות למסד הנתונים הצליחה');

    console.log('🗑️ מוחק תוכניות אימון קיימות...');
    await TrainingProgram.deleteMany({});
    await Lesson.deleteMany({});
    console.log('✅ נתונים קיימים נמחקו');

    // יצירת תוכנית האימון
    const programData = {
      "_id": new mongoose.Types.ObjectId("6863d549020e131bf1185575"),
      "accessRules": {
        "requireSequential": true,
        "subscriptionTypes": ["advanced", "premium"],
        "specificUsers": []
      },
      "type": "course",
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

    console.log('📚 יוצר תוכנית אימון...');
    const program = await TrainingProgram.create(programData);
    console.log(`✅ תוכנית נוצרה: ${program.title}`);

    // יצירת השיעורים
    console.log(`📝 יוצר ${ALL_LESSONS.length} שיעורים...`);
    
    for (const lessonData of ALL_LESSONS) {
      // המרת ObjectIds
      const lesson = {
        ...lessonData,
        _id: new mongoose.Types.ObjectId(lessonData._id),
        trainingProgramId: new mongoose.Types.ObjectId(lessonData.trainingProgramId),
        createdBy: new mongoose.Types.ObjectId(lessonData.createdBy),
        lastModifiedBy: new mongoose.Types.ObjectId(lessonData.lastModifiedBy),
        createdAt: new Date(lessonData.createdAt),
        updatedAt: new Date(lessonData.updatedAt)
      };
      
      // טיפול בתאריכים null
      if (lesson.contentStatus && lesson.contentStatus.lastContentUpdate) {
        lesson.contentStatus.lastContentUpdate = new Date(lesson.contentStatus.lastContentUpdate);
      }
      
      await Lesson.create(lesson);
      console.log(`✅ שיעור ${lesson.lessonNumber}: ${lesson.shortTitle} נוצר`);
    }
    
    console.log(`✅ ${ALL_LESSONS.length} שיעורים נוצרו בהצלחה`);
    console.log('🎉 הטמעת נתונים הושלמה בהצלחה!');

  } catch (error) {
    console.error('❌ שגיאה:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

seedData(); 