# מדריך סקריפטים - Mental Coach API

> מדריך מפורט לכל סקריפטי הניהול והתחזוקה במערכת

## 📋 רשימת סקריפטים

### 🏃‍♂️ סקריפטי פיתוח

| Script | Command | Description |
|--------|---------|-------------|
| **Development** | `npm run dev` | הרצת שרת פיתוח עם nodemon + ts-node |
| **Fresh Start** | `npm run dev:fresh` | הרצה טרייה - kill port + dev |
| **Build** | `npm run build` | קומפילציה ל-JavaScript (dist/) |
| **Production** | `npm start` | הרצת שרת פרודקשן (מקובץ מקומפל) |
| **Kill Port** | `npm run kill-port` | סגירת תהליך על הפורט המוגדר |

### 👥 סקריפטי משתמשים

#### `create-user.mjs`
**מטרה:** יצירת משתמש חדש במערכת
```bash
npm run create-user
```
**תלויות:**
- MongoDB connection
- Firebase Admin SDK
- Interactive terminal (inquirer)

**מה הסקריפט עושה:**
1. מתחבר למסד הנתונים
2. מבקש פרטי משתמש (שם, אימייל, טלפון, etc.)
3. יוצר משתמש חדש ב-MongoDB
4. מדפיס פרטי המשתמש החדש

#### `make-user-admin.mjs`
**מטרה:** הפיכת משתמש קיים למנהל מערכת
```bash
npm run make-user-admin
```
**תלויות:**
- MongoDB connection
- User ID או email של המשתמש

**מה הסקריפט עושה:**
1. מחפש משתמש לפי ID או email
2. משנה את role ל-admin (role: 0)
3. שומר את השינויים במסד הנתונים

### 🔐 סקריפטי אבטחה

#### `app-token-generator.mjs`
**מטרה:** יצירת טוקן אימות ל-External API
```bash
npm run app-token-generator
```
**תלויות:**
- APP_TOKEN_SECRET environment variable
- JWT library

**מה הסקריפט עושה:**
1. יוצר JWT token עם payload מותאם
2. משתמש ב-APP_TOKEN_SECRET לחתימה
3. מדפיס את הטוקן לשימוש ב-API חיצוני

#### `test-otp.mjs`
**מטרה:** בדיקת מערכת SMS/OTP
```bash
npm run test-otp
```
**תלויות:**
- Twilio credentials (SID, Token, Phone)
- MongoDB connection

**מה הסקריפט עושה:**
1. שולח SMS בדיקה
2. בודק קבלת הקוד
3. מאמת את מערכת ה-OTP

### 📚 סקריפטי תוכן

#### `seed-training.mjs`
**מטרה:** זריעת תוכן אימון בסיסי (לפיתוח)
```bash
npm run seed-training
```
**תלויות:**
- MongoDB connection
- Training program data structure

**מה הסקריפט עושה:**
1. יוצר תוכניות אימון דמיים
2. מוסיף שיעורים ותרגילים בסיסיים
3. מגדיר קשרים בין הרכיבים

#### `seed:real-training`
**מטרה:** זריעת נתוני אימון אמיתיים
```bash
npm run seed:real-training
```
**תלויות:**
- MongoDB connection  
- Real training data files
- Admin permissions

**מה הסקריפט עושה:**
1. טוען תוכן אימון אמיתי
2. יוצר מבנה קורסים מלא
3. מגדיר הרשאות גישה

### 🧹 סקריפטי ניקוי

#### `reset-matches`
**מטרה:** ניקוי נתוני משחקים של משתמשים
```bash
npm run reset-matches
```
**תלויות:**
- MongoDB connection
- Backup confirmation

**מה הסקריפט עושה:**
1. מוחק את כל רשומות המשחקים
2. מאפס סטטיסטיקות קשורות
3. שומר backup אוטומטי

#### `reset-profile-marks`
**מטרה:** איפוס התקדמות פרופילים
```bash
npm run reset-profile-marks
```
**תלויות:**
- MongoDB connection
- User progress models

**מה הסקריפט עושה:**
1. מאפס התקדמות בקורסים
2. מוחק ציונים ופיתוח
3. משמיר נתוני משתמש בסיסיים

## 🔧 סקריפטים מתקדמים

### תלויות טכניות

#### MongoDB Scripts
כל הסקריפטים דורשים:
```javascript
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();
const MONGO_URI = process.env.MONGO_URI_DEV;
const DB_NAME = process.env.DB_NAME;
```

#### Firebase Scripts  
סקריפטים עם Firebase דורשים:
```javascript
import admin from 'firebase-admin';

// Initialize Firebase Admin
if (\!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      private_key: process.env.FIREBASE_PRIVATE_KEY,
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      project_id: process.env.FIREBASE_PRIVATE_ID,
    })
  });
}
```

### הרצה בטוחה

#### Pre-run Checklist
לפני הרצת סקריפטים:
1. ✅ וודא חיבור למסד נתונים
2. ✅ בדק משתני סביבה נדרשים  
3. ✅ צור backup אם נדרש
4. ✅ הרץ בסביבת פיתוח קודם

#### Error Handling
כל הסקריפטים כוללים:
```javascript
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('SIGINT', async () => {
  console.log('\nGracefully closing...');
  await mongoose.connection.close();
  process.exit(0);
});
```

## 📝 דוגמאות שימוש

### יצירת משתמש ראשון
```bash
# 1. יצירת משתמש
npm run create-user
# הכנס פרטים: שם, מייל, טלפון

# 2. הפיכה למנהל
npm run make-user-admin  
# הכנס email של המשתמש

# 3. זריעת תוכן בסיסי
npm run seed-training
```

### הגדרת מערכת SMS
```bash
# 1. וודא הגדרת Twilio ב-.env
TWILIO_ACCOUNT_SID=ACxxxxx
TWILIO_AUTH_TOKEN=xxxxx  
TWILIO_PHONE_NUMBER=+972xxxxxx

# 2. בדיקת המערכת
npm run test-otp
```

### איפוס נתונים לפיתוח
```bash
# איפוס משחקים
npm run reset-matches

# איפוס התקדמות
npm run reset-profile-marks

# זריעת תוכן חדש
npm run seed-training
```

## ⚠️ אזהרות חשובות

### 🚫 אל תריץ בפרודקשן
הסקריפטים הבאים מסוכנים בפרודקשן:
- `reset-matches` - מוחק נתונים אמיתיים
- `reset-profile-marks` - מאפס התקדמות משתמשים
- `seed-training` - עלול לדרוס תוכן אמיתי

### ✅ בטיחות קודם
```bash
# תמיד גבה את הנתונים קודם
mongodump --uri="$MONGO_URI_DEV" --out=backup-$(date +%Y%m%d)

# הרץ באמצעות NODE_ENV=development
NODE_ENV=development npm run reset-matches
```

### 📋 לוג אירועים
כל הסקריפטים יוצרים לוגים ב:
- `logs/script-execution.log`
- Console output
- MongoDB operation logs

## 🔗 קישורים נוספים

- [API Documentation](./api/EXTERNAL_API_DOCUMENTATION.md)
- [Deployment Guide](./deployment/RAILWAY_DEPLOYMENT.md)  
- [Environment Setup](../README.md#משתני-סביבה)

---

> **💡 טיפ:** השתמש ב-`npm run dev:fresh` כשאתה רוצה להתחיל מחדש עם פורט נקי