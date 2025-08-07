# Changelog

## [1.4.0] - 2025-01-27

### Added
- **LoginPage - אפשרויות התחברות מרובות**:
  - הוספת 3 אפשרויות התחברות: Google, אימייל וסיסמה, SMS
  - ממשק טאבים לבחירת שיטת התחברות
  - התחברות עם אימייל וסיסמה דרך Firebase Auth
  - התחברות עם SMS - שליחת קוד אימות ואימות
  - בדיקה אוטומטית שהמשתמש הוא admin (role = 0) בכל שיטות ההתחברות
  - הודעות שגיאה ברורות אם המשתמש אינו admin
  - תמיכה ב-reCAPTCHA עבור אימות SMS

### Technical Details
- שימוש ב-Material-UI Tabs לניווט בין שיטות התחברות
- שימוש ב-Firebase Auth methods: signInWithEmailAndPassword, signInWithPhoneNumber
- בדיקת הרשאות דרך Firebase ID Token Claims
- שימוש ב-check-auth-method endpoint לבדיקת הרשאות SMS והאם המשתמש admin

## [1.3.4] - 2025-01-27

### Fixed
- **UserDialog**: תיקון בעיית שמירה בטופס עריכת משתמש - הטופס לא ביצע פעולה בלחיצה על כפתור השמירה
  - תיקון הגדרת ה-onSubmit function
  - עדכון ה-form element להשתמש ב-handleSubmit מ-react-hook-form
  - הוספת debug logs לזיהוי בעיות validation
- **UserDialog**: הסרת החובה משדה "טלפון וואטסאפ של המאמן"
  - יצירת yupPhoneSchema_optional חדש ב-validators עם תמיכה בערכים ריקים
  - עדכון שדה coachWhatsappNumber להשתמש ב-schema האופציונלי
  - שינוי שדה הטלפון הרגיל להיות אופציונלי גם כן
- **UserDialog**: תיקון ברירת מחדל של isAdmin
  - הגדרת isAdmin כ-false במצב יצירת משתמש חדש
  - תיקון הלוגיקה בעדכון משתמש קיים - isAdmin נקבע לפי role === 0

## [1.3.3] - 2025-01-27

### Added
- **UserDialog - המרת טלפון אוטומטית**:
  - המרה אוטומטית של מספרי טלפון ישראליים לפורמט בינלאומי (+972)
  - עדכון אוטומטי של שדה Firebase Phone Number כשמזינים מספר בשדה הטלפון הרגיל
  - סימון אוטומטי של אפשרות התחברות עם SMS כשיש מספר טלפון בפיירבייס

### Changed
- **UserDialog**:
  - הסרת החובה משדה "טלפון וואטסאפ של המאמן" - השדה הופך לאופציונלי

### Technical Details
- הוספת פונקציה להמרת מספרי טלפון ישראליים (05X-XXXXXXX) לפורמט E.164 (+972XXXXXXXXX)
- שימוש ב-watch של react-hook-form למעקב אחר שינויים בשדה הטלפון
- עדכון אוטומטי של allowedAuthMethods.sms = true כשיש מספר Firebase

## [1.3.2] - 2025-01-27

### Added
- **UsersPage - פעולות מרובות**:
  - הוספת יכולת לבחור מספר משתמשים בו-זמנית באמצעות checkboxes
  - כפתור למחיקת כל המשתמשים המסומנים עם דיאלוג אישור
  - כפתור לשינוי סוג מנוי לכל המשתמשים המסומנים
  - דיאלוג לבחירת סוג המנוי החדש (בסיסי/מתקדם/פרימיום)
  - הודעות הצלחה/שגיאה לאחר ביצוע הפעולות

### Technical Details
- שימוש ב-GridRowSelectionModel לניהול הבחירה המרובה
- ביצוע פעולות מרובות במקביל עם Promise.all
- מניעת פתיחת דיאלוג עריכה בלחיצה על checkbox

## [1.3.1] - 2025-01-27

### Changed
- **UsersPage**: 
  - הוספת עמודת טלפון בטבלת המשתמשים עם הצגת "חסר" במקרה שאין מספר
  - הסרת אייקון Apple משיטות ההתחברות (לא רלוונטי)
  - הוספת יכולת לחיצה על שורה בטבלה לפתיחת דיאלוג עריכה
  - הוספת סמן עכבר והדגשה בעת מעבר מעל שורות בטבלה

