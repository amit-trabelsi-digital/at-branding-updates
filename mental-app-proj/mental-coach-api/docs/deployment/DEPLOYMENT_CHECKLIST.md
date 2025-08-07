# ✅ Railway Deployment Checklist

## לפני ההעלאה

### 1. בדיקת קוד
- [ ] כל הקוד עובד locally
- [ ] אין שגיאות TypeScript (`npm run build`)
- [ ] ה-OTP service עובד
- [ ] אין קבצים רגישים ב-git

### 2. הכנת משתני סביבה
- [ ] MongoDB connection string (Atlas, לא local)
- [ ] Firebase Service Account JSON
- [ ] SendGrid API Key
- [ ] Twilio Credentials (SID, Token, Phone)
- [ ] EMAIL_FROM address

### 3. GitHub
- [ ] יצרת repository ב-GitHub
- [ ] עשית push לכל הקוד
- [ ] בדקת שאין קבצים רגישים

## בזמן ההעלאה

### 4. Railway Setup
- [ ] יצרת פרויקט חדש
- [ ] חיברת את ה-GitHub repo
- [ ] הוספת את כל משתני הסביבה
- [ ] הגדרת PORT=3000

### 5. בדיקה ראשונית
- [ ] ה-build הצליח
- [ ] השרת עלה
- [ ] בדיקת endpoint: `/api/otp/status`
- [ ] לוגים נקיים משגיאות

## אחרי ההעלאה

### 6. עדכון כתובות
- [ ] עדכנת את Flutter app עם הכתובת החדשה
- [ ] עדכנת את Admin panel עם הכתובת החדשה
- [ ] עדכנת Firebase Authorized domains

### 7. בדיקות סופיות
- [ ] SMS OTP עובד
- [ ] Login עובד
- [ ] API calls עובדים
- [ ] Push notifications (אם רלוונטי)

## בעיות נפוצות ופתרונות

### ❌ Build נכשל
- בדוק שכל ה-dependencies נמצאים ב-package.json
- בדוק שאין שגיאות TypeScript

### ❌ MongoDB connection failed
- וודא שה-IP whitelist פתוח
- בדוק את ה-connection string
- וודא ש-DB_NAME נכון

### ❌ Firebase error
- בדוק שה-Service Account JSON תקין
- וודא שהוא string אחד בלי line breaks

### ❌ Twilio not working
- בדוק שכל ה-3 credentials קיימים
- וודא שהמספר בפורמט +972...

---

## 🚨 במקרה חירום

1. בדוק Logs ב-Railway Dashboard
2. נסה להריץ locally עם אותם env variables
3. WhatsApp: +972506362008

---

*תאריך בדיקה אחרון: 27/01/2025*