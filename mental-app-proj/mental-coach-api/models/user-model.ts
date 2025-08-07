import mongoose, { Schema, Document, Model } from "mongoose";
import crypto from "crypto";
import { IUserMatch, IUserTraining } from "./user-match-training-model";
// Interface for the User

export interface IUser extends Document {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  phone: string;
  uid: string;
  nickName?: string;
  age?: number;
  position?: string; // עמדה , שוער , מגן שמאלי וכו...
  bio?: string; // תיאור כללי
  strongLeg?: string;
  currentStatus: { title: String; rating: Number }[];
  userTeam?: { name: String };
  userLeague?: { name: String };
  league?: mongoose.Types.ObjectId;
  team: mongoose.Types.ObjectId;
  selectedTeamColor: { hex1: string; hex2: string; hex3: string };
  matches?: IUserMatch[];
  trainings?: IUserTraining[];
  totalScore?: number;
  seasons?: number;
  playerNumber: string;
  encouragementSystemMessages?: {
    title: string;
    description: string;
    image?: string;
    date: Date;
    confirmed: boolean;
  }[];
  subscriptionType: "basic" | "advanced" | "premium";
  subscriptionExpiresAt?: Date;
  coachWhatsappNumber?: string;
  subscriptionId?: mongoose.Types.ObjectId;
  transactionId?: string; // מזהה עסקה
  certificationsNumber?: number;
  totalWins?: number;
  trainingProgram?: mongoose.Types.ObjectId;
  createdAt?: Date;
  passwordResetDate?: string;
  passwordResetDateMethod: () => void;
  setProfileComplete: boolean;
  setGoalAndProfileComplete: boolean;
  theDream: String;
  breakOutSeason: String;
  role: number;
  investigation: boolean;
  fcmToken?: string;
  // Auth configuration fields
  allowedAuthMethods?: {
    email?: boolean;
    sms?: boolean;
    google?: boolean;
  };
  firebasePhoneNumber?: string; // Phone number as stored in Firebase Auth
  mentalTrainingProgress?: Array<{
    trainingProgramId: mongoose.Types.ObjectId;
    enrolledAt: Date;
    
    lessonProgress: Array<{
      lessonId: mongoose.Types.ObjectId;
      startedAt: Date;
      completedAt?: Date;
      watchTime: number;
      progressPercentage: number;
      completed: boolean;
      userNotes?: string;
    }>;
    
    exerciseResponses: Array<{
      lessonId: mongoose.Types.ObjectId;
      exerciseId: string;
      completed: boolean;
      completedAt?: Date;
      responses: any; // Schema.Types.Mixed - התשובות
      timeSpent: number; // בשניות
      score?: number;
    }>;
    
    currentLesson?: mongoose.Types.ObjectId;
    overallProgress: number; // 0-100
    totalWatchTime: number;
    lastAccessed: Date;
    completed: boolean;
    completedAt?: Date;
    earnedPoints: number;
  }>;
  // External API fields
  externalId?: string; // מזהה ייחודי מהמערכת החיצונית
  externalSource?: string; // שם המערכת החיצונית
}

