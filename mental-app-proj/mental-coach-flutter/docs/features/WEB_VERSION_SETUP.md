# הגדרת גרסת הווב של האפליקציה

## תאריך: 27/01/2025

### סיכום השינויים:

1. **תיקון בעיית CORS**
   - הוספת זיהוי פלטפורמה ב-`platform_utils.dart`
   - עדכון `EnvironmentConfig` לשימוש ב-localhost בווב
   - יצירת סקריפט הרצה `run-web-local.sh`

2. **פתרון זמני להתחברות בווב**
   - יצירת מסך התחברות חלופי `WebLoginScreen` עם אימייל וסיסמה
   - עדכון הראוטר להשתמש במסך החדש בווב
   - השבתת אימות טלפון בווב (דורש RecaptchaVerifier מורכב)

3. **עדכון כותרת האתר**
   - שינוי ל-"המאמן המנטלי | איתן עזריה"

4. **שינוי פורטים**
   - Admin Panel: 9977 (במקום 5173)
   - API Server: 3000 (ללא שינוי)

### איך להריץ את גרסת הווב:

1. **הפעל את השרת ב-development mode:**
   ```bash
   cd mental-coach-api
   npm run dev
   ```

2. **הרץ את האפליקציה בווב:**
   ```bash
   cd mental-coach-flutter
   ./run-web-local.sh
   ```
   או:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

### הערות חשובות:

- **התחברות בווב**: השתמש באימייל וסיסמה (לא מספר טלפון)
- **משתמשי בדיקה**: צריך ליצור משתמשים עם אימייל וסיסמה ב-Firebase Console
- **CORS**: השרת חייב לרוץ ב-development mode
- **כתובות**:
  - אפליקציה: http://localhost:8080
  - API: http://localhost:3000
  - Admin: http://localhost:9977

### מגבלות גרסת הווב:

1. אימות טלפון לא נתמך (דורש RecaptchaVerifier מורכב)
2. חלק מהפיצ'רים עלולים לא לעבוד (הודעות push, רכישות in-app)
3. מיועד לפיתוח ובדיקות בלבד

### קבצים שנוצרו/עודכנו:

- `lib/utils/platform_utils.dart` - זיהוי פלטפורמה
- `lib/config/environment_config.dart` - תמיכה ב-localhost בווב
- `lib/screens/login/web_login_screen.dart` - מסך התחברות לווב
- `lib/routes/app_router.dart` - ניתוב מותאם לווב
- `lib/service/auth.dart` - השבתת אימות טלפון בווב
- `web/index.html` - עדכון כותרת
- `run-web-local.sh` - סקריפט הרצה