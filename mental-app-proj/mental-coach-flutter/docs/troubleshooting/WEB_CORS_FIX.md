# תיקון בעיית CORS בגרסת הווב

## תאריך: 27/01/2025

### הבעיה:
כאשר האפליקציה רצה בדפדפן, היא מנסה לגשת ל-API דרך כתובת IP מקומית (192.168.0.153:3000) וזה גורם לבעיית CORS.

### הפתרון:

1. **יצירת קובץ עזר לזיהוי פלטפורמה**
   - נוצר `lib/utils/platform_utils.dart`
   - מספק פונקציות לזיהוי אם האפליקציה רצה בווב, מובייל או דסקטופ

2. **עדכון EnvironmentConfig**
   - הוספת בדיקה אם רצים בווב
   - בווב - שימוש ב-localhost במקום IP
   - במובייל/דסקטופ - שימוש ב-IP המקומי

3. **יצירת סקריפט הרצה לווב**
   - `run-web-local.sh` - מריץ את האפליקציה בווב עם בדיקה שהשרת רץ

### איך להריץ:

1. **וודא שהשרת רץ ב-development mode:**
   ```bash
   cd mental-coach-api
   npm run dev
   ```

2. **הרץ את האפליקציה בווב:**
   ```bash
   cd mental-coach-flutter
   ./run-web-local.sh
   ```

### הערות חשובות:

- השרת חייב לרוץ ב-development mode כדי ש-CORS יאפשר גישה מ-localhost
- אם עדיין יש בעיות, בדוק את קובץ .env בשרת ווודא ש-NODE_ENV=development
- האפליקציה תרוץ על http://localhost:8080

### קבצים שנוצרו/עודכנו:

1. `lib/utils/platform_utils.dart` - עזר לזיהוי פלטפורמה
2. `lib/config/environment_config.dart` - עדכון לשימוש ב-localhost בווב
3. `run-web-local.sh` - סקריפט הרצה לווב