// Define the schema
const UserSchema: Schema = new Schema<IUser>({
  firstName: { type: String },
  lastName: { type: String },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String },
  password: { type: String, select: false },
  uid: { type: String },
  nickName: { type: String },
  age: { type: Number },
  position: { type: String },
  bio: { type: String },
  strongLeg: { type: String },
  currentStatus: [{ title: String, rating: { type: Number, min: 1, max: 5 } }],
  userTeam: { name: String },
  userLeague: { name: String },
  league: { type: Schema.Types.ObjectId, ref: "League" },
  team: { type: Schema.Types.ObjectId, ref: "Team" },
  playerNumber: { type: String },
  selectedTeamColor: { hex1: String, hex2: String, hex3: String },
  matches: [
    {
      date: { type: Date, required: true },
      homeTeam: { _id: Schema.Types.ObjectId, name: String },
      awayTeam: { _id: Schema.Types.ObjectId, name: String },
      score: {
        home: { type: Number, default: 0 },
        away: { type: Number, default: 0 },
      },
      actions: [{ actionName: String, performed: { type: Number, default: 0.0 } }],
      goal: { goalName: String, performed: { type: Number, default: 0.0 } },
      matchResult: { type: String, enum: ["win", "lose", "draw"] },
      personalityGroup: { title: String, tag: String, performed: { type: Number, default: 0.0 } },
      // Enforces "YYYY-YYYY" format
      season: {
        type: String,
        validate: {
          validator: function (v: string) {
            return /\d{4}-\d{4}/.test(v);
          },
          message: (props: { value: any }) => `${props.value} is not a valid season. Use "YYYY-YYYY"`,
        },
      },
      isUserPickedTime: { type: Boolean, default: false },
      note: { type: String },
      isOpen: { type: Boolean, default: false },
      investigation: { type: Boolean, default: false },
      matchId: { type: Schema.Types.ObjectId, ref: "Match" },
      isHomeMatch: { type: Boolean, default: true },
      visible: { type: Boolean, default: true },
    },
  ],
  trainings: [
    {
      date: { type: Date, required: true },
      actions: [{ actionName: String, performed: { type: Number, default: 0.0 } }],
      goal: { goalName: String, performed: { type: Number, default: 0.0 } },
      personalityGroup: { title: String, tag: String, performed: { type: Number, default: 0.0 } },
      season: {
        type: String,
        validate: {
          validator: function (v: string) {
            return /\d{4}-\d{4}/.test(v);
          },
          message: (props: { value: any }) => `${props.value} is not a valid season. Use "YYYY-YYYY"`,
        },
      },
      note: { type: String },
      isOpen: { type: Boolean, default: false },
      investigation: { type: Boolean, default: false },
      visible: { type: Boolean, default: true },
    },
  ],
  subscriptionType: {
    type: String,
    enum: ["basic", "advanced", "premium"],
    default: "basic",
  },
  subscriptionExpiresAt: {
    type: Date,
    required: false,
  },
  coachWhatsappNumber: {
    type: String,
    required: false,
    validate: {
      validator: function (v: string) {
        if (!v) {
          return true;
        }
        return /^\+?[0-9\s-]{10,15}$/.test(v);
      },
      message: (props: { value: string }) => `${props.value} is not a valid phone number!`,
    },
    default: '',
  },
  subscriptionId: { type: Schema.Types.ObjectId },
  transactionId: { type: String }, // מזהה עסקה
  totalScore: { type: Number, default: 0 },
  seasons: { type: Number },
  encouragementSystemMessages: [
    {
      title: { type: String, required: true },
      description: { type: String, required: true },
      image: { type: String },
      date: { type: Date, required: true },
      confirmed: { type: Boolean, required: true },
    },
  ],
  certificationsNumber: { type: Number },
  totalWins: { type: Number, default: 0 },
  trainingProgram: { type: Schema.Types.ObjectId, ref: "TrainingProgram" },
  createdAt: { type: Date, default: Date.now },
  setProfileComplete: { type: Boolean, default: false },
  setGoalAndProfileComplete: { type: Boolean, default: false },
  theDream: { type: String },
  breakOutSeason: { type: String },
  role: { type: Number, select: false },
  fcmToken: { type: String },
  // Auth configuration fields
  allowedAuthMethods: {
    email: { type: Boolean, default: false },
    sms: { type: Boolean, default: true },
    google: { type: Boolean, default: true }
  },
  firebasePhoneNumber: { 
    type: String,
    validate: {
      validator: function (v: string) {
        if (!v) return true;
        // Firebase phone format validation (E.164)
        return /^\+[1-9]\d{1,14}$/.test(v);
      },
      message: (props: { value: string }) => `${props.value} is not a valid E.164 phone number format!`
    }
  },
  mentalTrainingProgress: [{
    trainingProgramId: { 
      type: Schema.Types.ObjectId, 
      ref: "TrainingProgram",
      required: true
    },
    enrolledAt: { 
      type: Date, 
      default: Date.now 
    },
    
    lessonProgress: [{
      lessonId: { 
        type: Schema.Types.ObjectId, 
        ref: "Lesson",
        required: true
      },
      startedAt: { 
        type: Date, 
        required: true 
      },
      completedAt: Date,
      watchTime: { 
        type: Number, 
        default: 0,
        min: 0
      },
      progressPercentage: { 
        type: Number, 
        default: 0,
        min: 0,
        max: 100
      },
      completed: { 
        type: Boolean, 
        default: false 
      },
      userNotes: String
    }],
    
    exerciseResponses: [{
      lessonId: { 
        type: Schema.Types.ObjectId, 
        ref: "Lesson",
        required: true
      },
      exerciseId: { 
        type: String, 
        required: true 
      },
      completed: { 
        type: Boolean, 
        default: false 
      },
      completedAt: Date,
      responses: Schema.Types.Mixed, // התשובות
      timeSpent: { 
        type: Number, 
        default: 0,
        min: 0
      }, // בשניות
      score: { 
        type: Number,
        min: 0
      }
    }],
    
    currentLesson: { 
      type: Schema.Types.ObjectId, 
      ref: "Lesson" 
    },
    overallProgress: { 
      type: Number, 
      default: 0,
      min: 0,
      max: 100
    }, // 0-100
    totalWatchTime: { 
      type: Number, 
      default: 0,
      min: 0
    },
    lastAccessed: { 
      type: Date, 
      default: Date.now 
    },
    completed: { 
      type: Boolean, 
      default: false 
    },
    completedAt: Date,
    earnedPoints: { 
      type: Number, 
      default: 0,
      min: 0
    }
  }],
  // External API fields
  externalId: { 
    type: String, 
    sparse: true 
  },
  externalSource: { 
    type: String 
  }
});

UserSchema.methods.passwordResetDateMethod = function () {
  this.passwordResetDate = Date.now();
};

// Export the model
const User: Model<IUser> = mongoose.model<IUser>("User", UserSchema);

export default User;
