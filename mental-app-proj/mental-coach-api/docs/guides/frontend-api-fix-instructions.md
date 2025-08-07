# הנחיות לתיקון קריאות API בפרונטאנד

## הבעיה שזוהתה
הפרונטאנד פונה לנתיבי API ללא הקידומת `/api`, מה שגורם לשגיאות 404/500.

### דוגמאות לקריאות שגויות:
```
GET /training-programs     ❌
GET /lessons              ❌  
GET /exercises            ❌
```

### דוגמאות לקריאות נכונות:
```
GET /api/training-programs  ✅
GET /api/lessons           ✅
GET /api/exercises         ✅
```

## פתרון מומלץ

### 1. עדכון קובץ הגדרות API
חפש בפרויקט הפרונטאנד את קובץ ההגדרות של ה-API (בדרך כלל נמצא באחד מהמקומות הבאים):
- `src/config/api.js` או `api.ts`
- `src/services/api.js` או `api.ts`
- `src/utils/api.js` או `api.ts`
- `.env` או `.env.local`

### 2. עדכון ה-Base URL
וודא שה-base URL כולל את הקידומת `/api`:

```javascript
// ❌ שגוי
const API_BASE_URL = 'http://localhost:3000';

// ✅ נכון
const API_BASE_URL = 'http://localhost:3000/api';
```

או אם אתם משתמשים ב-axios:

```javascript
// ❌ שגוי
const api = axios.create({
  baseURL: 'http://localhost:3000'
});

// ✅ נכון
const api = axios.create({
  baseURL: 'http://localhost:3000/api'
});
```

### 3. עדכון כל הקריאות ל-API

אם אתם לא משתמשים ב-base URL, עדכנו כל קריאה ל-API:

```javascript
// ❌ שגוי
fetch('/training-programs')
axios.get('/lessons')

// ✅ נכון
fetch('/api/training-programs')
axios.get('/api/lessons')
```

### 4. רשימת כל הנתיבים הזמינים ב-API

#### מערכת הקורסים הדיגיטליים:
- `/api/training-programs` - תוכניות אימון
- `/api/lessons` - שיעורים
- `/api/exercises` - תרגילים
- `/api/user` - התקדמות משתמש

#### מערכת משתמשים ואימות:
- `/api/users` - ניהול משתמשים
- `/api/auth` - אימות והרשאות
- `/api/subscription` - מנויים

#### מערכת משחקים וליגות:
- `/api/matches` - משחקים
- `/api/leagues` - ליגות
- `/api/teams` - קבוצות
- `/api/match-joins` - הצטרפות למשחקים
- `/api/scores` - ניקוד

#### מערכת תוכן והודעות:
- `/api/goals` - יעדים
- `/api/actions` - פעולות
- `/api/cases` - מקרים
- `/api/pushMessages` - הודעות פוש
- `/api/eitanMessages` - הודעות איתן
- `/api/personallity-groups` - קבוצות אישיות

#### אחר:
- `/api/general` - נתונים כלליים
- `/api/track-activity` - מעקב פעילות

## פתרון זמני (כבר מיושם בשרת)

הוספתי redirects אוטומטיים בשרת שמפנים מנתיבים ללא `/api` לנתיבים עם `/api`.
זה אומר שהאפליקציה שלכם תעבוד גם בלי השינויים, אבל:

1. **ביצועים**: כל קריאה תעבור redirect נוסף (301) שמוסיף latency
2. **תקינות**: עדיף לפנות ישירות לנתיב הנכון
3. **עקביות**: כדאי שכל הקריאות יהיו אחידות

## המלצה

למרות שהבעיה נפתרה בצד השרת, מומלץ מאוד לתקן את הקריאות בצד הלקוח כדי:
- לשפר ביצועים (להימנע מ-redirect מיותר)
- לשמור על קוד נקי ותקין
- להקל על דיבוג בעתיד

## בדיקה

אחרי התיקון, וודאו שכל הקריאות עובדות כראוי:
1. פתחו את ה-Network tab בכלי הפיתוח של הדפדפן
2. וודאו שהקריאות פונות ל-`/api/...`
3. וודאו שאין יותר redirects (301) בקריאות
4. בדקו שכל הפונקציונליות עובדת כראוי 