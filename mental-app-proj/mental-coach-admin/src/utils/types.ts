/* eslint-disable @typescript-eslint/no-explicit-any */
export type User = {
  _id?: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  password: string;
  uid: string;
  nickName?: string;
  age?: number;
  team: string;
  position?: string; // עמדה , שוער , מגן שמאלי וכו...
  bio?: string; // תיאור כללי
  strongLeg?: string;
  currentStatus: { title: string; rating: number }[];
  league?: string;
  subscriptionType: "basic" | "advanced" | "premium";
  subscriptionExpiresAt?: string;
  transactionId?: string; // מזהה עסקה
  coachWhatsappNumber?: string;
  matches?: string[];
  totalScore?: number;
  seasons?: number;
  selectedTeamColor: { hex1: string; hex2: string; hex3: string };
  encouragementSystemMessages?: {
    title: string;
    description: string;
    image?: string;
    date: Date;
    confirmed: boolean;
  }[];
  certificationsNumber?: number;
  totalWins?: number;
  // trainingProgram?: mongoose.Types.ObjectId;
  createdAt: string;
  isAdmin: boolean;
  role?: number;
  // Auth configuration fields
  allowedAuthMethods?: {
    email?: boolean;
    sms?: boolean;
    google?: boolean;
  };
  firebasePhoneNumber?: string; // Phone number as stored in Firebase Auth
};

export type League = {
  _id: string;
  name: string;
  country: string;
  season: string;
  numberOfTeams: number;
  teams: {
    _id: string;
    name: string;
    city: string;
    stadium: string;
    coach: string;
    foundedYear: number;
    championshipsWon: number;
    players: string;
  }[];

  matches: {
    date: string | Date;
    homeTeam: string;
    awayTeam: string;
    score: {
      home: number;
      away: number;
    };
    location: string;
  }[];
  createdAt: Date;
  updatedAt: Date;
};

export type Team = {
  _id: string;
  name: string;
  city: string;
  hex1: string;
  hex2: string;
  hex3: string;
  users: string[]; // ids
  createdAt: Date;
  updatedAt: Date;
};

export type Match = {
  _id: string;
  date: Date;
  homeTeam: string | Partial<Team>;
  awayTeam: string | Partial<Team>;
  season: string;
  score: { home: number; away: number };
  location: string;
  createdAt: string;
};

export type BaseDialogProps = { open: boolean; onClose: () => void };

export type CaseAndResponse = {
  _id: string;
  case: string;
  response: string;
  responseState: "before" | "after" | "inTime";
  role: string;
  link: string;
  sent: boolean;
  createdAt: Date;
  sentAt?: Date;
  notes: string;
  tags: string[];
  positions: string[];
  data?: Record<string, any>; // Optional payload for additional information
};

export type PersonallityGroup = {
  _id: string;
  title: string;
  tags: string[];
};

export type Case = {
  _id: string;
  case: string;
  response: string;
  responseState: "before" | "after" | "inTime";
  link: string;
  sent: boolean;
  createdAt: Date;
  sentAt?: Date;
  notes: string;
  positions: { value: string; label: string }[];
  tags: { value: string; label: string }[];
  data?: Record<string, any>; // Optional payload for additional information
};

export type Position = { label: string; value: string };

export type Goal = {
  _id: string;
  goalName: string;
  positions: { value: string; label: string }[];
  measurable: boolean;
  trainingCompatible: boolean;
  createdAt: Date;
};

export type Action = {
  _id: string;
  actionName: string;
  positions: { value: string; label: string }[];
  measurable: boolean;
  trainingCompatible: boolean;
};

export type PushMessages = {
  _id: string;
  title: string;
  message: string;
  recipient: string; // Could be a user ID or "all" for broadcasting
  // data?: Record<string, any>; // Optional payload for additional information
  dataLink: string;
  readMoreLink: string;
  appearedIn: string;
  notes: string;

  sent: boolean;
  createdAt: Date;
  sentAt?: Date;
};

export type Score = {
  _id: string;
  scoreTrigger: string; // Name of the score
  points: number;
  branch: string;
  notes: string;
  limit: number;
};

// ========== טיפוסים למערכת קורסים דיגיטליים (גרסה מעודכנת על בסיס API) ==========

// --- Enums and General Types ---

export type PublishStatus = 'draft' | 'active' | 'archived';
export type DifficultyLevel = 'beginner' | 'intermediate' | 'advanced' | 'expert';
export type SubscriptionType = "basic" | "advanced" | "premium";

export interface AccessRules {
  subscriptionTypes: SubscriptionType[];
  specificUsers?: string[];
  requireSequential?: boolean;
  prerequisites?: string[]; // Array of lesson IDs
  unlockConditions?: {
    requirePreviousCompletion: boolean;
    minimumProgressPercentage?: number;
  };
}

// --- Training Program ---

export interface TrainingProgram {
  _id: string;
  title: string;
  description: string;
  instructor?: string; // Should be instructorId
  instructorId?: string;
  category?: string;
  type?: 'course' | 'workshop';
  difficulty?: DifficultyLevel;
  totalLessons?: number;
  estimatedDuration?: number; // in minutes
  accessRules?: AccessRules;
  isPublished: boolean;
  createdBy?: string;
  lastModifiedBy?: string;
  createdAt: string;
  updatedAt: string;
  
  lessons?: Lesson[]; 
  thumbnailUrl?: string;
  tags?: string[];
  status: PublishStatus; // from old type
  lessonsOrder?: string[]; // from old type
  id?: string; // from old type for client-side consistency
}

// --- Lesson ---

