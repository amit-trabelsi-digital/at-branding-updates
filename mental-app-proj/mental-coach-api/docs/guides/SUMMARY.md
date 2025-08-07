# מערכת קורסים דיגיטליים - שלב 1

## מבנה המודלים

### 1. TrainingProgram (תוכנית אימון)
מודל המייצג תוכנית אימון מלאה.

**שדות עיקריים:**
- `title` - כותרת התוכנית
- `description` - תיאור התוכנית
- `instructor` - מדריך התוכנית (רפרנס ל-User)
- `category` - קטגוריה: "mental" | "technical" | "tactical" | "physical"
- `type` - סוג: "course" | "program"
- `difficulty` - רמת קושי: "beginner" | "intermediate" | "advanced"
- `totalLessons` - מספר שיעורים כולל
- `estimatedDuration` - משך משוער בדקות
- `accessRules` - כללי גישה:
  - `subscriptionTypes` - סוגי מנוי מורשים
  - `specificUsers` - משתמשים ספציפיים
  - `requireSequential` - האם חובה לעבור שיעורים בסדר
- `isPublished` - האם התוכנית פורסמה
- `createdBy`, `lastModifiedBy` - מידע יצירה ועדכון

### 2. Lesson (שיעור)
מודל המייצג שיעור בודד בתוכנית.

**שדות עיקריים:**
- `trainingProgramId` - קישור לתוכנית
- `lessonNumber` - מספר השיעור
- `title`, `shortTitle` - כותרות
- `content` - תוכן השיעור:
  - `primaryContent` - תוכן ראשי
  - `additionalContent` - תוכן נוסף
  - `structure` - מבנה: "וידאו" | "טקסט" | "מעורב"
  - `notes` - הערות
- `media` - מדיה:
  - `videoUrl`, `videoType`, `videoDuration`
  - `audioFiles` - קבצי אודיו
  - `documents` - מסמכים
- `order` - סדר השיעור
- `duration` - משך השיעור
- `accessRules` - כללי גישה דומים לתוכנית
- `contentStatus` - סטטוס התוכן
- `scoring` - ניקוד

### 3. LessonExercise (תרגיל)
מודל המייצג תרגיל בשיעור.

**שדות עיקריים:**
- `lessonId` - קישור לשיעור
- `exerciseId` - מזהה התרגיל (exercise_1, exercise_2...)
- `type` - סוג התרגיל:
  - "questionnaire" - שאלון
  - "text_input" - קלט טקסט
  - "video_reflection" - רפלקציה על וידאו
  - "action_plan" - תוכנית פעולה
  - "mental_visualization" - דמיון מודרך
- `title`, `description` - פרטי התרגיל
- `settings` - הגדרות:
  - `timeLimit` - מגבלת זמן
  - `required` - האם חובה
  - `points` - ניקוד
  - `order` - סדר
- `content` - תוכן גמיש לפי סוג התרגיל
- `accessibility` - נגישות

### 4. עדכון מודל User
הוספת שדה `mentalTrainingProgress` למעקב התקדמות:
- `trainingProgramId` - התוכנית
- `enrolledAt` - תאריך הרשמה
- `lessonProgress` - התקדמות בשיעורים
- `exerciseResponses` - תשובות לתרגילים
- `overallProgress` - אחוז התקדמות כולל
- `totalWatchTime` - זמן צפייה כולל
- `earnedPoints` - נקודות שנצברו

## API Endpoints

### תוכניות אימון
- `GET /api/training-programs` - רשימת תוכניות
- `GET /api/training-programs/:id` - תוכנית ספציפית
- `POST /api/training-programs` - יצירת תוכנית (מדריכים בלבד)
- `PUT /api/training-programs/:id` - עדכון תוכנית
- `DELETE /api/training-programs/:id` - מחיקת תוכנית
- `GET /api/training-programs/:id/lessons` - שיעורי התוכנית
- `PATCH /api/training-programs/:id/publish` - פרסום/ביטול פרסום
- `GET /api/training-programs/:id/stats` - סטטיסטיקות

### שיעורים
- `GET /api/lessons/:id` - שיעור ספציפי
- `POST /api/lessons` - יצירת שיעור
- `PUT /api/lessons/:id` - עדכון שיעור
- `DELETE /api/lessons/:id` - מחיקת שיעור
- `GET /api/lessons/:id/exercises` - תרגילי השיעור
- `POST /api/lessons/:id/start` - התחלת שיעור
- `PUT /api/lessons/:id/progress` - עדכון התקדמות
- `PATCH /api/lessons/:id/publish` - פרסום/ביטול פרסום

### תרגילים
- `GET /api/exercises/:id` - תרגיל ספציפי
- `POST /api/exercises` - יצירת תרגיל
- `PUT /api/exercises/:id` - עדכון תרגיל
- `DELETE /api/exercises/:id` - מחיקת תרגיל
- `POST /api/exercises/:id/submit` - שליחת תשובות
- `GET /api/exercises/:id/stats` - סטטיסטיקות תרגיל
- `POST /api/exercises/questionnaire` - יצירת שאלון
- `POST /api/exercises/text-input` - יצירת תרגיל טקסט

### התקדמות משתמש
- `GET /api/user/training-progress` - כל ההתקדמות
- `GET /api/user/training-progress/:programId` - התקדמות בתוכנית
- `POST /api/user/enroll/:programId` - הרשמה לתוכנית
- `PUT /api/user/lesson-progress/:lessonId` - עדכון התקדמות בשיעור
- `GET /api/user/progress-report` - דוח התקדמות מפורט
- `POST /api/user/reset-progress/:programId` - איפוס התקדמות
- `GET /api/user/next-lesson/:programId` - השיעור הבא

