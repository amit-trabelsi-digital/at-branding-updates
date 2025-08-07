# 🏃‍♂️ Mental Coach Flutter App
# המאמן המנטלי - אפליקציית Flutter

אפליקציית המאמן המנטלי לספורטאים - כלי מקיף לאימון מנטלי, מעקב התקדמות וניהול מטרות.

## 📱 סקירה כללית

אפליקציית Flutter המיועדת לספורטאים (בדגש על כדורגלנים) המעוניינים לשפר את הביצועים המנטליים שלהם. האפליקציה כוללת תוכניות אימון מנטלי, תרגילים, מעקב התקדמות, ניהול מטרות ועוד.

### ✨ תכונות עיקריות
- 🎯 תוכניות אימון מנטלי מובנות
- 📚 שיעורים ותרגילים אינטראקטיביים
- 📊 מעקב אחר משחקים והתקדמות
- 🎯 ניהול מטרות אישיות
- 💪 תרגילי מנטליות וויזואליזציה
- 📝 הפרופיל המנטלי שלי - ריכוז כל התשובות והתרגילים
- 🔔 התראות ותזכורות
- 🌐 תמיכה מלאה בעברית וממשק RTL
- 📞 מערכת תמיכה מובנית

## 🛠️ טכנולוגיות

- **Framework:** Flutter 3.x
- **שפה:** Dart
- **State Management:** Provider Pattern
- **Backend:** Firebase Auth + Custom REST API (Node.js + MongoDB)
- **Push Notifications:** Firebase Cloud Messaging
- **Analytics:** Firebase Analytics
- **פלטפורמות:** iOS, Android, Web

## 📂 מבנה הפרויקט

```
mental-coach-flutter/
├── lib/                      # קוד המקור של האפליקציה
│   ├── main.dart            # נקודת הכניסה לאפליקציה
│   ├── config/              # הגדרות וקונפיגורציה
│   ├── models/              # מודלים ומבני נתונים
│   ├── providers/           # State Management (Provider)
│   ├── screens/             # מסכי האפליקציה
│   │   ├── login/          # מסכי התחברות ורישום
│   │   ├── main/           # מסכים ראשיים
│   │   └── support/        # מסך תמיכה
│   ├── service/            # שירותים (API, Firebase)
│   ├── widgets/            # רכיבים לשימוש חוזר
│   ├── routes/             # ניהול ניווט
│   └── utils/              # פונקציות עזר
├── documentation/           # תיעוד ומדריכים
│   ├── ARCHITECTURE.md    # ארכיטקטורת האפליקציה
│   ├── CLAUDE.md          # הנחיות לעבודה עם Claude AI
│   ├── android_deployment_guide.md  # מדריך פרסום לאנדרואיד
│   ├── ios_deployment_guide.md     # מדריך פרסום ל-iOS
│   ├── IOS_TROUBLESHOOTING.md     # פתרון בעיות iOS
│   ├── WEB_VERSION_SETUP.md       # הגדרות גרסת Web
│   ├── WEB_CORS_FIX.md           # תיקון CORS לגרסת Web
│   ├── VERSION_MANAGEMENT.md      # ניהול גרסאות
│   ├── DASHBOARD_UPDATES.md       # עדכוני דשבורד
│   ├── DASHBOARD_MATCH_DISPLAY_UPDATES.md  # עדכוני תצוגת משחקים
│   ├── OPEN_SOURCE_LIBS.md       # ספריות קוד פתוח
│   └── project_tasks.md          # משימות פרויקט
├── assets/                 # משאבים (תמונות, פונטים)
├── android/               # קוד ספציפי לאנדרואיד
├── ios/                   # קוד ספציפי ל-iOS
├── web/                   # קוד ספציפי לגרסת Web
├── test/                  # בדיקות
├── CHANGELOG.md          # היסטוריית שינויים מאוחדת
└── pubspec.yaml          # תלויות הפרויקט

```

## 🚀 התחלה מהירה

### דרישות מקדימות
- Flutter SDK 3.x ומעלה
- Dart SDK
- Android Studio / Xcode (לפיתוח מובייל)
- Node.js 18+ (עבור ה-API)
- MongoDB (עבור מסד הנתונים)

### התקנה

1. **שיבוט הפרויקט:**
```bash
git clone [repository-url]
cd mental-coach-flutter
```

2. **התקנת תלויות:**
```bash
flutter pub get
```

3. **הגדרת משתני סביבה:**
   - צור קובץ `.env` בתיקיית השורש
   - הוסף את המשתנים הנדרשים (ראה `.env.example`)

4. **הרצה במצב פיתוח:**
```bash
flutter run
```

## 📱 סקריפטים שימושיים

```bash
# הרצה ב-iOS Simulator
./run-ios.sh

# בניית גרסת iOS לפרסום
./build-ios.sh

# הרצה בדפדפן (Web)
./run-web-local.sh

# עדכון גרסה
./bump-version.sh
```

## 📚 תיעוד מפורט

למידע נוסף, עיין בקבצי התיעוד בתיקיית `documentation/`:

### מדריכי פיתוח
- [ארכיטקטורת האפליקציה](documentation/ARCHITECTURE.md) - מבנה הקוד והארכיטקטורה
- [הנחיות Claude AI](documentation/CLAUDE.md) - הנחיות לעבודה עם AI
- [ניהול גרסאות](documentation/VERSION_MANAGEMENT.md) - איך לנהל גרסאות

### מדריכי פרסום
- [פרסום לאנדרואיד](documentation/android_deployment_guide.md) - Google Play Store
- [פרסום ל-iOS](documentation/ios_deployment_guide.md) - App Store
- [הגדרות Web](documentation/WEB_VERSION_SETUP.md) - הגדרות לגרסת הדפדפן

### פתרון בעיות
- [בעיות iOS](documentation/IOS_TROUBLESHOOTING.md) - פתרונות לבעיות נפוצות
- [בעיות CORS](documentation/WEB_CORS_FIX.md) - תיקון בעיות CORS בגרסת Web

### מידע נוסף
- [ספריות קוד פתוח](documentation/OPEN_SOURCE_LIBS.md) - רשימת הספריות בשימוש
- [משימות פרויקט](documentation/project_tasks.md) - רשימת משימות
- [עדכוני דשבורד](documentation/DASHBOARD_UPDATES.md) - שינויים במסך הראשי

## 🔄 היסטוריית שינויים

להיסטוריית שינויים מלאה, ראה [CHANGELOG.md](CHANGELOG.md)

## 🤝 תמיכה

במקרה של בעיות או שאלות:
1. השתמש במערכת התמיכה המובנית באפליקציה (תפריט ← תמיכה)
2. שלח אימייל ל: amit@trabel.si
3. פתח Issue ב-GitHub

## 👨‍💻 קרדיטים

פותח על ידי [עמית טרבלסי](https://amit-trabelsi.co.il)

## 📄 רישיון

כל הזכויות שמורות © 2024-2025 עמית טרבלסי

---

*עדכון אחרון: 27 בינואר 2025*# Deployment trigger - Wed Aug  6 20:33:59 IDT 2025
