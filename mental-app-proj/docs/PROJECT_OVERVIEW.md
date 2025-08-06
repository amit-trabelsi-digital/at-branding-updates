# מערכת Mental Coach - סקירת פרויקט מקיפה

## תיאור כללי

Mental Coach היא פלטפורמה מקיפה לאימון מנטלי לספורטאים, במיוחד לשחקני כדורגל. המערכת כוללת שלושה רכיבים עיקריים:

1. **אפליקציית מובייל (Flutter)** - לשחקנים
2. **מערכת ניהול (React Admin)** - למנהלים ומאמנים
3. **שרת API (Node.js)** - לניהול הנתונים והלוגיקה העסקית

## ארכיטקטורת המערכת

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mental Coach System                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Flutter App    │  │  React Admin    │  │   API Server    │ │
│  │  (Mobile)       │  │  (Web)          │  │   (Node.js)     │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
│           │                    │                     │          │
│           └────────────────────┴─────────────────────┘          │
│                               │                                 │
│                               ▼                                 │
│                    ┌─────────────────────┐                     │
│                    │    MongoDB          │                     │
│                    │    Database         │                     │
│                    └─────────────────────┘                     │
│                               │                                 │
│                               ▼                                 │
│                    ┌─────────────────────┐                     │
│                    │    Firebase         │                     │
│                    │  (Auth & Storage)   │                     │
│                    └─────────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

## 1. אפליקציית המובייל (mental-coach-flutter)

### מטרה
אפליקציה לשחקני כדורגל המספקת כלים לאימון מנטלי, מעקב אחר ביצועים, והכנה למשחקים.

### טכנולוגיות
- **Flutter 3.6+** - פיתוח חוצה פלטפורמות
- **Dart** - שפת התכנות
- **Provider** - ניהול state
- **GoRouter** - ניווט
- **Firebase** - אימות והודעות push
- **HTTP** - תקשורת עם השרת

### תכונות עיקריות
1. **מערכת התחברות והרשמה**
   - התחברות עם Google/Apple
   - הרשמה ידנית עם אימייל וסיסמה
   - הגדרת פרופיל ומטרות אישיות

2. **דשבורד אישי**
   - תצוגת משחק הקרוב
   - סטטיסטיקות אישיות
   - ניקוד כללי
   - תוכניות אימון פעילות

3. **ניהול משחקים ואימונים**
   - הוספת משחקים עתידיים
   - תיעוד ביצועים במשחק
   - מעקב אחר מטרות ופעולות
   - חקירת אירועים מיוחדים

4. **מערכת אימון מנטלי**
   - תוכניות אימון מובנות
   - שיעורים עם וידאו
   - תרגילים אינטראקטיביים
   - מעקב התקדמות

5. **מקרים ותגובות**
   - תרחישים מנטליים
   - אסטרטגיות התמודדות
   - למידה מניסיון

### מבנה הקוד
```
lib/
├── main.dart              # נקודת כניסה
├── config/               # הגדרות סביבה
├── models/               # מודלים של נתונים
├── providers/            # ניהול state
├── screens/              # מסכי האפליקציה
│   ├── login/           # מסכי התחברות
│   ├── main/            # מסכים ראשיים
│   └── general/         # מסכים כלליים
├── service/             # שירותי API
├── widgets/             # רכיבים לשימוש חוזר
└── routes/              # ניהול ניווט
```

### סביבות עבודה
- **Development**: `https://mntl-app-dev.eitanazaria.co.il`
- **Production**: `https://mntl-app.eitanazaria.co.il`

## 2. מערכת הניהול (mental-coach-admin)

### מטרה
ממשק ניהול מקיף למנהלי המערכת ומאמנים לניהול תוכן, משתמשים ומעקב אחר התקדמות.

### טכנולוגיות
- **React 18** עם TypeScript
- **Vite** - כלי build מהיר
- **Material-UI** - ספריית רכיבים
- **React Router v7** - ניווט
- **Firebase** - אימות ואחסון
- **React Hook Form + Yup** - טפסים וולידציה
- **SWR** - ניהול מטמון ו-data fetching

