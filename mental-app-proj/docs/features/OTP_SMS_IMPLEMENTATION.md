# 📱 מימוש מערכת התחברות SMS עם Twilio + Firebase

## 🎯 סקירה כללית

מערכת התחברות היברידית המשלבת:
- **Twilio** - לשליחת SMS עם קודי OTP
- **Firebase Custom Tokens** - לניהול sessions
- **MongoDB** - לשמירת נתוני משתמשים

## ✅ מה יצרנו

### צד שרת (Node.js/Express)
1. **מודל OTP** (`models/otp-model.ts`)
   - שמירת קודים עם תוקף 5 דקות
   - הגבלת 3 ניסיונות
   - מחיקה אוטומטית אחרי 10 דקות

2. **שירות Twilio** (`services/twilio-service.ts`)
   - שליחת SMS
   - יצירת קודי OTP (6 ספרות)
   - תמיכה במספרים ישראליים

3. **Controller + Routes** (`controllers/otp-controller.ts`)
   - `/api/otp/send` - שליחת קוד
   - `/api/otp/verify` - אימות וקבלת Firebase Token
   - `/api/otp/resend` - שליחה חוזרת
   - `/api/otp/status` - בדיקת סטטוס

### צד קליינט (Flutter)
1. **שירות OTP** (`service/otp_service.dart`)
   - ממשק לתקשורת עם ה-API
   - פורמט מספרים ישראליים
   - ניהול session

2. **מסך התחברות SMS** (`screens/login/phone_login_new.dart`)
   - הזנת מספר טלפון
   - אפשרות להוסיף אימייל
   - תמיכה במצב פיתוח

3. **מסך אימות OTP** (`screens/login/otp_verification_screen.dart`)
   - 6 שדות להזנת קוד
   - טיימר לשליחה חוזרת (60 שניות)
   - אימות אוטומטי בהשלמת הקוד
   - תמיכה ב-paste

## 🚀 הוראות הפעלה

### 1. הגדרת Twilio

הוסף לקובץ `.env` בתיקיית `mental-coach-api`:

```bash
# Twilio Configuration
TWILIO_ACCOUNT_SID=your_twilio_account_sid_here
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_PHONE_NUMBER=your_twilio_phone_number_here
```

### 2. הפעלת השרת

```bash
cd mental-coach-api
npm install
npm run dev
```

### 3. הפעלת האפליקציה

```bash
cd mental-coach-flutter
flutter run
```

### 4. גישה למסך החדש

נווט ל-`/phone-login-new` באפליקציה

## 🧪 בדיקות

### בדיקה בשורת הפקודה:
```bash
cd mental-coach-api
npm run test-otp
```

### בדיקה ב-curl:
```bash
# שליחת OTP
curl -X POST http://localhost:3000/api/otp/send \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"0501234567"}'

# אימות קוד
curl -X POST http://localhost:3000/api/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"+972501234567","code":"123456"}'
```

## 🔧 מצב פיתוח

כשאין הגדרות Twilio:
- המערכת עובדת במצב פיתוח
- הקוד מוחזר בתגובת ה-API
- הקוד מוצג על המסך באפליקציה
- אין שליחת SMS בפועל

## 📊 תכונות מרכזיות

### אבטחה:
- ✅ הגבלת קצב - דקה בין בקשות
- ✅ מקסימום 3 ניסיונות לקוד
- ✅ תוקף קוד: 5 דקות
- ✅ מחיקה אוטומטית אחרי 10 דקות
- ✅ שמירת IP ו-User Agent

### חוויית משתמש:
- ✅ אימות אוטומטי בהשלמת קוד
- ✅ תמיכה ב-paste
- ✅ טיימר לשליחה חוזרת
- ✅ הודעות שגיאה ברורות
- ✅ מצב פיתוח למפתחים

### אינטגרציה:
- ✅ יצירת משתמש Firebase אוטומטית
- ✅ שמירת נתונים ב-MongoDB
- ✅ Custom Claims ל-Firebase
- ✅ תמיכה במספרים ישראליים

## 🔍 Troubleshooting

### בעיה: לא מגיעים SMS
- בדוק שה-credentials נכונים
- בדוק יתרת קרדיטים ב-Twilio
- בדוק שהמספר מאומת ב-Twilio (במצב Trial)

### בעיה: שגיאה באימות
- בדוק שה-Firebase Service Account מוגדר
- בדוק חיבור ל-MongoDB
- בדוק שהשרת רץ

### בעיה: קוד לא נכון
- בדוק שהקוד הוזן תוך 5 דקות
- בדוק שלא עברת 3 ניסיונות
- נסה לשלוח קוד חדש

## 📝 הערות

1. **עלויות Twilio**: כל SMS עולה כסף - השתמש במצב פיתוח לבדיקות
2. **מספרי Trial**: ב-Twilio Trial אפשר לשלוח רק למספרים מאומתים
3. **Firebase**: דורש Service Account עם הרשאות מתאימות
4. **Production**: מומלץ להוסיף Redis לניהול rate limiting

## 🎉 סיום

המערכת מוכנה לשימוש! 

לבדיקה מהירה:
1. הפעל את השרת
2. פתח את האפליקציה
3. נווט ל-`/phone-login-new`
4. הזן מספר טלפון
5. קבל קוד (במצב פיתוח יוצג על המסך)
6. הזן את הקוד
7. התחבר בהצלחה!

---
פותח על ידי עמית טרבלסי
https://amit-trabelsi.co.il