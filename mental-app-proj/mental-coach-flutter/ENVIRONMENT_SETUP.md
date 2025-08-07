# Flutter Environment Configuration Guide

## בעיה שנפתרה
Flutter לא יכול לקרוא משתני סביבה runtime כמו web apps. הפתרון הוא להעביר משתנים בזמן build.

## הגישה החדשה

### 1. Environment Config מעודכן
קובץ `lib/config/environment_config_improved.dart` תומך עכשיו ב:
- `--dart-define=FLUTTER_ENV=prod`  
- `--dart-define=API_URL=https://your-api.com/api`

### 2. Docker Build עם משתני סביבה

#### בנייה מקומית:
```bash
# Development build
docker build --build-arg FLUTTER_ENV=dev --build-arg API_URL=https://dev-srv.eitanazaria.co.il/api -t mental-coach-flutter .

# Production build  
docker build --build-arg FLUTTER_ENV=prod --build-arg API_URL=https://app-srv.eitanazaria.co.il/api -t mental-coach-flutter .

# Test build
docker build --build-arg FLUTTER_ENV=test --build-arg API_URL=https://dev-srv.eitanazaria.co.il/api -t mental-coach-flutter .
```

#### הרצת Container:
```bash
docker run -p 8080:80 mental-coach-flutter
```

### 3. Railway Configuration

#### Environment Variables בRailway:
```
FLUTTER_ENV=prod
API_URL=https://dev-srv.eitanazaria.co.il/api
```

Railway יעביר אותם אוטומטית כ-build args ל-Docker.

### 4. בדיקה מקומית ללא Docker:
```bash
# Development
flutter run -d chrome --dart-define=FLUTTER_ENV=dev --dart-define=API_URL=http://localhost:3000/api

# Production test
flutter run -d chrome --dart-define=FLUTTER_ENV=prod --dart-define=API_URL=https://dev-srv.eitanazaria.co.il/api
```

### 5. Debug Information
האפליקציה תדפיס בהתחלה:
```
Working on PROD server
Environment: prod
API URL: https://dev-srv.eitanazaria.co.il/api
```

## יתרונות הגישה הזאת:
✅ משתני סביבה אמיתיים  
✅ גמישות בפריסה  
✅ תמיכה בכל הפלטפורמות  
✅ דיבוג קל  
✅ אין צורך לשנות קוד בין סביבות

## Migration Steps:
1. החלף `environment_config.dart` ב-`environment_config_improved.dart`
2. השתמש ב-`Dockerfile.improved` במקום `Dockerfile`
3. הגדר משתני סביבה בRailway
4. בדוק build מקומית לפני push
SETUPEND < /dev/null