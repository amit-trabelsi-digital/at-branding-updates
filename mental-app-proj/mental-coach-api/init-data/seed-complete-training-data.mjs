import mongoose from 'mongoose';
import dotenv from 'dotenv';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: './.env' });

// הגדרת הסכמות
const trainingProgramSchema = new mongoose.Schema({}, { strict: false, timestamps: true });
const lessonSchema = new mongoose.Schema({}, { strict: false, timestamps: true });

const TrainingProgram = mongoose.model('TrainingProgram', trainingProgramSchema);
const Lesson = mongoose.model('Lesson', lessonSchema);

// הנתונים המלאים מהמשתמש
const completeData = {
  "status": "success",
  "results": 1,
  "data": {
    "programs": [
      {
        "accessRules": {
          "requireSequential": true,
          "subscriptionTypes": [
            "advanced",
            "premium"
          ],
          "specificUsers": []
        },
        "type": "course",
        "_id": "6863d549020e131bf1185575",
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
        "instructor": "67dc0618e3fc076b756177f8",
        "totalLessons": 24,
        "totalEnrolled": 0,
        "averageRating": 0,
        "isPublished": true,
        "publishedAt": "2025-01-15T10:00:00.000Z",
        "createdBy": "67dc0618e3fc076b756177f8",
        "lastModifiedBy": "67dc0618e3fc076b756177f8",
        "createdAt": "2025-01-15T10:00:00.000Z",
        "updatedAt": "2025-06-20T14:30:00.000Z",
        "__v": 0,
        "lessons": [] // יטען בנפרד
      }
    ]
  }
};

async function seedCompleteData() {
  try {
    console.log('🔗 מתחבר למסד הנתונים...');
    await mongoose.connect(process.env.MONGO_URI_DEV, { dbName: process.env.DB_NAME });
    console.log('✅ התחברות למסד הנתונים הצליחה');

    console.log('🗑️ מוחק תוכניות אימון ושיעורים קיימים...');
    await TrainingProgram.deleteMany({});
    await Lesson.deleteMany({});
    console.log('✅ נתונים קיימים נמחקו');

    // הכנת נתוני התוכנית
    const programData = completeData.data.programs[0];
    const { lessons, ...programWithoutLessons } = programData;
    
    // המרת מזהים למונגו ObjectId
    programWithoutLessons._id = new mongoose.Types.ObjectId(programWithoutLessons._id);
    programWithoutLessons.instructor = new mongoose.Types.ObjectId(programWithoutLessons.instructor);
    programWithoutLessons.createdBy = new mongoose.Types.ObjectId(programWithoutLessons.createdBy);
    programWithoutLessons.lastModifiedBy = new mongoose.Types.ObjectId(programWithoutLessons.lastModifiedBy);
    programWithoutLessons.publishedAt = new Date(programWithoutLessons.publishedAt);
    programWithoutLessons.createdAt = new Date(programWithoutLessons.createdAt);
    programWithoutLessons.updatedAt = new Date(programWithoutLessons.updatedAt);

    console.log('📚 יוצר תוכנית אימון...');
    const program = await TrainingProgram.create(programWithoutLessons);
    console.log(`✅ תוכנית נוצרה: ${program.title}`);

    console.log('🎉 הטמעת נתונים הושלמה בהצלחה!');
    console.log(`📊 נוצרה תוכנית אחת עם מזהה: ${program._id}`);

  } catch (error) {
    console.error('❌ שגיאה:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

seedCompleteData(); 