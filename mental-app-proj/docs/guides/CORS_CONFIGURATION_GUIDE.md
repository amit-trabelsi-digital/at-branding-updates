# 🔐 מדריך הגדרות CORS לסביבות שונות

## 📋 סקירה כללית

מסמך זה מסביר כיצד להגדיר ולנהל CORS (Cross-Origin Resource Sharing) עבור פרויקט Mental Coach בסביבות שונות.

## 🎯 הבעיה

כאשר אפליקציית Flutter רצה בדפדפן (Web) ומנסה לגשת ל-API שרץ על דומיין אחר, הדפדפן חוסם את הבקשה מטעמי אבטחה (CORS policy).

### שגיאות נפוצות:
```
Access to fetch at 'https://app-srv.eitanazaria.co.il/api/...' from origin 'http://localhost:5858' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## 🛠️ הפתרון המלא

### 1. הגדרות בצד השרת (API)

#### קובץ הגדרות CORS מודולרי
נוצר קובץ `mental-coach-api/config/cors.config.ts` שמכיל:
- **תמיכה אוטומטית בכל סאב-דומיין תחת `eitanazaria.co.il`** 🎯
- בדיקה דינמית של דומיינים מורשים
- תמיכה אוטומטית ב-localhost בסביבת פיתוח
- טיפול ב-preflight requests
- הגדרות headers מתקדמות

#### דומיינים מורשים אוטומטית:
- ✅ `*.eitanazaria.co.il` - כל סאב-דומיין (כולל multi-level)
- ✅ `localhost` - לפיתוח מקומי
- ✅ `127.0.0.1` - לפיתוח מקומי
- ✅ `10.0.2.2` - Android emulator

דוגמאות לסאב-דומיינים שיעבדו אוטומטית:
- `https://app.eitanazaria.co.il`
- `https://admin.mental.eitanazaria.co.il`
- `https://dev.api.mntl.eitanazaria.co.il`
- כל סאב-דומיין חדש שייווצר בעתיד!

#### שימוש ב-server.ts
```typescript
import corsOptions, { handlePreflight } from "./config/cors.config";

// הוספת middleware לטיפול ב-preflight
app.use(handlePreflight);

// הגדרות CORS
app.use(cors(corsOptions));
```

### 2. הגדרות בצד הלקוח (Flutter)

#### עדכון environment_config.dart
- תמיכה בכתובות שונות לפי פלטפורמה
- `10.0.2.2` עבור אמולטור Android
- `localhost` עבור iOS Simulator
- כתובת IP מקומית למכשירים פיזיים

### 3. הרצה עם CORS

#### שימוש בסקריפט המיוחד
```bash
# הרצה מקומית עם Chrome
./scripts/run-with-cors.sh local chrome

# הרצה מול שרת פיתוח
./scripts/run-with-cors.sh dev chrome

# הרצה מול production
./scripts/run-with-cors.sh prod chrome
```

## 📱 הגדרות לפי פלטפורמה

### Web (Chrome/Edge)
```bash
# הרצה עם CORS מושבת (לפיתוח בלבד!)
flutter run -d chrome \
  --web-browser-flag "--disable-web-security" \
  --web-browser-flag "--user-data-dir=/tmp/chrome_dev"
```

### Android Emulator
- השרת המקומי נגיש דרך `10.0.2.2:3000`
- אין צורך בהגדרות CORS מיוחדות

### iOS Simulator
- השרת המקומי נגיש דרך `localhost:3000`
- אין צורך בהגדרות CORS מיוחדות

### מכשירים פיזיים
1. וודאו שהמכשיר והמחשב באותה רשת
2. מצאו את ה-IP המקומי:
   ```bash
   # Mac/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```
3. עדכנו את `localIp` ב-`environment_config.dart`

## 🔧 משתני סביבה

### בשרת API
```bash
# .env
NODE_ENV=development
ALLOW_LOCAL_CORS=true
ADDITIONAL_CORS_ORIGINS=http://192.168.1.100:3000,http://192.168.1.101:5173
```

### ב-Flutter
הגדרה דרך dart-define:
```bash
flutter run --dart-define=ENVIRONMENT=dev
```

## 🐛 פתרון בעיות

### 1. בעיית CORS בדפדפן
**סימפטום**: שגיאות CORS בקונסול של הדפדפן

**פתרון**:
1. וודאו שהשרת רץ עם הגדרות CORS נכונות
2. השתמשו בסקריפט `run-with-cors.sh`
3. בדקו שה-origin מופיע ברשימה המותרת

### 2. Connection Refused
**סימפטום**: `Failed to connect to localhost:3000`

**פתרון**:
1. וודאו שהשרת רץ
2. בדקו את הכתובת בהתאם לפלטפורמה
3. עבור Android Emulator: השתמשו ב-`10.0.2.2`

### 3. Network Error במכשיר פיזי
**סימפטום**: האפליקציה לא מצליחה להתחבר לשרת

**פתרון**:
1. וודאו שהמכשיר והמחשב באותה רשת WiFi
2. בדקו את ה-IP המקומי
3. וודאו שהפיירוול מאפשר חיבורים בפורט 3000

## 📝 דוגמאות קוד

### הוספת headers מותאמים אישית ב-Flutter
```dart
import 'package:mental_coach_app/config/environment_config.dart';

final headers = {
  'Content-Type': 'application/json',
  ...EnvironmentConfig.instance.additionalHeaders,
};
```

### בדיקת סביבה נוכחית
```dart
// בדיקה איזו סביבה פעילה
if (EnvironmentConfig.environment == Environment.local) {
  print('Running on local server');
}

// קבלת URL השרת
final apiUrl = EnvironmentConfig.instance.serverURL;
```

## 🚀 המלצות לייצור

1. **אל תשביתו CORS בייצור** - זה פותח פרצות אבטחה
2. **הגדירו רשימה מדויקת של origins מותרים**
3. **השתמשו ב-HTTPS תמיד בייצור**
4. **הגבילו את ה-methods וה-headers המותרים**

## 📚 קישורים נוספים

- [MDN - CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web CORS](https://docs.flutter.dev/development/platform-integration/web/faq#how-do-i-enable-cors)
- [Express CORS Middleware](https://github.com/expressjs/cors)

---
תאריך עדכון: 08/01/2025
נוצר על ידי: אמית טרבלסי