## [1.3.0] - 2025-01-27

### Added
- **ניהול שיטות התחברות למשתמשים:**
  - הוספת שדות חדשים בדיאלוג עריכת משתמש:
    - מספר טלפון בפיירבייס (בפורמט בינלאומי E.164)
    - בחירת שיטות התחברות מורשות: אימייל, SMS, Google, Apple
  - הצגת אייקונים של שיטות התחברות מורשות בטבלת המשתמשים
  - ולידציה של פורמט מספר טלפון בינלאומי
  - עדכון אוטומטי של מספר הטלפון ב-Firebase Auth בעת שמירה

### Changed
- **UserDialog**: הוספת סעיף "הגדרות התחברות" עם שדות חדשים
- **UsersPage**: הוספת עמודה חדשה להצגת שיטות התחברות מורשות עם אייקונים

### Technical Details
- תמיכה בפורמט E.164 למספרי טלפון (+972501234567)
- סנכרון אוטומטי עם Firebase Auth API
- ברירת מחדל: email, Google ו-Apple מורשים, SMS לא מורשה

## [Unreleased] - 2025-01-30

### Added
- **Image Upload Component**: New `ImageUpload.tsx` component for uploading images to Firebase Storage
- **Lesson Thumbnail Upload**: Replaced URL input with file upload for lesson thumbnails
- **Firebase Storage Integration**: Enhanced storage service with progress tracking and error handling
- **Image Preview**: Real-time preview of uploaded images with proper aspect ratio
- **File Validation**: Type and size validation for uploaded images
- **Drag & Drop Lesson Ordering**: New `SortableLessonsList.tsx` component for reordering lessons
- **Lesson Order API**: Server endpoint for updating lesson order with drag & drop functionality

### Changed
- **LessonEditDrawer**: Updated to use new ImageUpload component instead of URL input field
- **Firebase Storage Service**: Enhanced with upload progress tracking and better error handling
- **Exercise Display**: Improved ExercisesList component with better type handling
- **TrainingProgramsPage**: Replaced static lessons table with sortable drag & drop interface

### Fixed
- **Video Preview**: Fixed Vimeo video preview using external thumbnail service
- **Data Structure Support**: Added support for both old and new lesson data structures
- **TypeScript Errors**: Fixed various TypeScript strict mode warnings
- **RTL Support**: Enhanced right-to-left text support for Hebrew interface

### Technical Details
- Uses Firebase Storage for file hosting
- Supports JPG, PNG, GIF, WebP image formats
- Maximum file size: 10MB for images
- Automatic filename sanitization and unique naming
- Progress tracking with Material-UI components
- Maintains backward compatibility with existing URL-based thumbnails
- Drag & drop functionality using @dnd-kit/core library
- Real-time lesson order updates with server synchronization
- Visual feedback during drag operations with smooth animations

### Files Modified
- `src/components/general/ImageUpload.tsx` - New component
- `src/components/drawers/LessonEditDrawer.tsx` - Updated to use ImageUpload
- `src/services/firebaseStorage.ts` - Enhanced storage utilities
- `src/components/general/ExercisesList.tsx` - Improved type handling
- `src/components/general/SortableLessonsList.tsx` - New drag & drop component
- `src/pages/TrainingProgramsPage/TrainingProgramsPage.tsx` - Updated to use SortableLessonsList
- `src/services/coursesApi.ts` - Added updateLessonsOrder function
- `mental-coach-api/controllers/lesson-controller.ts` - Added updateLessonsOrder endpoint
- `mental-coach-api/routes/lessonRoutes.ts` - Added /reorder route
- `CLAUDE.md` - Updated documentation

### Known Issues
- Some TypeScript strict mode warnings (handled with eslint-disable)
- Exercise type definitions need refinement for better type safety
- Legacy components may need TypeScript updates

---

## Previous Updates

### Video Display Improvements
- Fixed video preview for Vimeo videos without API authentication
- Added support for both old and new lesson data structures
- Enhanced VideoPreview component with external thumbnail service

