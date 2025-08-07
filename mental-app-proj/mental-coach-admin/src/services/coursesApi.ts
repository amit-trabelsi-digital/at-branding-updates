import { appFetch } from './fetch';
import { TrainingProgram, Lesson, Exercise, UserProgramProgress, UserLessonProgress, ExerciseSubmission } from '../utils/types';

// ========== תוכניות אימון ==========

const BASE_URL = '/api/training-programs';

/**
 * קבלת כל תוכניות האימון
 */
export const getTrainingPrograms = async (filters?: {
  status?: string;
  searchTerm?: string;
}): Promise<TrainingProgram[]> => {
  const queryParams = new URLSearchParams();
  if (filters?.status && filters.status !== 'all') {
    queryParams.append('status', filters.status);
  }
  if (filters?.searchTerm) {
    queryParams.append('search', filters.searchTerm);
  }

  const url = `${BASE_URL}${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
  const response = await appFetch(url);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  console.log('Server response:', result);
  
  // בדיקה אם הנתונים מגיעים בפורמט של {data: {programs: [...]}}
  if (result.data && result.data.programs && Array.isArray(result.data.programs)) {
    console.log('Found programs in result.data.programs:', result.data.programs);
    return result.data.programs;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data && Array.isArray(result.data)) {
    return result.data;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של programs
  if (result.programs && Array.isArray(result.programs)) {
    return result.programs;
  }
  
  // אם הנתונים מגיעים ישירות כמערך
  if (Array.isArray(result)) {
    return result;
  }
  
  // אם אין נתונים, מחזירים מערך ריק
  return [];
};

/**
 * קבלת תוכנית אימון לפי ID
 */
export const getTrainingProgram = async (id: string): Promise<TrainingProgram> => {
  const response = await appFetch(`${BASE_URL}/${id}`);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data) {
    return result.data;
  }
  
  // אם הנתונים מגיעים ישירות
  return result;
};

/**
 * יצירת תוכנית אימון חדשה
 */
export const createTrainingProgram = async (data: Omit<TrainingProgram, 'id' | '_id' | 'createdAt' | 'updatedAt'>): Promise<TrainingProgram> => {
  const response = await appFetch(BASE_URL, {
    method: 'POST',
    body: JSON.stringify(data),
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data) {
    return result.data;
  }
  
  // אם הנתונים מגיעים ישירות
  return result;
};

/**
 * עדכון תוכנית אימון
 */
export const updateTrainingProgram = async (id: string, data: Partial<TrainingProgram>): Promise<TrainingProgram> => {
  const response = await appFetch(`${BASE_URL}/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(data),
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data) {
    return result.data;
  }
  
  // אם הנתונים מגיעים ישירות
  return result;
};

/**
 * מחיקת תוכנית אימון
 */
