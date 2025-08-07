# מדריך ניהול גרסאות אוטומטי - Mental Coach

## סקירה כללית

מערכת ניהול גרסאות אחידה ואוטומטית עבור כל שלושת רכיבי המערכת:
- **API Server** (`mental-coach-api/`)
- **Admin Panel** (`mental-coach-admin/`)  
- **Flutter App** (`mental-coach-flutter/`)

## עקרונות המערכת

### 🎯 Semantic Versioning
```
MAJOR.MINOR.PATCH+BUILD
```

- **MAJOR**: שינויים שוברים תאימות לאחור
- **MINOR**: תכונות חדשות תואמות לאחור
- **PATCH**: תיקוני באגים
- **BUILD**: מספר בנייה (רק ב-Flutter)

### 🔄 עדכון אוטומטי
הגרסה מתעדכנת אוטומטית על פי הודעת הcommit:

| סוג Commit | דוגמה | עדכון גרסה |
|-------------|--------|-------------|
| `feat:` | `feat: הוספת מערכת התראות` | **MINOR** ⬆️ |
| `fix:` | `fix: תיקון בעיית התחברות` | **PATCH** ⬆️ |
| `BREAKING CHANGE` | `BREAKING CHANGE: שינוי API` | **MAJOR** ⬆️ |
| אחר | `docs: עדכון תיעוד` | **PATCH** ⬆️ |

## מבנה הקבצים

### 📁 קבצי גרסה בכל פרויקט

```
mental-coach-api/
├── version.json          # מרכז מידע גרסה
├── package.json          # מסונכרן עם version.json
└── scripts/bump-version.sh

mental-coach-admin/
├── version.json          # מרכז מידע גרסה  
├── package.json          # מסונכרן עם version.json
├── src/utils/version.ts  # קבצי TypeScript מסונכרנים
└── scripts/bump-version.sh

mental-coach-flutter/
├── version.json          # מרכז מידע גרסה
├── pubspec.yaml          # מסונכרן עם version.json
├── lib/utils/version_helper.dart
└── scripts/bump-version.sh
```

### 📄 תוכן version.json
```json
{
  "version": "1.0.0",
  "build": "2025.08.06.001", 
  "buildNumber": "13",
  "name": "mental-coach-api",
  "description": "Mental Coach API - Sports Mental Training Platform",
  "buildDate": "2025-08-06T15:23:51.000Z"
}
```

## 🛠️ שימוש במערכת

### עדכון גרסה ידני

```bash
# בתיקיית כל פרויקט
npm run version:patch    # הגדלת PATCH
npm run version:minor    # הגדלת MINOR  
npm run version:major    # הגדלת MAJOR
npm run version:bump     # זיהוי אוטומטי לפי commit

# או ישירות
./scripts/bump-version.sh patch
./scripts/bump-version.sh minor
./scripts/bump-version.sh major
./scripts/bump-version.sh auto
```

### עדכון אוטומטי עם Git Hooks

1. **התקנת Hooks**:
```bash
# מתיקיית הפרויקט הראשית
./scripts/install-git-hooks.sh
```

2. **שימוש רגיל**:
```bash
git add .
git commit -m "feat: הוספת תכונה חדשה"
# הגרסה תתעדכן אוטומטית ל-MINOR! 🎉
git push
```

## 🖥️ הצגת גרסאות במערכת

### API Server
- **Endpoint**: `GET /api/info/version`
- **Response**:
```json
{
  "status": "success",
  "data": {
    "version": "1.0.0",
    "name": "mental-coach-api", 
    "build": "2025.08.06.001",
    "buildDate": "2025-08-06T15:23:51.000Z",
    "description": "Mental Coach API - Sports Mental Training Platform"
  }
}
```

### Admin Panel
```typescript
import { BUILD_INFO } from '@/utils/version';

// הצגת גרסה בממשק
console.log(`גרסה: ${BUILD_INFO.version}`);
console.log(`Build: ${BUILD_INFO.build}`);
```

### Flutter App
```dart
import 'package:mental_coach/utils/version_helper.dart';

// אתחול (בmain או באפליקציה)
await VersionHelper.instance.initialize();

// השימוש
String version = VersionHelper.instance.version;
String fullVersion = VersionHelper.instance.fullVersion; // "0.9.0+13"
String displayVersion = VersionHelper.instance.getDisplayVersion(
  showBuild: true, 
  showDate: true
);
```

## ⚙️ התקנה והגדרה

