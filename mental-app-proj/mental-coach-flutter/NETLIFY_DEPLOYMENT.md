# 🚀 Netlify Deployment Guide - Mental Coach Flutter

## 📋 הגדרות Deployment

### 1. הגדרות Build בסיסיות ב-Netlify:

```yaml
Base directory: mental-coach-flutter
Build command: ./scripts/netlify-build.sh
Publish directory: mental-coach-flutter/build/web
```

### 2. משתני סביבה נדרשים:

```bash
FLUTTER_VERSION=3.19.0
FLUTTER_CHANNEL=stable
```

## 🔧 תיקון בעיית Submodules

הפרויקט **לא משתמש ב-submodules**. אם קיבלת שגיאה על submodules:

1. **וודא שה-commit האחרון כולל את התיקון**:
   ```bash
   git log --oneline | head -5
   ```
   חפש: "fix: הסרת הגדרות submodules"

2. **אם השגיאה ממשיכה**, הוסף ב-Netlify:
   - Build settings → Environment variables:
   ```
   GIT_LFS_ENABLED=false
   ```

## 📦 מבנה הפרויקט

```
mental-coach-flutter/
├── lib/                    # קוד Flutter
├── web/                    # הגדרות Web
├── assets/                 # משאבים
├── build/web/             # תוצר הבנייה (נוצר אוטומטית)
├── netlify.toml           # הגדרות Netlify
├── package.json           # Dependencies ל-Web server
└── scripts/
    └── netlify-build.sh   # סקריפט בנייה

```

## 🌐 הגדרות API

האפליקציה פונה ל-API בכתובות:
- Production: `https://app-srv.eitanazaria.co.il/api`
- Development: `https://dev-srv.eitanazaria.co.il/api`

**CORS מוגדר אוטומטית** עבור כל סאב-דומיין תחת `eitanazaria.co.il`.

## 🛠️ Troubleshooting

### בעיה: "No url found for submodule"
**פתרון**: זה תוקן ב-commit האחרון. עשה pull מחדש.

### בעיה: "Flutter command not found"
**פתרון**: הסקריפט `netlify-build.sh` מתקין Flutter אוטומטית.

### בעיה: "Build failed"
**בדוק**:
1. Base directory נכון: `mental-coach-flutter`
2. Build command: `./scripts/netlify-build.sh` או `flutter build web --release`
3. Publish directory: `mental-coach-flutter/build/web`

### בעיה: CORS errors
**פתרון**: השרת מוגדר לקבל בקשות מכל סאב-דומיין של `eitanazaria.co.il`.

## 📝 Build Command Options

### Option 1: Using the build script (מומלץ)
```bash
./scripts/netlify-build.sh
```

### Option 2: Direct Flutter command
```bash
flutter build web --release --web-renderer html
```

### Option 3: Using npm
```bash
npm run build
```

## 🔗 קישורים חשובים

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Netlify Build Settings](https://docs.netlify.com/configure-builds/file-based-configuration/)
- [Project Repository](https://github.com/your-repo/mental-coach)

## ✅ Checklist לפני Deployment

- [ ] Commit "fix: הסרת הגדרות submodules" קיים
- [ ] קובץ `netlify.toml` קיים
- [ ] סקריפט `netlify-build.sh` קיים ו-executable
- [ ] Base directory מוגדר נכון
- [ ] API URL מוגדר נכון ב-`environment_config.dart`

---
*נוצר על ידי: Amit Trabelsi | תאריך עדכון: 07/08/2025*