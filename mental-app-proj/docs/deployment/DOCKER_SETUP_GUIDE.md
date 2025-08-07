# 🐳 Docker Setup Guide - Mental Coach App

מדריך להרצת פרויקט Mental Coach עם Docker, כולל תמיכה מלאה במשתני סביבה ובגישה לשרתים חיצוניים.

## 📋 דרישות מקדימות

- Docker Desktop מותקן
- Docker Compose v2.0+
- גישה ל-Database חיצוני (MongoDB)
- קובץ `serviceAccount.json` של Firebase (למערכת ה-API)

## 🚀 התחלה מהירה

### 1. הכנת משתני סביבה

```bash
# העתק את קובץ הדוגמה
cp env.docker.example .env

# ערוך את הקובץ עם הערכים שלך
nano .env
```

### 2. הגדרות חשובות ב-.env

```env
# חיבור ל-Database חיצוני
DATABASE_URL=mongodb://username:password@your-external-db:27017/mental-coach

# כתובות API חיצוניות
ADMIN_API_URL=https://your-api-server.com/api
FLUTTER_API_URL=https://your-api-server.com/api

# הגדרות Firebase (לפלאטר Web)
FIREBASE_WEB_API_KEY=your-key
FIREBASE_WEB_PROJECT_ID=your-project
```

### 3. הרצת השירותים

```bash
# הרצת כל השירותים
docker-compose up -d

# או עם הסקריפט המוכן
./docker-run.sh
```

## 🏗️ ארכיטקטורת Docker

### שירותים זמינים:

1. **API Server** (אופציונלי - אם רוצים להריץ מקומית)
   - פורט: 3000
   - מתחבר ל-DB חיצוני
   - תומך במשתני סביבה מלאים

2. **Admin Panel** 
   - פורט: 9977
   - React Admin עם Vite
   - מתחבר לשרת API חיצוני

3. **Flutter Web**
   - פורט: 8080
   - תמיכה מלאה במשתני סביבה
   - גישה לתמונות ו-assets
   - התחברות לשרת API חיצוני

## 📁 מבנה הקבצים

```
mental-app-proj/
├── docker-compose.yml          # קונפיגורציית Docker מרכזית
├── .env                        # משתני סביבה (לא עולה ל-Git)
├── env.docker.example          # דוגמה למשתני סביבה
├── docker-run.sh              # סקריפט הרצה
├── mental-coach-api/
│   ├── Dockerfile             # בניית API
│   └── serviceAccount.json    # Firebase credentials
├── mental-coach-admin/
│   └── Dockerfile             # בניית Admin
└── mental-coach-flutter/
    ├── Dockerfile             # בניית Flutter Web
    ├── docker-entrypoint.sh  # הזרקת משתני סביבה
    └── lib/config/
        └── environment_config_docker.dart  # תמיכה במשתני Docker
```

## 🔧 קונפיגורציה מתקדמת

### הגדרת Flutter למשתני סביבה

הפרויקט תומך במשתני סביבה דרך `--dart-define`:

```dart
// lib/config/environment_config_docker.dart
static const String _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api'
);
```

### גישה לתמונות ב-Flutter

התמונות מועתקות אוטומטית ל-container:

```yaml
volumes:
  - ./mental-coach-flutter/assets:/usr/share/nginx/html/assets:ro
  - ./mental-coach-flutter/images:/usr/share/nginx/html/images:ro
```

### התחברות לשרת חיצוני

```env
# ב-.env
FLUTTER_API_URL=https://production-api.example.com/api
ADMIN_API_URL=https://production-api.example.com/api
```

## 🔍 בדיקת השירותים

```bash
# בדיקת סטטוס
docker-compose ps

# צפייה בלוגים
docker-compose logs -f flutter-web
docker-compose logs -f admin
docker-compose logs -f api

# גישה לשירותים
open http://localhost:8080  # Flutter Web
open http://localhost:9977  # Admin Panel
open http://localhost:3000  # API (אם פועל)
```

## 🛠️ פקודות שימושיות

```bash
# בנייה מחדש
docker-compose build --no-cache

# עצירת כל השירותים
docker-compose down

# ניקוי מלא
docker-compose down -v
docker system prune -a

# הרצת שירות ספציפי
docker-compose up -d flutter-web

# כניסה ל-container
docker exec -it mental-coach-flutter sh
```

## 🌍 פריסה לייצור

### 1. עדכון משתני סביבה לייצור:

```env
NODE_ENV=production
FLUTTER_ENV=prod
NPM_SCRIPT=start
```

### 2. בנייה לייצור:

```bash
docker-compose -f docker-compose.yml build
```

### 3. העלאה ל-Registry:

```bash
docker tag mental-coach-flutter:latest your-registry/mental-coach-flutter:latest
docker push your-registry/mental-coach-flutter:latest
```

## ❓ בעיות נפוצות

### בעיה: Flutter לא מתחבר לשרת
**פתרון:** וודא שהגדרת את `FLUTTER_API_URL` נכון ב-.env

### בעיה: תמונות לא נטענות
**פתרון:** בדוק שהתיקיות `assets` ו-`images` קיימות ומכילות את הקבצים

### בעיה: שגיאות CORS
**פתרון:** וודא שהשרת החיצוני מאפשר גישה מה-domain של Docker

## 📞 תמיכה

לשאלות ובעיות, פנה לצוות הפיתוח.

---
*מעודכן: ינואר 2025*