#!/usr/bin/env node

import mongoose from "mongoose";
import inquirer from "inquirer";
import colors from "colors";

// מודלים
const LessonExercise = mongoose.model("LessonExercise", new mongoose.Schema({
  lessonId: { type: mongoose.Schema.Types.ObjectId, ref: "Lesson", required: true },
  exerciseId: { type: String, required: true, unique: true },
  type: {
    type: String,
    enum: ["questionnaire", "text_input", "video_reflection", "action_plan", "mental_visualization", "content_slider", "signature"],
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

// התחברות למסד נתונים
async function connectDB() {
  try {
    const { mongoUri } = await inquirer.prompt([
      {
        type: "input",
        name: "mongoUri",
        message: "Enter MongoDB connection string:",
        default: "mongodb://localhost:27017/mental-coach-dev"
      }
    ]);

    await mongoose.connect(mongoUri);
    console.log("✅ Connected to MongoDB".green);
  } catch (error) {
    console.error("❌ Database connection error:".red, error.message);
    process.exit(1);
  }
}

async function addSignatureExercise() {
  try {
    await connectDB();

    // מציאת משתמש אדמין
    const adminUser = await User.findOne({ email: "admin@mentalcoach.co.il" });
    if (!adminUser) {
      console.error("❌ Admin user not found. Please create an admin user first.".red);
      process.exit(1);
    }

    // ID של שיעור 6
    const lesson6Id = new mongoose.Types.ObjectId("6863d54a020e131bf118557d");

    // בדיקה אם התרגיל כבר קיים
    const existingExercise = await LessonExercise.findOne({
      lessonId: lesson6Id,
      type: "signature"
    });

    if (existingExercise) {
      console.log("⚠️  Signature exercise already exists in lesson 6".yellow);
      const { overwrite } = await inquirer.prompt([
        {
          type: "confirm",
          name: "overwrite",
          message: "Do you want to overwrite it?",
          default: false
        }
      ]);
      
      if (!overwrite) {
        console.log("❌ Operation cancelled".red);
        process.exit(0);
      }
      
      await LessonExercise.deleteOne({ _id: existingExercise._id });
      console.log("🗑️  Deleted existing exercise".yellow);
    }

    // ספירת תרגילים קיימים לקביעת הסדר
    const exerciseCount = await LessonExercise.countDocuments({ lessonId: lesson6Id });

    // יצירת תרגיל החתימה
    const signatureExercise = await LessonExercise.create({
      lessonId: lesson6Id,
      exerciseId: `exercise_signature_${Date.now()}`,
      type: "signature",
      title: "התחייבות אישית - חתימה על החזון שלי",
      description: "חתום על ההתחייבות האישית שלך לעמוד ביעדים ובחזון שהגדרת",
      instructions: "קרא את ההצהרה בעיון, מלא את השדות הנדרשים וחתום על ההתחייבות שלך",
      settings: {
        order: exerciseCount + 1,
        mandatory: true,
        points: 100,
        timeLimit: 300, // 5 דקות
        allowRetake: false,
        showCorrectAnswers: false
      },
      content: {
        signatureData: {
          declarationText: "אני מתחייב בזאת לעמוד ביעדים שהגדרתי לעצמי בתוכנית האימון המנטלי. אני מבין שההצלחה שלי תלויה במחויבות שלי לתהליך ובנכונות שלי להתמיד ולהשתפר מדי יום. אני מתחייב לתרגל את הטכניקות שלמדתי, להיות כנה עם עצמי ולא לוותר גם כשקשה. החתימה שלי היא הבטחה לעצמי שאני אעשה כל מה שביכולתי כדי להגשים את החזון שלי ככדורגלן.",
          nameField: true,
          dateField: true,
          generateCertificate: true,
          certificateTemplate: "https://storage.googleapis.com/mental-training/certificates/commitment_template.pdf"
        }
      },
      createdBy: adminUser._id,
      lastModifiedBy: adminUser._id
    });

    console.log("\n✅ תרגיל החתימה נוצר בהצלחה!".green);
    console.log("📝 פרטי התרגיל:".cyan);
    console.log(`   ID: ${signatureExercise._id}`);
    console.log(`   כותרת: ${signatureExercise.title}`);
    console.log(`   סוג: ${signatureExercise.type}`);
    console.log(`   סדר: ${signatureExercise.settings.order}`);
    console.log(`   ניקוד: ${signatureExercise.settings.points}`);
    console.log(`   חובה: ${signatureExercise.settings.mandatory ? 'כן' : 'לא'}`);

  } catch (error) {
    console.error("❌ Error creating signature exercise:".red, error);
  } finally {
    await mongoose.disconnect();
    console.log("\n👋 Disconnected from MongoDB".gray);
  }
}

// הרצת הסקריפט
addSignatureExercise(); 