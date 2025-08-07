import mongoose, { Schema, Document, Model } from "mongoose";

// ממשק לתרגיל בשיעור
export interface ILessonExercise extends Document {
  lessonId: mongoose.Types.ObjectId;
  exerciseId: string;
  type: "questionnaire" | "text_input" | "video_reflection" | "action_plan" | "mental_visualization" | "content_slider" | "signature";
  title: string;
  description: string;
  
  // New optional fields
  attachments?: Array<{ name: string; url: string }>;
  audioUrl?: string;
  exampleAnswer?: string;
  customButton?: { text: string; link: string };
  
  settings: {
    timeLimit?: number; // בשניות
    required: boolean;
    points: number;
    order: number;
  };
  
  content: any; // Schema.Types.Mixed - תוכן גמיש לפי סוג התרגיל
  
  accessibility: {
    hasAudioInstructions: boolean;
    supportsDyslexia: boolean;
    hasAlternativeFormat: boolean;
  };
  
  createdBy: mongoose.Types.ObjectId;
  lastModifiedBy: mongoose.Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}

// ממשקים לסוגי תוכן שונים
export interface IQuestionnaireContent {
  questions: Array<{
    questionId: string;
    questionText: string;
    questionType: "single_choice" | "multiple_choice" | "scale" | "open_text" | "file_upload" | "signature";
    options?: Array<{
      optionId: string;
      text: string;
      isCorrect?: boolean;
    }>;
    scaleRange?: {
      min: number;
      max: number;
      labels?: {
        min: string;
        max: string;
      };
    };
    required: boolean;
    points?: number;
  }>;
}

export interface ITextInputContent {
  prompts: Array<{
    promptId: string;
    promptText: string;
    placeholder?: string;
    minLength?: number;
    maxLength?: number;
    required: boolean;
  }>;
}

export interface IVideoReflectionContent {
  videoUrl: string;
  questions: Array<{
    questionId: string;
    questionText: string;
    timeStamp?: number; // שניות מתחילת הסרטון
    required: boolean;
  }>;
}

export interface IActionPlanContent {
  sections: Array<{
    sectionId: string;
    title: string;
    description?: string;
    fields: Array<{
      fieldId: string;
      fieldType: "text" | "date" | "number" | "select";
      label: string;
      placeholder?: string;
      options?: string[];
      required: boolean;
    }>;
  }>;
}

export interface IMentalVisualizationContent {
  steps: Array<{
    stepId: string;
    title: string;
    description: string;
    duration: number; // בשניות
    audioUrl?: string;
    imageUrl?: string;
  }>;
  totalDuration: number;
}

// ממשק לתוכן חתימה
export interface ISignatureContent {
  signatureData: {
    declarationText: string; // הטקסט שהמשתמש חותם עליו
    nameField: boolean; // האם להציג שדה שם
    dateField: boolean; // האם להציג תאריך
    generateCertificate: boolean; // האם ליצור תעודה/PDF
    certificateTemplate?: string; // URL לתבנית התעודה
  };
}

// ממשק לתוכן סליידר תוכן
export interface IContentSliderContent {
  requiresSelection: boolean;
  items: Array<{
    id: string;
    type: "image" | "text";
    content: string;
  }>;
}