### התקנה ראשונית
```bash
# 1. התקנת Git Hooks (חובה!)
./scripts/install-git-hooks.sh

# 2. בדיקה שהכל עובד
cd mental-coach-api
npm run version:patch
# ✅ אמור להציג: עודכן ל-1.0.1

cd ../mental-coach-admin  
npm run version:patch
# ✅ אמור להציג: עודכן ל-1.0.2

cd ../mental-coach-flutter
./scripts/bump-version.sh patch
# ✅ אמור להציג: עודכן ל-0.9.1+14
```

### סנכרון גרסאות קיימות
```bash
# אם יש אי-התאמות בין קבצים
cd mental-coach-api
npm run version:bump  # יסנכרן מpackage.json

cd mental-coach-admin
npm run version:bump  # יסנכרן ויעדכן גם את version.ts

cd mental-coach-flutter  
./scripts/bump-version.sh auto  # יסנכרן עם pubspec.yaml
```

## 🔍 פתרון בעיות נפוצות

### בעיה: Git Hook לא עובד
```bash
# בדיקה שההוק הותקן
ls -la .git/hooks/pre-commit

# התקנה מחדש  
./scripts/install-git-hooks.sh
```

### בעיה: גרסה לא מתסנכרנת
```bash
# עדכון ידני של כל הקבצים
./scripts/bump-version.sh auto

# בדיקה שכל הקבצים מעודכנים
git diff version.json package.json pubspec.yaml src/utils/version.ts
```

### בעיה: סקריפט לא רץ
```bash
# בדיקת הרשאות
chmod +x scripts/bump-version.sh

# בדיקה שNode.js זמין (נדרש לכל הסקריפטים)
node --version
```

## 📊 דוגמאות לזרימת עבודה

### תרחיש 1: הוספת תכונה חדשה
```bash
# פיתוח התכונה
git checkout -b feature/new-dashboard

# עבודה על הקוד
# ... שינויים בקוד ...

# Commit אוטומטי
git add .
git commit -m "feat: הוספת דשבורד חדש למשתמשים"
# ✅ הגרסה תתעדכן אוטומטית ל-MINOR

git push origin feature/new-dashboard
```

### תרחיש 2: תיקון באג חריף
```bash
# התחלת עבודה על התיקון
git checkout -b hotfix/login-bug

# תיקון הבאג
# ... שינויים בקוד ...

# Commit עם עדכון גרסה אוטומטי
git add .
git commit -m "fix: תיקון בעיית התחברות משתמשים"
# ✅ הגרסה תתעדכן אוטומטית ל-PATCH

git push origin hotfix/login-bug
```

### תרחיש 3: שינוי שובר תאימות
```bash
# שינוי משמעותי ב-API
git add .
git commit -m "BREAKING CHANGE: שינוי בפורמט נתוני המשתמש

- שדה 'name' שונה ל-'fullName'  
- שדה 'age' הוסר
- נוסף שדה 'dateOfBirth'"
# ✅ הגרסה תתעדכן אוטומטית ל-MAJOR

git push
```

## 🎨 התאמה אישית

### שינוי כללי זיהוי Commit
ערוך את `scripts/bump-version.sh` בפונקציה `detect_bump_type`:

```bash
detect_bump_type() {
    local commit_msg="$1"
    
    # הוסף כללים משלך
    if [[ "$commit_msg" =~ ^hotfix: ]]; then
        echo "patch"
    elif [[ "$commit_msg" =~ ^feature: ]]; then
        echo "minor"
    # ... כללים נוספים
}
```

### הוספת מידע נוסף לversion.json
ערוך את הסקריפט להוסיף שדות:

```bash
cat > "$VERSION_FILE" << EOF
{
  "version": "$new_version",
  "build": "$build", 
  "customField": "ערך מותאם אישית",
  "lastCommit": "$(git rev-parse HEAD)",
  "branch": "$(git branch --show-current)"
}
EOF
```

## 🚀 שילוב עם CI/CD

### GitHub Actions דוגמה
```yaml
name: Version and Deploy
on:
  push:
    branches: [ main ]

jobs:
  version-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Update version
        run: npm run version:bump
        
      - name: Commit version
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add version.json package.json
          git commit -m "chore: update version [skip ci]" || exit 0
          git push
        
      - name: Deploy
        run: npm run deploy
```

---

## ✅ סיכום

מערכת ניהול הגרסאות מספקת:

1. **אחידות** - כל הפרויקטים משתמשים באותה שיטה
2. **אוטומציה** - עדכון אוטומטי עם כל commit
3. **שקיפות** - מידע מלא על גרסה וbuild בכל רכיב
4. **פשטות** - פקודות npm פשוטות לעדכונים ידניים
5. **גמישות** - ניתן להתאים לצרכים ספציפיים

**התחל עכשיו**: `./scripts/install-git-hooks.sh` 🚀