# 🚂 Railway Deployment Guide - Mental Coach

מדריך לפריסת 3 השירותים העצמאיים ב-Railway, כל אחד עם repository נפרד וCI/CD עצמאי.

## 📋 סקירה כללית

הפרויקט מורכב מ-3 שירותים עצמאיים:
1. **mental-coach-api** - Node.js API Server
2. **mental-coach-admin** - React Admin Panel  
3. **mental-coach-flutter** - Flutter Web App

כל שירות:
- Repository נפרד ב-GitHub
- CI/CD עצמאי
- משתני סביבה משלו
- יכול לרוץ באופן עצמאי
- מתקשר עם השירותים האחרים דרך URLs חיצוניים

## 🔧 הכנה מקדימה

### 1. יצירת Repositories ב-GitHub

```bash
# API Repository
cd mental-coach-api
git init
git remote add origin https://github.com/amit-trabelsi-digital/mental-coach-api.git
git add .
git commit -m "Initial commit"
git push -u origin main

# Admin Repository  
cd mental-coach-admin
git init
git remote add origin https://github.com/amit-trabelsi-digital/mental-coach-admin.git
git add .
git commit -m "Initial commit"
git push -u origin main

# Flutter Repository
cd mental-coach-flutter
git init
git remote add origin https://github.com/amit-trabelsi-digital/mental-coach-flutter.git
git add .
git commit -m "Initial commit"
git push -u origin main
```

### 2. הכנת MongoDB חיצוני

השתמש באחד מהשירותים:
- **MongoDB Atlas** (מומלץ): https://cloud.mongodb.com
- **Railway MongoDB**: הוסף MongoDB service ב-Railway

קבל את ה-connection string בפורמט:
```
mongodb://mongo:wMkshOZzvlNISkmvhqugANbRZkFCQsRP@centerbeam.proxy.rlwy.net:14770
```

## 🚀 פריסת API Service

### 1. יצירת פרויקט ב-Railway

1. היכנס ל-Railway: https://railway.app
2. לחץ על "New Project"
3. בחר "Deploy from GitHub repo"
4. בחר את `mental-coach-api` repository

### 2. הגדרת משתני סביבה

ב-Railway Dashboard > Variables, הוסף:

```env
NODE_ENV=production
DATABASE_URL=mongodb+srv://... # ה-connection string שלך
JWT_SECRET=your-super-secure-jwt-secret-key
JWT_EXPIRES_IN=90d

# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=/app/serviceAccount.json

# External API Keys
EXTERNAL_API_KEYS=production-key-1,production-key-2

# SendGrid
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
EMAIL_FROM=noreply@yourdomain.com

# Twilio  
TWILIO_ACCOUNT_SID=ACxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890

# CORS (יתעדכן אחרי פריסת Admin ו-Flutter)
CORS_ORIGINS=https://mental-coach-admin.up.railway.app,https://mental-coach-flutter.up.railway.app
```

### 3. העלאת Firebase Service Account

1. ב-Railway, לך ל-"Settings" > "Files"
2. העלה את `serviceAccount.json`
3. וודא שהנתיב תואם ל-`FIREBASE_SERVICE_ACCOUNT_PATH`

### 4. פריסה

Railway יזהה אוטומטית את `railway.toml` ויפרוס את השירות.

### 5. קבלת URL

לאחר הפריסה, Railway יספק URL כמו:
```
https://mental-coach-api.up.railway.app
```

## 📊 פריסת Admin Panel

### 1. יצירת פרויקט ב-Railway

1. "New Project" > "Deploy from GitHub repo"
2. בחר את `mental-coach-admin` repository

### 2. הגדרת משתני סביבה

```env
VITE_API_URL=https://mental-coach-api.up.railway.app/api
VITE_ENV=production
```

### 3. פריסה

Railway יבנה ויפרוס אוטומטית.

### 4. קבלת URL

```
https://mental-coach-admin.up.railway.app
```

