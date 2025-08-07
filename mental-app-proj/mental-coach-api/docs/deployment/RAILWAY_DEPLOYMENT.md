# 🚂 העלאת Mental Coach API ל-Railway

## 📋 דרישות מקדימות
- חשבון Railway (railway.app)
- חשבון GitHub מחובר ל-Railway
- MongoDB Atlas או MongoDB מארח חיצוני
- SendGrid API Key
- Twilio Credentials
- Firebase Service Account

## 🔧 שלב 1: הכנת הפרויקט

### קבצים שכבר מוכנים:
✅ `package.json` - עם scripts מתאימים  
✅ `tsconfig.json` - להגדרות TypeScript  
✅ `railway.json` - קונפיגורציית Railway  

### צריך להוסיף ל-`.gitignore`:
```
.env
node_modules/
dist/
.DS_Store
*.log
```

## 🚀 שלב 2: העלאה ל-GitHub

```bash
# אם עדיין לא עשית init
git init

# הוסף את הקבצים
git add .

# עשה commit
git commit -m "Ready for Railway deployment"

# צור repository חדש ב-GitHub ואז:
git remote add origin https://github.com/YOUR_USERNAME/mental-coach-api.git
git branch -M main
git push -u origin main
```

## 🎯 שלב 3: הגדרת Railway

### 1. התחבר ל-Railway
- כנס ל-[railway.app](https://railway.app)
- התחבר עם GitHub

### 2. צור פרויקט חדש
- לחץ על "New Project"
- בחר "Deploy from GitHub repo"
- בחר את הריפו שיצרת: `mental-coach-api`

### 3. הגדר משתני סביבה
לחץ על הפרויקט > Variables > Add Variables:

```env
# MongoDB
DATABASE=mongodb+srv://username:password@cluster.mongodb.net/mental-coach
DB_NAME=mental-coach

# Server Config
PORT=3000
NODE_ENV=production

# Firebase
FIREBASE_SERVICE_ACCOUNT={"type":"service_account","project_id":"...","private_key":"..."}

# SendGrid
SENDGRID_API_KEY=SG.xxxxx
EMAIL_FROM=noreply@mentalcoach.com

# Twilio
TWILIO_ACCOUNT_SID=ACcc378679...
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+972535666773

# API Keys (אם יש)
ANTHROPIC_API_KEY=xxx
PERPLEXITY_API_KEY=xxx
OPENAI_API_KEY=xxx

# URLs
FRONTEND_URL=https://your-app.web.app
ADMIN_URL=https://your-admin.web.app
```

### 4. Deploy!
- Railway יזהה אוטומטית את ה-`railway.json`
- הוא יריץ: `npm install && npm run build`
- ואז יריץ: `npm start`

## 🔍 שלב 4: בדיקה

### בדוק שהשרת עולה:
```bash
curl https://your-app.railway.app/api/otp/status
```

צריך לקבל:
```json
{
  "success": true,
  "service": "Twilio SMS OTP",
  "status": "active",
  "hasCredentials": true,
  "environment": "production"
}
```

## 🌍 שלב 5: עדכון כתובות ב-Flutter

עדכן את `mental-coach-flutter/lib/config/environment_config.dart`:

```dart
class EnvironmentConfig {
  static const String serverURL = kDebugMode 
    ? 'http://localhost:3000' 
    : 'https://your-app.railway.app';
}
```

## 📝 טיפים חשובים

### 1. **Firebase Service Account**
- היכנס ל-Firebase Console
- Project Settings > Service Accounts
- Generate New Private Key
- העתק את כל ה-JSON כ-string אחד למשתנה `FIREBASE_SERVICE_ACCOUNT`

### 2. **MongoDB Atlas**
- השתמש ב-MongoDB Atlas (לא local)
- הוסף את Railway IPs ל-whitelist או הפעל "Allow from Anywhere"
- השתמש ב-connection string עם `retryWrites=true&w=majority`

### 3. **Custom Domain (אופציונלי)**
- ב-Railway: Settings > Domains
- Add Custom Domain
- עדכן את ה-DNS records אצל הרשם שלך

### 4. **Logs**
- ב-Railway Dashboard תוכל לראות logs בזמן אמת
- שים לב לשגיאות בעת ה-build או runtime

## 🐛 בעיות נפוצות

### "Build failed"
- בדוק שכל ה-dependencies ב-`package.json`
- בדוק שאין שגיאות TypeScript

### "Cannot connect to MongoDB"
- בדוק את ה-connection string
- וודא ש-IP מורשה ב-Atlas

### "Firebase error"
- בדוק שה-Service Account JSON תקין
- וודא שהעתקת את כל ה-JSON

## 🔄 עדכונים עתידיים

```bash
# עשה שינויים
git add .
git commit -m "Update: description"
git push

# Railway יעדכן אוטומטית!
```

---

## 📞 תמיכה
אם יש בעיות, צור קשר:
- WhatsApp: +972506362008
- Email: support@mentalcoach.com

---

*מסמך זה נוצר עבור: Amit Trabelsi*  
*תאריך: 27/01/2025*