### תכונות עיקריות
1. **ניהול משתמשים**
   - רשימת משתמשים
   - עריכת פרופילים
   - ניהול הרשאות
   - מעקב מנויים

2. **ניהול תוכן ספורטיבי**
   - ליגות וקבוצות
   - משחקים ותוצאות
   - מטרות ופעולות
   - ניקוד וסטטיסטיקות

3. **מערכת קורסים דיגיטליים**
   - יצירת תוכניות אימון
   - ניהול שיעורים
   - בניית תרגילים
   - מעקב התקדמות

4. **תקשורת**
   - הודעות מאיתן (המאמן)
   - הודעות Push
   - ניהול תגיות
   - מקרים ותגובות

5. **מדיה וקבצים**
   - העלאת תמונות ווידאו
   - ניהול קבצים
   - אחסון ב-Firebase Storage

### מבנה הקוד
```
src/
├── router.tsx           # הגדרות ניווט
├── routes/             # רכיבי הגנה על נתיבים
├── layouts/            # תבניות עמוד
├── pages/              # עמודי האפליקציה
├── components/         # רכיבים לשימוש חוזר
│   ├── dialogs/       # חלונות דיאלוג
│   └── general/       # רכיבים כלליים
├── services/          # שירותי API
├── utils/             # פונקציות עזר
├── hooks/             # React hooks
├── data/              # נתונים סטטיים
└── plugins/           # הגדרות ספריות
```

### ממשק משתמש
- **עיצוב RTL** - תמיכה מלאה בעברית
- **Material Design** - עיצוב מודרני ונקי
- **Responsive** - התאמה למסכים שונים
- **Dark Mode** - תמיכה עתידית

## 3. שרת API (mental-coach-api)

### מטרה
שרת backend המספק API RESTful לניהול כל הנתונים והלוגיקה העסקית של המערכת.

### טכנולוגיות
- **Node.js** עם TypeScript
- **Express.js** - framework לשרת
- **MongoDB** עם Mongoose - מסד נתונים
- **Firebase Admin** - אימות ו-push notifications
- **SendGrid** - שליחת מיילים
- **React Email** - תבניות מייל

### תכונות עיקריות
1. **אימות והרשאות**
   - אימות Firebase
   - ניהול תפקידים (admin/user)
   - middleware להגנה על נתיבים
   - טוקנים ו-refresh

2. **ניהול נתונים**
   - CRUD מלא לכל הישויות
   - קשרים מורכבים בין נתונים
   - אגרגציות וסטטיסטיקות
   - חיפוש וסינון מתקדם

3. **מערכת קורסים**
   - תוכניות אימון היררכיות
   - ניהול גישה לתוכן
   - מעקב התקדמות
   - ניקוד והישגים

4. **תקשורת**
   - שליחת מיילים עם תבניות
   - הודעות Push
   - webhooks
   - real-time updates

5. **אבטחה וביצועים**
   - Rate limiting
   - Input sanitization
   - CORS configuration
   - Error handling
   - Logging

### מבנה הקוד
```
├── server.ts           # נקודת כניסה
├── controllers/        # לוגיקה עסקית
├── models/            # מודלים של Mongoose
├── routes/            # הגדרות נתיבים
├── middlewares/       # middleware functions
├── utils/             # פונקציות עזר
├── lib/               # ספריות חיצוניות
├── emails/            # תבניות מייל
├── scripts/           # סקריפטים לניהול
└── documentation/     # תיעוד
```

### API Endpoints עיקריים
```
/api/auth/*           - אימות והרשמה
/api/users/*          - ניהול משתמשים
/api/training-programs/* - תוכניות אימון
/api/lessons/*        - שיעורים
/api/exercises/*      - תרגילים
/api/matches/*        - משחקים
/api/teams/*          - קבוצות
/api/leagues/*        - ליגות
/api/goals/*          - מטרות
/api/actions/*        - פעולות
/api/push-messages/*  - הודעות push
/api/cases/*          - מקרים ותגובות
```

## מודלים עיקריים במסד הנתונים