export const deleteTrainingProgram = async (id: string): Promise<void> => {
  const response = await appFetch(`${BASE_URL}/${id}`, {
    method: 'DELETE',
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
};

// ========== שיעורים ==========

/**
 * קבלת כל השיעורים של תוכנית
 */
export const getLessonsByProgram = async (programId: string): Promise<Lesson[]> => {
  const response = await appFetch(`/api/training-programs/${programId}/lessons`);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  console.log('Lessons response:', result);
  
  // בדיקה אם הנתונים מגיעים בפורמט של {data: {lessons: [...]}}
  if (result.data && result.data.lessons && Array.isArray(result.data.lessons)) {
    return result.data.lessons;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data && Array.isArray(result.data)) {
    return result.data;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של lessons
  if (result.lessons && Array.isArray(result.lessons)) {
    return result.lessons;
  }
  
  // אם הנתונים מגיעים ישירות כמערך
  if (Array.isArray(result)) {
    return result;
  }
  
  // אם אין נתונים, מחזירים מערך ריק
  return [];
};

/**
 * קבלת שיעור לפי ID
 */
export const getLessonById = async (id: string): Promise<Lesson> => {
  const response = await appFetch(`/api/lessons/${id}`);
  const data = await response.json();
  return data;
};

/**
 * יצירת שיעור חדש
 */
export const createLesson = async (lesson: Omit<Lesson, 'id' | 'createdAt' | 'updatedAt' | 'viewCount'>): Promise<Lesson> => {
  const response = await appFetch('/api/lessons', {
    method: 'POST',
    body: JSON.stringify(lesson)
  });
  const data = await response.json();
  return data;
};

/**
 * עדכון שיעור
 */
export const updateLesson = async (programId: string, lessonId: string, data: Partial<Lesson>): Promise<Lesson> => {
  const response = await appFetch(`${BASE_URL}/${programId}/lessons/${lessonId}`, {
    method: 'PATCH',
    body: JSON.stringify(data),
  });
  const result = await response.json();
  return result;
};

/**
 * מחיקת שיעור
 */
export const deleteLesson = async (programId: string, lessonId: string): Promise<void> => {
  const response = await appFetch(`${BASE_URL}/${programId}/lessons/${lessonId}`, {
    method: 'DELETE',
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
};

/**
 * עדכון סדר השיעורים
 */
export const updateLessonsOrder = async (programId: string, lessonsOrder: { lessonId: string, order: number }[]): Promise<Lesson[]> => {
  const response = await appFetch('/api/lessons/reorder', {
    method: 'PUT',
    body: JSON.stringify({ programId, lessonsOrder })
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const result = await response.json();
  return result.data.lessons;
};

// ========== תרגילים ==========

/**
 * קבלת כל התרגילים של שיעור
 */
export const getExercisesByLesson = async (lessonId: string): Promise<Exercise[]> => {
  const response = await appFetch(`/api/lessons/${lessonId}/exercises`);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  console.log('Exercises response:', result);
  
  // בדיקה אם הנתונים מגיעים בפורמט של {data: {exercises: [...]}}
  if (result.data && result.data.exercises && Array.isArray(result.data.exercises)) {
    return result.data.exercises;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data && Array.isArray(result.data)) {
    return result.data;
  }
  
  // בדיקה אם הנתונים מגיעים בפורמט של exercises
  if (result.exercises && Array.isArray(result.exercises)) {
    return result.exercises;
  }
  
  // אם הנתונים מגיעים ישירות כמערך
  if (Array.isArray(result)) {
    return result;
  }
  
  // אם אין נתונים, מחזירים מערך ריק
  return [];
};

/**
 * קבלת תרגיל לפי ID
 */
export const getExerciseById = async (id: string): Promise<Exercise> => {
  const response = await appFetch(`/api/exercises/${id}`);
  return response.json();
};

/**
 * יצירת תרגיל חדש
 */
export const createExercise = async (exercise: Omit<Exercise, 'id' | 'createdAt' | 'updatedAt' | 'completedCount'>): Promise<Exercise> => {
  const response = await appFetch('/api/exercises', {
    method: 'POST',
    body: JSON.stringify(exercise)
  });
  return response.json();
};

/**
 * עדכון תרגיל
 */
export const updateExercise = async (id: string, updates: Partial<Exercise>): Promise<Exercise> => {
  const response = await appFetch(`/api/exercises/${id}`, {
    method: 'PUT',
    body: JSON.stringify(updates)
  });
  return response.json();
};

/**
 * מחיקת תרגיל
 */
export const deleteExercise = async (id: string): Promise<void> => {
  await appFetch(`/api/exercises/${id}`, {
    method: 'DELETE'
  });
};

/**
 * הגשת תרגיל
 */
export const submitExercise = async (exerciseId: string, submission: Omit<ExerciseSubmission, 'id' | 'submittedAt'>): Promise<ExerciseSubmission> => {
  const response = await appFetch(`/api/exercises/${exerciseId}/submit`, {
    method: 'POST',
    body: JSON.stringify(submission)
  });
  return response.json();
};

// ========== התקדמות משתמשים ==========

/**
 * קבלת התקדמות משתמש בכל התוכניות
 */
export const getUserProgress = async (userId: string): Promise<UserProgramProgress[]> => {
  const response = await appFetch(`/api/users/${userId}/training-progress`);
  return response.json();
};

/**
 * קבלת התקדמות משתמש בתוכנית ספציפית
 */
export const getUserProgramProgress = async (userId: string, programId: string): Promise<UserProgramProgress> => {
  const response = await appFetch(`/api/users/${userId}/training-progress/${programId}`);
  return response.json();
};

/**
 * קבלת התקדמות משתמש בשיעור
 */
export const getUserLessonProgress = async (userId: string, lessonId: string): Promise<UserLessonProgress> => {
  const response = await appFetch(`/api/users/${userId}/lesson-progress/${lessonId}`);
  return response.json();
};

/**
 * רישום משתמש לתוכנית
 */
export const enrollUserToProgram = async (userId: string, programId: string): Promise<UserProgramProgress> => {
  const response = await appFetch(`/api/users/${userId}/enroll/${programId}`, {
    method: 'POST'
  });
  return response.json();
};

/**
 * התחלת שיעור
 */
export const startLesson = async (userId: string, lessonId: string): Promise<UserLessonProgress> => {
  const response = await appFetch(`/api/users/${userId}/lessons/${lessonId}/start`, {
    method: 'POST'
  });
  return response.json();
};

/**
 * עדכון התקדמות בשיעור
 */
export const updateLessonProgress = async (
  userId: string, 
  lessonId: string, 
  progress: Partial<UserLessonProgress>
): Promise<UserLessonProgress> => {
  const response = await appFetch(`/api/users/${userId}/lessons/${lessonId}/progress`, {
    method: 'PUT',
    body: JSON.stringify(progress)
  });
  return response.json();
};

// ========== סטטיסטיקות ==========

/**
 * קבלת סטטיסטיקות כלליות
 */
export const getCourseStatistics = async (): Promise<Record<string, unknown>> => {
  const response = await appFetch('/api/courses/statistics');
  return response.json();
};

/**
 * קבלת סטטיסטיקות תוכנית
 */
export const getProgramStatistics = async (programId: string): Promise<{
  enrolledCount: number;
  completedCount: number;
  avgCompletionRate: number;
  avgRating: number;
  lessonsStats: {
    lessonId: string;
    title: string;
    viewCount: number;
    avgCompletionTime: number;
  }[];
}> => {
  const response = await appFetch(`/api/training-programs/${programId}/statistics`);
  return response.json();
};

/**
 * קבלת סטטיסטיקות שיעור
 */
export const getLessonStatistics = async (lessonId: string): Promise<{
  viewCount: number;
  avgCompletionTime: number;
  avgRating: number;
  exercisesStats: {
    exerciseId: string;
    title: string;
    completedCount: number;
    avgScore: number;
  }[];
}> => {
  const response = await appFetch(`/api/lessons/${lessonId}/statistics`);
  return response.json();
};

/**
 * קבלת תשובות לתרגיל
 */
export const getExerciseSubmissions = async (exerciseId: string): Promise<ExerciseSubmission[]> => {
  const response = await appFetch(`/api/exercises/${exerciseId}/submissions`);
  return response.json();
};

// ========== חיפוש ==========

/**
 * חיפוש תוכניות
 */
export const searchPrograms = async (query: string): Promise<TrainingProgram[]> => {
  const response = await appFetch(`/api/training-programs/search?q=${encodeURIComponent(query)}`);
  return response.json();
};

/**
 * חיפוש שיעורים
 */
export const searchLessons = async (query: string): Promise<Lesson[]> => {
  const response = await appFetch(`/api/lessons/search?q=${encodeURIComponent(query)}`);
  return response.json();
};

// הוספת שיעור לתוכנית
export const addLessonToProgram = async (programId: string, data: Omit<Lesson, '_id' | 'id' | 'createdAt' | 'updatedAt'>): Promise<Lesson> => {
  const response = await appFetch(`${BASE_URL}/${programId}/lessons`, {
    method: 'POST',
    body: JSON.stringify(data),
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const result = await response.json();
  
  // בדיקה אם הנתונים מגיעים בפורמט של API Response
  if (result.data) {
    return result.data;
  }
  
  // אם הנתונים מגיעים ישירות
  return result;
}; 