// הגדרת הסכמה
const LessonExerciseSchema: Schema = new Schema<ILessonExercise>(
  {
    lessonId: {
      type: Schema.Types.ObjectId,
      ref: "Lesson",
      required: [true, "שיעור התרגיל הינו שדה חובה"],
      index: true
    },
    exerciseId: {
      type: String,
      required: [true, "מזהה התרגיל הינו שדה חובה"],
      trim: true,
      match: [/^exercise_\d+$/, "מזהה התרגיל חייב להיות בפורמט exercise_X"]
    },
    type: {
      type: String,
      enum: {
        values: ["questionnaire", "text_input", "video_reflection", "action_plan", "mental_visualization", "content_slider", "signature"],
        message: "סוג התרגיל חייב להיות אחד מהאפשרויות המוגדרות"
      },
      required: [true, "סוג התרגיל הינו שדה חובה"]
    },
    title: {
      type: String,
      required: [true, "כותרת התרגיל הינה שדה חובה"],
      trim: true,
      maxlength: [200, "כותרת התרגיל לא יכולה להיות ארוכה מ-200 תווים"]
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, "תיאור התרגיל לא יכול להיות ארוך מ-500 תווים"]
    },
    
    // New optional fields
    attachments: [{
      name: { type: String, required: true },
      url: { type: String, required: true }
    }],
    audioUrl: { type: String },
    exampleAnswer: { type: String },
    customButton: {
      text: { type: String },
      link: { type: String }
    },
    
    // הגדרות התרגיל
    settings: {
      timeLimit: {
        type: Number,
        min: [0, "מגבלת זמן לא יכולה להיות שלילית"]
      },
      required: {
        type: Boolean,
        default: true
      },
      points: {
        type: Number,
        default: 10,
        min: [0, "ניקוד לא יכול להיות שלילי"]
      },
      order: {
        type: Number,
        required: [true, "סדר התרגיל הינו שדה חובה"],
        min: [0, "סדר התרגיל לא יכול להיות שלילי"]
      }
    },
    
    // תוכן התרגיל - גמיש לפי הסוג
    content: {
      type: Schema.Types.Mixed,
      required: [true, "תוכן התרגיל הינו שדה חובה"],
      validate: {
        validator: function(this: ILessonExercise, value: any) {
          // ולידציה בסיסית לפי סוג התרגיל
          switch (this.type) {
            case "questionnaire":
              return value && Array.isArray(value.questions) && value.questions.length > 0;
            case "text_input":
              return value && Array.isArray(value.prompts) && value.prompts.length > 0;
            case "video_reflection":
              return value && value.videoUrl && Array.isArray(value.questions);
            case "action_plan":
              return value && Array.isArray(value.sections) && value.sections.length > 0;
            case "mental_visualization":
              return value && Array.isArray(value.steps) && value.steps.length > 0;
            case "content_slider":
              return value && typeof value.requiresSelection === 'boolean' && Array.isArray(value.items);
            case "signature":
              return value && typeof value.signatureData === 'object' && value.signatureData !== null;
            default:
              return false;
          }
        },
        message: "תוכן התרגיל לא תואם לסוג התרגיל שנבחר"
      }
    },
    
    // נגישות
    accessibility: {
      hasAudioInstructions: {
        type: Boolean,
        default: false
      },
      supportsDyslexia: {
        type: Boolean,
        default: false
      },
      hasAlternativeFormat: {
        type: Boolean,
        default: false
      }
    },
    
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "יוצר התרגיל הינו שדה חובה"]
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
LessonExerciseSchema.index({ lessonId: 1, exerciseId: 1 }, { unique: true });
LessonExerciseSchema.index({ lessonId: 1, "settings.order": 1 });
LessonExerciseSchema.index({ type: 1 });

// Middleware לעדכון lastModifiedBy
LessonExerciseSchema.pre<ILessonExercise>("save", function(next) {
  if (this.isModified() && !this.isNew) {
    this.lastModifiedBy = this.createdBy; // בפועל צריך לקבל מה-context
  }
  next();
});

// מתודות סטטיות לעזרה ביצירת תרגילים
LessonExerciseSchema.statics.createQuestionnaire = function(baseData: any, content: IQuestionnaireContent) {
  return new this({
    ...baseData,
    type: "questionnaire",
    content
  });
};

LessonExerciseSchema.statics.createTextInput = function(baseData: any, content: ITextInputContent) {
  return new this({
    ...baseData,
    type: "text_input",
    content
  });
};

LessonExerciseSchema.statics.createVideoReflection = function(baseData: any, content: IVideoReflectionContent) {
  return new this({
    ...baseData,
    type: "video_reflection",
    content
  });
};

LessonExerciseSchema.statics.createActionPlan = function(baseData: any, content: IActionPlanContent) {
  return new this({
    ...baseData,
    type: "action_plan",
    content
  });
};

LessonExerciseSchema.statics.createMentalVisualization = function(baseData: any, content: IMentalVisualizationContent) {
  return new this({
    ...baseData,
    type: "mental_visualization",
    content
  });
};

// יצוא המודל
const LessonExercise: Model<ILessonExercise> = mongoose.model<ILessonExercise>("LessonExercise", LessonExerciseSchema);

export default LessonExercise; 