## 📱 פריסת Flutter Web

### 1. יצירת פרויקט ב-Railway

1. "New Project" > "Deploy from GitHub repo"
2. בחר את `mental-coach-flutter` repository

### 2. הגדרת משתני סביבה

```env
API_URL=https://mental-coach-api.up.railway.app/api
FLUTTER_ENV=production

# Firebase Web
FIREBASE_WEB_API_KEY=your-firebase-api-key
FIREBASE_WEB_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_WEB_PROJECT_ID=your-project-id
FIREBASE_WEB_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_WEB_MESSAGING_SENDER_ID=123456789
FIREBASE_WEB_APP_ID=your-app-id

# ReCaptcha
RECAPTCHA_SITE_KEY=your-recaptcha-site-key
```

### 3. פריסה

Railway יבנה ויפרוס אוטומטית.

### 4. קבלת URL

```
https://mental-coach-flutter.up.railway.app
```

## 🔄 עדכון CORS ב-API

לאחר שקיבלת את כל ה-URLs, חזור ל-API service ועדכן:

```env
CORS_ORIGINS=https://mental-coach-admin.up.railway.app,https://mental-coach-flutter.up.railway.app
```

## 🔍 CI/CD Workflow

### GitHub Actions (אופציונלי)

לכל repository, צור `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Railway
        uses: bervProject/railway-deploy@main
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
          service: ${{ github.event.repository.name }}
```

הוסף `RAILWAY_TOKEN` ב-GitHub Secrets.

## 🐛 Debugging

### בדיקת לוגים

```bash
# ב-Railway CLI
railway logs -s mental-coach-api
railway logs -s mental-coach-admin
railway logs -s mental-coach-flutter
```

### בדיקת Health

```bash
# API
curl https://mental-coach-api.up.railway.app/api/health

# Admin
curl https://mental-coach-admin.up.railway.app/health

# Flutter
curl https://mental-coach-flutter.up.railway.app/health
```

## 📈 Monitoring

Railway מספק:
- **Metrics**: CPU, Memory, Network
- **Logs**: Real-time logs
- **Alerts**: הגדר התראות על שגיאות
- **Usage**: מעקב אחר שימוש ועלויות

## 🔒 Security Best Practices

1. **משתני סביבה**: אף פעם לא ב-code
2. **Secrets**: השתמש ב-Railway Variables
3. **CORS**: הגדר רק domains מורשים
4. **API Keys**: צור keys נפרדים לכל סביבה
5. **MongoDB**: השתמש ב-IP Whitelist
6. **HTTPS**: Railway מספק אוטומטית

## 💰 עלויות

Railway מציע:
- **Hobby Plan**: $5/חודש עם $5 קרדיט
- **Pro Plan**: $20/חודש עם יותר משאבים
- **תמחור לפי שימוש**: CPU, Memory, Network

הערכת עלות חודשית:
- API: ~$5-10
- Admin: ~$3-5
- Flutter: ~$3-5
- **סה"כ**: ~$11-20/חודש

## 🚨 Rollback

במקרה של בעיה:

1. **Instant Rollback**: 
   - Railway Dashboard > Deployments
   - בחר deployment קודם
   - לחץ "Rollback"

2. **Git Revert**:
   ```bash
   git revert HEAD
   git push
   ```

## 📞 Support

- **Railway Discord**: https://discord.gg/railway
- **Railway Docs**: https://docs.railway.app
- **Status Page**: https://status.railway.app

---

## 🎯 Checklist לפריסה

- [ ] יצרת 3 repositories נפרדים ב-GitHub
- [ ] הגדרת MongoDB חיצוני
- [ ] פרסת API service
- [ ] פרסת Admin panel
- [ ] פרסת Flutter web
- [ ] עדכנת CORS ב-API
- [ ] בדקת health endpoints
- [ ] הגדרת monitoring
- [ ] תיעדת את כל ה-URLs והגדרות

---
*מעודכן: ינואר 2025*