### User (משתמש)
```typescript
{
  firstName, lastName, email, phone,
  uid, // Firebase UID
  position, // תפקיד בקבוצה
  team, league, // שיוכים
  matches[], trainings[], // היסטוריה
  subscriptionType, // סוג מנוי
  mentalTrainingProgress[], // התקדמות בקורסים
  role // 0=admin, 1+=user
}
```

### TrainingProgram (תוכנית אימון)
```typescript
{
  title, description,
  category: "mental" | "technical" | "tactical" | "physical",
  difficulty: "beginner" | "intermediate" | "advanced",
  accessRules: {
    subscriptionTypes[],
    requireSequential
  },
  totalLessons, estimatedDuration
}
```

### Lesson (שיעור)
```typescript
{
  trainingProgramId,
  title, content, media,
  order, duration,
  accessRules,
  exercises[]
}
```

### Match (משחק)
```typescript
{
  date, homeTeam, awayTeam,
  score: { home, away },
  location,
  userPerformance // נתוני ביצוע אישיים
}
```

## זרימות עבודה עיקריות

### 1. הרשמת משתמש חדש
```
Mobile App → Firebase Auth → API Server → MongoDB
    ↓            ↓              ↓           ↓
User Input → Create User → Save Profile → Return Token
```

### 2. גישה לתוכנית אימון
```
User Request → Check Auth → Check Subscription → Check Prerequisites
      ↓            ↓              ↓                    ↓
   App/Web    Firebase Token   API Logic         Lesson Access
```

### 3. תיעוד משחק
```
Add Match → Set Goals → Play Match → Record Performance → Calculate Score
     ↓          ↓           ↓              ↓                    ↓
  Pre-game   Planning    Real-time      Post-game           Analytics
```

## הגדרות סביבה נדרשות

### API Server (.env)
```bash
PORT=5001
NODE_ENV=development
MONGO_URI_DEV=mongodb://localhost:27017/
DB_NAME=mental-coach
SENDGRID_API_KEY=SG.xxxxx
```

### Admin Panel
```bash
VITE_API_BASE_URL=http://localhost:5001
```

### Flutter App
הגדרות בקובץ `environment_config.dart`

## התקנה והרצה

### 1. API Server
```bash
cd mental-coach-api
npm install
npm run dev
```

### 2. Admin Panel
```bash
cd mental-coach-admin
npm install
npm run dev
```

### 3. Flutter App
```bash
cd mental-coach-flutter
flutter pub get
flutter run
```

## סקריפטים שימושיים

### API Server
- `npm run create-user` - יצירת משתמש
- `npm run make-user-admin` - הפיכה למנהל
- `npm run seed-training` - הזנת נתוני אימון

### Admin Panel
- `npm run build` - בניה לפרודקשן
- `npm run lint` - בדיקת קוד

### Flutter
- `flutter build apk` - בניית APK
- `flutter build ios` - בניית iOS
- `flutter analyze` - בדיקת קוד

## אבטחה והרשאות

1. **אימות** - כל הבקשות דורשות Firebase token
2. **הרשאות** - בדיקת role (0=admin)
3. **הצפנה** - HTTPS בפרודקשן
4. **Sanitization** - ניקוי קלט משתמש
5. **Rate Limiting** - הגבלת בקשות

## ביצועים ואופטימיזציה

1. **Caching** - SWR באדמין, Provider בפלאטר
2. **Lazy Loading** - טעינה עצלה של רכיבים
3. **Indexes** - אינדקסים ב-MongoDB
4. **Compression** - דחיסת תגובות
5. **CDN** - שימוש ב-Firebase Storage

## תחזוקה ופיתוח

1. **Logging** - לוגים מפורטים בשרת
2. **Error Tracking** - טיפול בשגיאות
3. **Monitoring** - ניטור ביצועים
4. **Backups** - גיבויים אוטומטיים
5. **CI/CD** - בניה ופריסה אוטומטית

## קרדיטים

פותח על ידי [עמית טרבלסי](https://amit-trabelsi.co.il)

---

*מסמך זה מספק סקירה כללית של המערכת. לפרטים טכניים נוספים, עיין בתיעוד הספציפי של כל פרויקט.* 