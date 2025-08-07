import mongoose, { Schema, Document, Model } from "mongoose";

// ממשק לשיעור בודד
export interface ILesson extends Document {
  trainingProgramId: mongoose.Types.ObjectId;
  lessonNumber: number;
  title: string;
  shortTitle: string;
  
  content: {
    primaryContent: string;
    additionalContent: string;
    structure: string;
    notes: string;
    highlights?: string[]; // הדגשים - מערך של מחרוזות
  };
  
  media: {
    videoUrl?: string;
    videoType?: "primary" | "supplementary";
    videoDuration?: number;
    audioFiles: Array<{
      name: string;
      url: string;
      duration: number;
    }>;
    documents: Array<{
      name: string;
      url: string;
      type: string;
    }>;
  };
  
  order: number;
  duration: number;
  
  accessRules: {
    subscriptionTypes: string[];
    specificUsers: mongoose.Types.ObjectId[];
    prerequisites: mongoose.Types.ObjectId[];
    unlockConditions: {
      requirePreviousCompletion: boolean;
      minimumProgressPercentage: number;
    };
  };
  
  contentStatus: {
    isPublished: boolean;
    hasContent: boolean;
    needsReview: boolean;
    lastContentUpdate: Date;
  };
  
  scoring: {
    points: number;
    bonusPoints: number;
    scoreableActions: string[];
  };
  
  createdBy: mongoose.Types.ObjectId;
  lastModifiedBy: mongoose.Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}

// הגדרת הסכמה
const LessonSchema: Schema = new Schema<ILesson>(
  {
    trainingProgramId: {
      type: Schema.Types.ObjectId,
      ref: "TrainingProgram",
      required: [true, "תוכנית האימון הינה שדה חובה"],
      index: true
    },
    lessonNumber: {
      type: Number,
      required: [true, "מספר השיעור הינו שדה חובה"],
      min: [0, "מספר השיעור לא יכול להיות שלילי"]
    },
    title: {
      type: String,
      required: [true, "כותרת השיעור הינה שדה חובה"],
      trim: true,
      maxlength: [200, "כותרת השיעור לא יכולה להיות ארוכה מ-200 תווים"]
    },
    shortTitle: {
      type: String,
      required: [true, "כותרת קצרה הינה שדה חובה"],
      trim: true,
      maxlength: [50, "כותרת קצרה לא יכולה להיות ארוכה מ-50 תווים"]
    },
    
    // תוכן השיעור
    content: {
      primaryContent: {
        type: String,
        default: ""
      },
      additionalContent: {
        type: String,
        default: ""
      },
      structure: {
        type: String,
        enum: ["וידאו", "טקסט", "מעורב"],
        default: "מעורב"
      },
      notes: {
        type: String,
        default: ""
      },
      highlights: [{
        type: String,
        trim: true
      }]
    },
    
    // מדיה
    media: {
      videoUrl: String,
      videoType: {
        type: String,
        enum: ["primary", "supplementary"]
      },
      videoDuration: {
        type: Number,
        min: [0, "משך הוידאו לא יכול להיות שלילי"]
      },
      audioFiles: [{
        name: {
          type: String,
          required: true
        },
        url: {
          type: String,
          required: true
        },
        duration: {
          type: Number,
          min: 0
        }
      }],
      documents: [{
        name: {
          type: String,
          required: true
        },
        url: {
          type: String,
          required: true
        },
        type: {
          type: String,
          required: true
        }
      }]
    },
    
    order: {
      type: Number,
      required: [true, "סדר השיעור הינו שדה חובה"],
      min: [0, "סדר השיעור לא יכול להיות שלילי"]
    },
    duration: {
      type: Number,
      required: [true, "משך השיעור הינו שדה חובה"],
      min: [0, "משך השיעור לא יכול להיות שלילי"]
    },
    
    // גישה ותנאים
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
      prerequisites: [{
        type: Schema.Types.ObjectId,
        ref: "Lesson"
      }],
      unlockConditions: {
        requirePreviousCompletion: {
          type: Boolean,
          default: true
        },
        minimumProgressPercentage: {
          type: Number,
          default: 80,
          min: [0, "אחוז התקדמות מינימלי לא יכול להיות שלילי"],
          max: [100, "אחוז התקדמות מינימלי לא יכול להיות מעל 100"]
        }
      }
    },
    
    // סטטוס תוכן
    contentStatus: {
      isPublished: {
        type: Boolean,
        default: false
      },
      hasContent: {
        type: Boolean,
        default: false
      },
      needsReview: {
        type: Boolean,
        default: false
      },
      lastContentUpdate: {
        type: Date,
        default: Date.now
      }
    },
    
    // ניקוד
    scoring: {
      points: {
        type: Number,
        default: 100,
        min: [0, "ניקוד לא יכול להיות שלילי"]
      },
      bonusPoints: {
        type: Number,
        default: 0,
        min: [0, "ניקוד בונוס לא יכול להיות שלילי"]
      },
      scoreableActions: [{
        type: String
      }]
    },
    
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "יוצר השיעור הינו שדה חובה"]
    },
    lastModifiedBy: {
      type: Schema.Types.ObjectId,
      ref: "User"
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// אינדקסים לביצועים טובים יותר
LessonSchema.index({ trainingProgramId: 1, order: 1 });
LessonSchema.index({ trainingProgramId: 1, lessonNumber: 1 }, { unique: true });
LessonSchema.index({ "contentStatus.isPublished": 1 });
LessonSchema.index({ "accessRules.subscriptionTypes": 1 });

// Virtual לתרגילים של השיעור
LessonSchema.virtual("exercises", {
  ref: "LessonExercise",
  localField: "_id",
  foreignField: "lessonId"
});

// Middleware לעדכון hasContent
LessonSchema.pre<ILesson>("save", function(next) {
  // בדיקה אם יש תוכן
  if (this.content.primaryContent || this.media.videoUrl || this.media.documents.length > 0) {
    this.contentStatus.hasContent = true;
  }
  
  // עדכון תאריך עדכון תוכן
  if (this.isModified("content") || this.isModified("media")) {
    this.contentStatus.lastContentUpdate = new Date();
  }
  
  // עדכון lastModifiedBy
  if (this.isModified() && !this.isNew) {
    this.lastModifiedBy = this.createdBy; // בפועל צריך לקבל מה-context
  }
  
  next();
});

// יצוא המודל
const Lesson: Model<ILesson> = mongoose.model<ILesson>("Lesson", LessonSchema);

export default Lesson; 