### Exercise Management
- Developed comprehensive ExercisesList component
- Added support for different exercise types (text_input, questionnaire, action_plan)
- Integrated with lesson editing workflow
- Added proper error handling and loading states # שינויים שבוצעו במערכת ניהול המאמן המנטלי

## תאריך: היום

### 1. שינוי כותרת האפליקציה ✅
- שונה השם מ"מנטלי בכיס" ל"ניהול - המאמן המנטלי" בכל המקומות:
  - `index.html` - כותרת הדפדפן
  - `AppDrawer.tsx` - כותרת בתפריט הצדדי
  - `LoginPage.tsx` - כותרת בדף ההתחברות

### 2. העברת כפתורי ההוספה ✅
- כפתורי ההוספה (FAB) הועברו מהפינה התחתונה הימנית לפינה העליונה השמאלית
- קובץ: `components/general/AppFab.tsx`
- שינויים: position מ-bottom/right ל-top/left עם zIndex גבוה

### 3. הוספת שדה "מזהה עסקה" למשתמש ✅
- **API:**
  - `models/user-model.ts` - הוספת השדה ל-Interface ול-Schema
  - שדה אופציונלי מסוג string
- **Admin:**
  - `utils/types.ts` - הוספת השדה לטייפ User
  - `components/dialogs/UserDialog.tsx` - הוספת שדה בטופס עריכת משתמש

### 4. הצגת גרסת API בפוטר ✅
- נוצר פוטר חדש בקובץ `layouts/Footer.tsx`
- מציג "גרסת API: 1.0.0" בתחתית המסך
- הפוטר קבוע בתחתית העמוד עם רקע לבן

### 5. קרדיט בתפריט הצדדי ✅
- הוסף בתחתית ה-`AppDrawer.tsx`
- מציג "פותח על ידי עמית טרבלסי" עם לינק לאתר האישי
- ממוקם בתחתית התפריט הצדדי

### 6. מערכת תמיכה מלאה ✅
#### API:
- **קובץ חדש:** `controllers/support-controller.ts`
  - פונקציה לשליחת פנייה לתמיכה במייל
  - שליחת מייל ל-amit@trabel.si
  - שליחת אישור למשתמש הפונה
- **קובץ חדש:** `routes/supportRoutes.ts`
  - ראוט POST `/api/support`
  - דורש אימות משתמש
- **עדכון:** `server.ts` - הוספת הראוט למערכת

#### ממשק ניהול:
- **קובץ חדש:** `components/dialogs/SupportDialog.tsx`
  - טופס תמיכה מלא עם:
    - שדה נושא ותיאור
    - העלאת קבצים (עד 5)
    - מידע אוטומטי על המשתמש, העמוד הנוכחי, ודיאלוגים פתוחים
    - תאריך ושעה
- **עדכון:** `layouts/AppDrawer.tsx`
  - הוספת לינק "צריך עזרה? פנה לתמיכה"
  - ממוקם מעל הקרדיט
- **עדכון:** `layouts/Layout.tsx`
  - הוספת לוגיקה לפתיחת דיאלוג התמיכה
  - זיהוי דיאלוגים פתוחים אוטומטית

## קבצים שנוצרו:
1. `mental-coach-api/controllers/support-controller.ts`
2. `mental-coach-api/routes/supportRoutes.ts`
3. `mental-coach-admin/src/components/dialogs/SupportDialog.tsx`
4. `mental-coach-admin/CHANGELOG_NEW.md` (קובץ זה)

## קבצים שעודכנו:
1. `mental-coach-admin/index.html`
2. `mental-coach-admin/src/layouts/AppDrawer.tsx`
3. `mental-coach-admin/src/pages/LoginPage.tsx`
4. `mental-coach-admin/src/components/general/AppFab.tsx`
5. `mental-coach-api/models/user-model.ts`
6. `mental-coach-admin/src/utils/types.ts`
7. `mental-coach-admin/src/components/dialogs/UserDialog.tsx`
8. `mental-coach-admin/src/layouts/Footer.tsx`
9. `mental-coach-api/server.ts`
10. `mental-coach-admin/src/layouts/Layout.tsx`