import mongoose, { Schema, Document, Model } from "mongoose";

// ממשק לתוכנית אימון מנטלי
export interface ITrainingProgram extends Document {
  title: string;
  description: string;
  instructor: mongoose.Types.ObjectId;
  category: "mental" | "technical" | "tactical" | "physical";
  type: "course" | "program";
  difficulty: "beginner" | "intermediate" | "advanced";
  totalLessons: number;
  estimatedDuration: number; // בדקות
  
  // מנגנון גישה
  accessRules: {
    subscriptionTypes: string[]; // ["basic", "advanced", "premium"]
    specificUsers: mongoose.Types.ObjectId[];
    requireSequential: boolean; // חובה לסיים שיעור לפני המשך
  };
  
  isPublished: boolean;
  createdBy: mongoose.Types.ObjectId;
  lastModifiedBy: mongoose.Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}

// הגדרת הסכמה
const TrainingProgramSchema: Schema = new Schema<ITrainingProgram>(
  {
    title: { 
      type: String, 
      required: [true, "כותרת התוכנית הינה שדה חובה"],
      trim: true,
      maxlength: [100, "כותרת התוכנית לא יכולה להיות ארוכה מ-100 תווים"]
    },
    description: { 
      type: String,
      trim: true,
      maxlength: [1000, "תיאור התוכנית לא יכול להיות ארוך מ-1000 תווים"]
    },
    instructor: { 
      type: Schema.Types.ObjectId, 
      ref: "User",
      required: [true, "מדריך התוכנית הינו שדה חובה"]
    },
    category: { 
      type: String,
      enum: {
        values: ["mental", "technical", "tactical", "physical"],
        message: "קטגוריה חייבת להיות אחת מהאפשרויות: mental, technical, tactical, physical"
      },
      required: [true, "קטגוריה הינה שדה חובה"]
    },
    type: { 
      type: String,
      enum: {
        values: ["course", "program"],
        message: "סוג התוכנית חייב להיות course או program"
      },
      default: "course"
    },
    difficulty: { 
      type: String,
      enum: {
        values: ["beginner", "intermediate", "advanced"],
        message: "רמת קושי חייבת להיות אחת מהאפשרויות: beginner, intermediate, advanced"
      },
      required: [true, "רמת קושי הינה שדה חובה"]
    },
    totalLessons: { 
      type: Number,
      min: [1, "תוכנית חייבת להכיל לפחות שיעור אחד"],
      default: 0
    },
    estimatedDuration: { 
      type: Number, // בדקות
      min: [0, "משך התוכנית לא יכול להיות שלילי"],
      default: 0
    },
    
    // מנגנון גישה
    accessRules: {
      subscriptionTypes: {
        type: [String],
        enum: ["basic", "advanced", "premium"],
        default: ["basic", "advanced", "premium"]
      },
      specificUsers: [{
        type: Schema.Types.ObjectId,
        ref: "User"
      }],
      requireSequential: {
        type: Boolean,
        default: true
      }
    },
    
    isPublished: { 
      type: Boolean, 
      default: false 
    },
    createdBy: { 
      type: Schema.Types.ObjectId, 
      ref: "User",
      required: [true, "יוצר התוכנית הינו שדה חובה"]
    },
    lastModifiedBy: { 
      type: Schema.Types.ObjectId, 
      ref: "User"
    }
  },
  {
    timestamps: true, // יוצר אוטומטית createdAt ו-updatedAt
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// אינדקסים לביצועים טובים יותר
TrainingProgramSchema.index({ category: 1, difficulty: 1 });
TrainingProgramSchema.index({ instructor: 1 });
TrainingProgramSchema.index({ isPublished: 1 });
TrainingProgramSchema.index({ "accessRules.subscriptionTypes": 1 });

// Virtual לחישוב מספר השיעורים (יחושב דינמית מהשיעורים המקושרים)
TrainingProgramSchema.virtual("lessons", {
  ref: "Lesson",
  localField: "_id",
  foreignField: "trainingProgramId"
});

// Middleware לעדכון lastModifiedBy
TrainingProgramSchema.pre("save", function(next) {
  if (this.isModified() && !this.isNew) {
    this.lastModifiedBy = this.createdBy; // בפועל צריך לקבל מה-context
  }
  next();
});

// יצוא המודל
const TrainingProgram: Model<ITrainingProgram> = mongoose.model<ITrainingProgram>("TrainingProgram", TrainingProgramSchema);

export default TrainingProgram; 