export interface LessonMedia {
  videoUrl?: string | null;
  videoType?: 'primary' | 'secondary' | null;
  videoDuration?: number;
  audioFiles?: {
    name: string;
    url: string;
    duration: number;
  }[];
  documents?: {
    name: string;
    url: string;
    type: 'pdf' | 'doc' | 'other';
  }[];
}

export interface LessonContent {
  primaryContent: string;
  additionalContent?: string;
  structure?: string;
  notes?: string;
  highlights?: string[]; // הדגשים - מערך של מחרוזות
  type?: 'text' | 'video' | 'mixed';
  data?: {
    videoUrl?: string;
    thumbnailUrl?: string;
    duration?: number;
    transcript?: string;
    documents?: {
      title: string;
      type: 'pdf' | 'doc';
      url: string;
    }[];
    additionalResources?: {
      title: string;
      type: 'pdf' | 'link';
      url: string;
    }[];
  };
}

export interface LessonContentStatus {
  isPublished: boolean;
  hasContent: boolean;
  needsReview: boolean;
  lastContentUpdate?: string | null;
}

export interface LessonScoring {
  points: number;
  bonusPoints?: number;
  scoreableActions?: string[];
  passingScore?: number;
}

export interface Lesson {
  _id: string;
  trainingProgramId: string;
  lessonNumber: number;
  title: string;
  shortTitle?: string;
  content: LessonContent;
  media: LessonMedia;
  order: number;
  duration: number; // in minutes
  accessRules?: AccessRules;
  contentStatus: LessonContentStatus;
  scoring?: LessonScoring;
  createdBy?: string;
  lastModifiedBy?: string;
  createdAt: string;
  updatedAt: string;

  // from old type for client-side consistency
  id?: string; 
  isPublished: boolean;
  description: string; 

  exercises?: Exercise[];
}


// --- Exercises ---

export type ExerciseType = 'questionnaire' | 'text_input' | 'video_reflection' | 'action_plan' | 'mental_visualization' | 'content_slider' | 'file_upload' | 'signature';

export interface ExerciseSettings {
  timeLimit?: number; // in seconds
  required: boolean;
  points: number;
  order: number;
  allowRetake?: boolean;
  showCorrectAnswers?: boolean;
}

// --- Question Types for Questionnaire ---

export type QuestionType = 'text_area' | 'multiple_choice' | 'scale' | 'text_input' | 'file_upload' | 'signature';

export interface QuestionScale {
  min: number;
  max: number;
  labels: { [key: number]: string };
}

export interface QuestionOption {
    optionId?: string;
    text: string;
    isCorrect?: boolean;
}

export interface QuestionnaireQuestion {
  id: string;
  type: QuestionType;
  question: string;
  placeholder?: string;
  minLength?: number;
  maxLength?: number;
  required: boolean;
  options?: QuestionOption[] | string[];
  scale?: QuestionScale;
}

// --- Field Types for Action Plan ---
export interface ActionPlanField {
  name: string;
  type: 'text_input' | 'text_area';
  label: string;
  placeholder?: string;
  required: boolean;
}


// --- Content Slider (NEW & OPTIONAL) ---
export interface SliderItem {
  id: string;
  type: 'image' | 'text';
  content: string;
}
export interface ContentSliderContent {
  requiresSelection: boolean;
  items: SliderItem[];
}


export interface ExerciseContent {
  questions?: QuestionnaireQuestion[];
  fields?: ActionPlanField[];
  instructions?: string[];
  reflectionQuestion?: string;
  slider?: ContentSliderContent;
}


export interface Exercise {
  _id: string;
  lessonId: string;
  exerciseId?: string;
  type: ExerciseType;
  title: string;
  description: string;
  settings: ExerciseSettings;
  content: ExerciseContent;
  
  // Optional recommendations
  audioUrl?: string;
  attachments?: { name: string; url: string }[];
  exampleAnswer?: string;
  customButton?: { text: string; link: string };

  accessibility?: {
    hasAudioInstructions?: boolean;
    supportsDyslexia?: boolean;
    hasAlternativeFormat?: boolean;
  };
  createdBy?: string;
  lastModifiedBy?: string;
  createdAt: string;
  updatedAt: string;
}

// --- User Progress ---

export interface ExerciseSubmission {
  id: string;
  exerciseId: string;
  userId: string;
  answers: {
    questionId: string;
    answer: any;
  }[];
  score?: number;
  feedback?: string;
  submittedAt: Date;
  completionTime: number; // in minutes
}

export interface UserProgramProgress {
  id: string;
  userId: string;
  programId: string;
  enrolledAt: Date;
  completedLessons: string[];
  currentLessonId?: string;
  totalPoints: number;
  completionPercentage: number;
  lastActivityAt: Date;
  completedAt?: Date;
}

export interface UserLessonProgress {
  id: string;
  userId: string;
  lessonId: string;
  programId: string;
  startedAt: Date;
  completedAt?: Date;
  viewDuration: number; // in minutes
  completedExercises: string[];
  earnedPoints: number;
  rating?: number;
  notes?: string;
}

// --- API Response Types ---

export interface ApiResponse<T> {
  status: "success" | "error";
  data?: T;
  message?: string;
  error?: {
    statusCode: number;
    status: string;
  };
}

export interface ProgramsResponse {
  programs: TrainingProgram[];
}

export interface ProgramResponse {
  program: TrainingProgram;
}

export interface LessonsResponse {
  lessons: Lesson[];
}

export interface LessonResponse {
  lesson: Lesson;
}

export interface ExercisesResponse {
  exercises: Exercise[];
}

export interface ExerciseResponse {
  exercise: Exercise;
}
