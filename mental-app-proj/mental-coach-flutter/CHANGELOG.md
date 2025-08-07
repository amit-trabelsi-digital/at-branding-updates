# CHANGELOG - Mental Coach Platform
# היסטוריית שינויים - פלטפורמת המאמן המנטלי

הקובץ מאחד את כל השינויים מכל רכיבי המערכת: Flutter App, Admin Dashboard, ו-API Server.

---

## 📱 Mental Coach Flutter App

### [יום שני, 27 בינואר 2025]

#### ✅ הוספת עמוד "הפרופיל המנטלי שלי"
- יצירת עמוד חדש שמרכז את כל התשובות של המשתמש לתרגילים
- תצוגת כרטיסיות מעוצבות לכל תשובה עם פרטי התוכנית, השיעור והתרגיל
- אפשרות סינון לפי תוכנית או סוג תרגיל
- תצוגה מותאמת לכל סוג תרגיל (שאלון, טקסט חופשי, תוכנית פעולה וכו')
- הוספת העמוד לתפריט "עוד" בתחתית המסך
- תמיכה מלאה ב-RTL ועיצוב מודרני

#### 🔄 איחוד ניהול גרסה וקרדיטים
- איחדתי את ניהול מספר הגרסה והקרדיטים כך שכל המקומות באפליקציה ישתמשו באותו מקור נתונים
- **DataProvider Updates:**
  - הוספת import של `package_info_plus`
  - שינוי `appVersion` מערך קבוע ל-property דינאמי שנטען מ-pubspec.yaml
  - הוספת פונקציה `_loadAppVersion()` שקוראת את הגרסה מ-PackageInfo
  - עדכון הקרדיטים: 'פותח על ידי עמית טרבלסי'
- **Home Screen Updates:**
  - הסרת המשתנה המקומי `_version` והפונקציה `_loadVersion()`
  - עדכון התצוגה להשתמש ב-Consumer של DataProvider
- **Login Screen Updates:**
  - עדכון התצוגה להציג רק את הקרדיטים

#### 📞 הוספת מערכת תמיכה מלאה
- **קבצים חדשים:**
  - `lib/service/support_service.dart` - שירות לטיפול בפניות תמיכה עם איסוף מידע טכני אוטומטי
  - `lib/screens/support/support_dialog.dart` - דיאלוג לפתיחת פנייה עם טופס מלא
- **תכונות המערכת:**
  - איסוף מידע אוטומטי: שם העמוד הנוכחי, תאריך ושעה, מידע על המכשיר, גרסת האפליקציה, סביבת ההרצה
  - קטגוריות פנייה: תקלה טכנית, בעיה בתצוגה, בעיה בתשלום, הצעה לשיפור, אחר
  - טופס נוח ומסודר עם אינדיקציה על טעינה ומשוב ברור
- **אינטגרציה:**
  - הוספת אפשרות "תמיכה" בתפריט הנפתח עם אייקון support_agent
  - שימוש ב-API endpoint: POST /api/support
  - שליחת אימייל דרך SendGrid ל-amit@trabel.si

#### 🌐 תמיכה מלאה להרצה בדפדפן (Web Support)
- עדכון `web/index.html` עם תמיכת RTL, כותרת בעברית ומסך טעינה
- עדכון `web/manifest.json` עם פרטים בעברית
- יצירת `utils/platform_utils.dart` לטיפול בהבדלים בין פלטפורמות
- הוספת בדיקות פלטפורמה ב-FirebaseMessagingService
- עדכון main.dart עם בדיקות לפיצ'רים שלא נתמכים בווב
- **סקריפטים חדשים:**
  - `run-web.sh` - להרצה מהירה בדפדפן
  - `build-web.sh` - לבניית גרסת production
- יצירת README_WEB.md עם הוראות מפורטות
- הוספת firebase-hosting.json להגדרת Firebase Hosting

### [יום חמישי, 11 ביולי 2024]

#### 🚀 שיפורים ועדכונים כלליים
- עדכונים ושיפורי UI במסך הראשי, כולל התאמות בכפתור "פתק המטרות"
- שינויים במסכי ההתחברות והבית
- עדכונים במסכי האימון והשיעורים
- שינויים כלליים בקבצי עזר והגדרות

---

## 🖥️ Mental Coach Admin Dashboard

### [1.4.0] - 2025-01-27

#### Added - אפשרויות התחברות מרובות
- **LoginPage Updates:**
  - הוספת 3 אפשרויות התחברות: Google, אימייל וסיסמה, SMS
  - ממשק טאבים לבחירת שיטת התחברות
  - התחברות עם אימייל וסיסמה דרך Firebase Auth
  - התחברות עם SMS - שליחת קוד אימות ואימות
  - בדיקה אוטומטית שהמשתמש הוא admin (role = 0)
  - הודעות שגיאה ברורות אם המשתמש אינו admin
  - תמיכה ב-reCAPTCHA עבור אימות SMS

### [1.3.4] - 2025-01-27

#### Fixed
- **UserDialog:** תיקון בעיית שמירה בטופס עריכת משתמש
- הסרת החובה משדה "טלפון וואטסאפ של המאמן"
- תיקון ברירת מחדל של isAdmin

### [1.3.3] - 2025-01-27

#### Added
- **UserDialog - המרת טלפון אוטומטית:**
  - המרה אוטומטית של מספרי טלפון ישראליים לפורמט בינלאומי (+972)
  - עדכון אוטומטי של שדה Firebase Phone Number
  - סימון אוטומטי של אפשרות התחברות עם SMS

### [1.3.2] - 2025-01-27

#### Added  
- **UsersPage - פעולות מרובות:**
  - הוספת יכולת לבחור מספר משתמשים בו-זמנית באמצעות checkboxes
  - כפתור למחיקת כל המשתמשים המסומנים עם דיאלוג אישור
  - כפתור לשינוי סוג מנוי לכל המשתמשים המסומנים
  - דיאלוג לבחירת סוג המנוי החדש

### [1.3.1] - 2025-01-27

#### Changed
- **UsersPage:**
  - הוספת עמודת טלפון בטבלת המשתמשים עם הצגת "חסר" במקרה שאין מספר
  - הסרת אייקון Apple משיטות ההתחברות
  - הוספת יכולת לחיצה על שורה בטבלה לפתיחת דיאלוג עריכה
  - הוספת סמן עכבר והדגשה בעת מעבר מעל שורות

### [1.3.0] - 2025-01-27

#### Added - ניהול שיטות התחברות למשתמשים
- הוספת שדות חדשים בדיאלוג עריכת משתמש:
  - מספר טלפון בפיירבייס (בפורמט בינלאומי E.164)
  - בחירת שיטות התחברות מורשות: אימייל, SMS, Google, Apple
- הצגת אייקונים של שיטות התחברות מורשות בטבלת המשתמשים
- ולידציה של פורמט מספר טלפון בינלאומי
- עדכון אוטומטי של מספר הטלפון ב-Firebase Auth בעת שמירה

### שינויים שבוצעו היום

#### 1. שינוי כותרת האפליקציה ✅
- שונה השם מ"מנטלי בכיס" ל"ניהול - המאמן המנטלי" בכל המקומות

#### 2. העברת כפתורי ההוספה ✅
- כפתורי ההוספה (FAB) הועברו מהפינה התחתונה הימנית לפינה העליונה השמאלית

#### 3. הוספת שדה "מזהה עסקה" למשתמש ✅
- הוספת השדה ל-Interface ול-Schema ב-API
- הוספת שדה בטופס עריכת משתמש באדמין

#### 4. הצגת גרסת API בפוטר ✅
- נוצר פוטר חדש המציג "גרסת API: 1.0.0" בתחתית המסך

#### 5. קרדיט בתפריט הצדדי ✅
- הוסף "פותח על ידי עמי טרבלסי" עם לינק לאתר האישי

#### 6. מערכת תמיכה מלאה ✅
- קובץ חדש `controllers/support-controller.ts` ב-API
- קובץ חדש `components/dialogs/SupportDialog.tsx` באדמין
- טופס תמיכה מלא עם העלאת קבצים ומידע אוטומטי

### [Unreleased] - 2025-01-30

#### Added
- **Image Upload Component:** New ImageUpload.tsx component for Firebase Storage
- **Lesson Thumbnail Upload:** File upload instead of URL input
- **Firebase Storage Integration:** Enhanced with progress tracking
- **Drag & Drop Lesson Ordering:** New SortableLessonsList.tsx component
- **Lesson Order API:** Server endpoint for updating lesson order

#### Changed
- **LessonEditDrawer:** Uses new ImageUpload component
- **TrainingProgramsPage:** Replaced table with sortable drag & drop interface

#### Fixed
- **Video Preview:** Fixed Vimeo video preview using external thumbnail service
- **Data Structure Support:** Added support for both old and new lesson data structures
- **TypeScript Errors:** Fixed various TypeScript strict mode warnings
- **RTL Support:** Enhanced right-to-left text support for Hebrew interface

---

## 🔧 Mental Coach API Server

### [1.6.1] - 2025-01-27

#### Added
- **check-auth-method endpoint:** הוספת בדיקת isAdmin לתגובה
  - מחזיר שדה isAdmin (true/false) בתגובה
  - משמש לבדיקת הרשאות admin בממשק הניהול לפני התחברות עם SMS

### [1.6.0] - 2025-01-27

#### Added - ניהול שיטות התחברות למשתמשים
- הוספת שדה `allowedAuthMethods` למודל המשתמש עם תמיכה ב: email, sms, google, apple
- הוספת שדה `firebasePhoneNumber` לשמירת מספר טלפון בפורמט E.164
- יכולת עדכון מספר טלפון ב-Firebase Auth דרך ה-API בעת עדכון משתמש
- endpoint חדש `/api/auth/check-auth-method` לבדיקת שיטת התחברות מורשית

### [1.5.1] - 2025-01-23

#### Fixed
- **נתיב `/api/training-programs/{id}/lessons`** מחזיר כעת רשימה בסיסית של שיעורים לכל המשתמשים
- הפרדה בין סוגי גישה: רשימת שיעורים (זמין לכולם) vs תוכן מפורט (לפי הרשאות)
- הוספת שדה `hasAccess` לכל שיעור ברשימה

### [1.5.0] - 2025-01-23

#### Added
- **יצירת קולקשן Postman מלא** עם כל הקריאות במערכת
- **מדריך אימות מפורט** (`Authentication-Guide.md`)
- **נתיב `/api/lessons`** עם פונקציונליות מלאה
- תמיכה אוטומטית בשמירה וניהול טוקני אימות בקולקשן

### [1.1.0] - 2024-01-17

#### הוספות חדשות 🚀
- **מערכת קורסים דיגיטליים מלאה** - תשתית חדשה לניהול תוכניות אימון מנטלי
  - מודל TrainingProgram - ניהול תוכניות אימון עם קטגוריות, רמות קושי והרשאות גישה
  - מודל Lesson - ניהול שיעורים עם תמיכה בוידאו, אודיו ומסמכים
  - מודל LessonExercise - תרגילים מגוונים (שאלונים, קלט טקסט, רפלקציה, תוכנית פעולה, ויזואליזציה)
  - עדכון מודל User - הוספת מערך mentalTrainingProgress למעקב התקדמות

#### Controllers חדשים 🎮
- `training-program-controller.ts` - ניהול תוכניות אימון (CRUD, פרסום, סטטיסטיקות)
- `lesson-controller.ts` - ניהול שיעורים (CRUD, התחלת שיעור, עדכון התקדמות)
- `exercise-controller.ts` - ניהול תרגילים (CRUD, שליחת תשובות, חישוב ציונים)
- `user-progress-controller.ts` - ניהול התקדמות משתמש (הרשמה, מעקב, דוחות)

#### Routes חדשים 🛣️
- `/api/training-programs` - ניהול תוכניות אימון
- `/api/lessons` - ניהול שיעורים
- `/api/exercises` - ניהול תרגילים
- `/api/user/training-*` - ניהול התקדמות משתמש

#### Middleware חדש 🔒
- `trainingAuthMiddleware.ts` - בדיקות הרשאות מתקדמות לתוכניות, שיעורים ותרגילים

### [01.07.2025] - Full Lessons Data Integration

#### Added
- **הוספת כל 24 השיעורים של תוכנית "מנטליות של ווינר I" למסד הנתונים**
- יצירת קובץ `scripts/training-lessons-data.mjs` עם כל נתוני השיעורים המלאים
- עדכון סקריפט `seed-real-training-data.mjs` להכנסת גם השיעורים למסד
- הוספת סקריפט `seed:real-training` ל-package.json

### [22.01.2025] - Data Integration & API Fixes

#### Added
- הוספת לוגים מפורטים לדיבוג בעיות API
- הוספת רשימת נתיבים זמינים בהודעת 404
- הוספת redirects אוטומטיים מנתיבים ללא `/api` לנתיבים עם `/api`
- **הטמעת נתונים אמיתיים לתוכניות אימון:**
  - תוכנית "מנטליות של ווינר I - המעטפת המנטלית" עם 24 שיעורים
  - שיעור מבוא מלא עם הסבר על השימוש בתוכנית
  - שיעורים 1-3 עם תוכן מפורט כולל וידאו מ-Vimeo, מדיטציות ותרגילים
  - שיעור 14 מלא על התמודדות עם פחד מדעת אחרים

### [2025-01-02] - תיקון בעיית JSON Parsing

#### תוקן
- תיקון בעיית parsing כאשר האפליקציה שולחת `null` בתור body בבקשות POST
- הוספת middleware מותאם אישית ב-server.ts שמטפל ב-JSON לא תקין
- הוספת בדיקת body ריק בפונקציה startLesson
- תיקון בעיית "user.save is not a function" על ידי טעינת המשתמש המלא מהמסד נתונים
- תיקון בעיית אימות Firebase - הסרת "Bearer " prefix מהטוקן לפני פירוש

### [יום שני, 27 בינואר 2025]

#### ✅ הוספת endpoint לקבלת כל תשובות המשתמש
- נתיב חדש: GET /api/user/exercise-responses
- החזרת כל התשובות של המשתמש מכל התוכניות
- פרטים מלאים כולל: תוכנית, שיעור, תרגיל, תשובות, ציון וזמן
- מיון לפי תאריך השלמה (החדשות קודם)

---

## 📋 קרדיטים
פותח על ידי [עמית טרבלסי](https://amit-trabelsi.co.il)

---

*עדכון אחרון: 27 בינואר 2025*