## דוגמאות שימוש

### יצירת תוכנית אימון
```javascript
// POST /api/training-programs
{
  "title": "אימון מנטלי למתחילים",
  "description": "תוכנית אימון מנטלי בסיסית לכדורגלנים",
  "category": "mental",
  "type": "course",
  "difficulty": "beginner",
  "estimatedDuration": 600, // 10 שעות
  "accessRules": {
    "subscriptionTypes": ["basic", "advanced", "premium"],
    "requireSequential": true
  }
}
```

### יצירת שיעור
```javascript
// POST /api/lessons
{
  "trainingProgramId": "65a1b2c3d4e5f6g7h8i9j0k1",
  "title": "מבוא לחשיבה חיובית",
  "shortTitle": "שיעור 1",
  "content": {
    "primaryContent": "בשיעור זה נלמד על החשיבות של חשיבה חיובית...",
    "structure": "מעורב"
  },
  "media": {
    "videoUrl": "https://example.com/video1.mp4",
    "videoType": "primary",
    "videoDuration": 15
  },
  "duration": 30,
  "scoring": {
    "points": 100
  }
}
```

### יצירת תרגיל שאלון
```javascript
// POST /api/exercises/questionnaire
{
  "lessonId": "65a1b2c3d4e5f6g7h8i9j0k2",
  "title": "שאלון הבנה",
  "description": "בדיקת הבנת החומר",
  "settings": {
    "timeLimit": 300, // 5 דקות
    "required": true,
    "points": 50
  },
  "content": {
    "questions": [
      {
        "questionId": "q1",
        "questionText": "מה החשיבות של חשיבה חיובית?",
        "questionType": "single_choice",
        "options": [
          {
            "optionId": "opt1",
            "text": "משפרת ביצועים",
            "isCorrect": true
          },
          {
            "optionId": "opt2",
            "text": "לא חשובה",
            "isCorrect": false
          }
        ],
        "required": true,
        "points": 25
      }
    ]
  }
}
```

### הרשמה לתוכנית
```javascript
// POST /api/user/enroll/65a1b2c3d4e5f6g7h8i9j0k1
// Response:
{
  "status": "success",
  "message": "נרשמת בהצלחה לתוכנית האימון",
  "data": {
    "programProgress": {
      "trainingProgramId": "65a1b2c3d4e5f6g7h8i9j0k1",
      "enrolledAt": "2024-01-15T10:00:00Z",
      "overallProgress": 0,
      "earnedPoints": 0
    }
  }
}
```

## הוראות אינטגרציה לאפליקציה

### 1. מסך תוכניות אימון
```javascript
// קריאה לרשימת תוכניות
const response = await fetch('/api/training-programs', {
  headers: { 'Authorization': userToken }
});
const programs = await response.json();

// סינון לפי קטגוריה
const mentalPrograms = programs.filter(p => p.category === 'mental');
```

### 2. מסך שיעור
```javascript
// התחלת שיעור
await fetch(`/api/lessons/${lessonId}/start`, {
  method: 'POST',
  headers: { 'Authorization': userToken }
});

// עדכון התקדמות כל דקה
setInterval(async () => {
  await fetch(`/api/lessons/${lessonId}/progress`, {
    method: 'PUT',
    headers: { 
      'Authorization': userToken,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      watchTime: 60, // שניות נוספות
      progressPercentage: calculateProgress()
    })
  });
}, 60000);
```

### 3. Redux State מומלץ
```javascript
const trainingSlice = {
  programs: [],
  currentProgram: null,
  currentLesson: null,
  userProgress: {
    enrolledPrograms: [],
    currentProgramProgress: null
  },
  exercises: {
    current: null,
    responses: {}
  }
};
```

## הוראות לצוות הפיתוח

### 1. אבטחה
- כל הפעולות דורשות אימות משתמש
- בדיקת הרשאות מנוי לפני גישה לתוכן
- ולידציה מלאה של קלט משתמש
- הגנה מפני injection

### 2. ביצועים
- השתמשו ב-pagination לרשימות ארוכות
- cache לתוכניות ושיעורים פופולריים
- lazy loading למדיה כבדה
- אופטימיזציה של queries ל-MongoDB

### 3. חוויית משתמש
- שמירה אוטומטית של התקדמות
- offline support לתוכן שנצפה
- loading states ברורים
- error handling ידידותי

## בדיקות מומלצות

### 1. בדיקות פונקציונליות
- יצירת תוכנית עם כל סוגי השיעורים
- הרשמה והתקדמות מלאה בתוכנית
- שליחת תשובות לכל סוגי התרגילים
- בדיקת מנגנון הניקוד

### 2. בדיקות אבטחה
- ניסיון גישה ללא אימות
- ניסיון גישה עם מנוי לא מתאים
- ניסיון לשנות נתוני משתמש אחר
- SQL/NoSQL injection

### 3. בדיקות ביצועים
- טעינת רשימה של 1000 תוכניות
- עדכון התקדמות במקביל מ-100 משתמשים
- העלאת קבצי מדיה גדולים

## שלבים הבאים

### שלב 2 - הרחבות
1. מערכת המלצות מותאמת אישית
2. gamification מתקדם (badges, leaderboards)
3. שיתוף התקדמות ברשתות חברתיות
4. דוחות מתקדמים למדריכים

### שלב 3 - אינטגרציות
1. חיבור למערכת תשלומים
2. push notifications להתקדמות
3. אינטגרציה עם לוח שנה
4. ייצוא תעודות השלמה

### שלב 4 - אנליטיקס
1. מעקב התנהגות משתמשים
2. A/B testing לתוכן
3. דוחות ROI לתוכניות
4. predictive analytics לנשירה 