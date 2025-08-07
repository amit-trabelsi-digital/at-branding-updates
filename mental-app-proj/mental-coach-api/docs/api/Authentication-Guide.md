# מדריך אימות למערכת Mental Coach API

## סקירה כללית

מערכת Mental Coach API משתמשת באימות מבוסס JWT (JSON Web Token) להגנה על הנתיבים ולוודא שרק משתמשים מורשים יכולים לגשת לתוכן.

## תהליך האימות

### 1. הרשמה חדשה (Signup)
```http
POST /api/auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "שם פרטי",
  "lastName": "שם משפחה",
  "dateOfBirth": "1990-01-01",
  "gender": "male",
  "subscriptionType": "basic"
}
```

**תשובה מוצלחת:**
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "user_id_here",
      "email": "user@example.com",
      "firstName": "שם פרטי",
      "lastName": "שם משפחה",
      "subscriptionType": "basic",
      "role": 0
    }
  }
}
```

### 2. התחברות (Login)
```http
POST /api/auth/general-login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**תשובה מוצלחת:**
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "user_id_here",
      "email": "user@example.com",
      "firstName": "שם פרטי",
      "lastName": "שם משפחה",
      "subscriptionType": "basic",
      "role": 0
    }
  }
}
```

### 3. בדיקת טוקן
```http
GET /api/auth/login
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## שימוש בטוקן

לאחר קבלת הטוקן, יש לכלול אותו בכל הבקשות המוגנות:

```http
Authorization: Bearer <TOKEN_HERE>
```

או

```http
Authorization: <TOKEN_HERE>
```

## סוגי הרשאות

### 1. משתמש רגיל (role: 0)
- גישה לתוכניות אימון לפי סוג המנוי
- עדכון פרופיל אישי
- צפייה בהתקדמות אישית

### 2. מדריך (role: 1)
- כל ההרשאות של משתמש רגיל
- יצירת ועריכת תוכניות אימון
- צפייה בסטטיסטיקות

### 3. מנהל (role: 2)
- כל ההרשאות של מדריך
- ניהול משתמשים
- גישה לכל הנתונים במערכת

## סוגי מנויים

### Basic
- גישה לתוכניות בסיסיות
- תכונות מוגבלות

### Advanced
- גישה לתוכניות מתקדמות
- תכונות נוספות

### Premium
- גישה לכל התוכניות
- כל התכונות

## שגיאות אימות נפוצות

### 401 Unauthorized
```json
{
  "status": "error",
  "message": "אנא התחבר למערכת"
}
```

### 403 Forbidden
```json
{
  "status": "error",
  "message": "אין לך הרשאה לגשת לתוכן זה"
}
```

### 404 Not Found
```json
{
  "status": "error",
  "message": "משתמש לא נמצא"
}
```

## דוגמאות שימוש ב-Postman

### הגדרת משתנים בקולקשן
1. `base_url`: `http://localhost:3000/api`
2. `auth_token`: יתמלא אוטומטית לאחר התחברות
3. `user_id`: יתמלא אוטומטית לאחר התחברות

### סקריפט Pre-request (להוספה אוטומטית של טוקן)
```javascript
// הגדרת טוקן אוטומטי מתשובת ההתחברות
if (pm.request.url.path.includes('auth/general-login') || pm.request.url.path.includes('auth/signup')) {
  // לא צריך טוקן לבקשות אימות
} else {
  // הוספת טוקן לכל הבקשות האחרות
  const token = pm.collectionVariables.get('auth_token');
  if (token) {
    pm.request.headers.add({
      key: 'Authorization',
      value: token
    });
  }
}
```

### סקריפט Test (לשמירה אוטומטית של טוקן)
```javascript
// שמירת טוקן אוטומטית מתשובת ההתחברות
if (pm.request.url.path.includes('auth/general-login') || pm.request.url.path.includes('auth/signup')) {
  if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.token) {
      pm.collectionVariables.set('auth_token', response.token);
      console.log('טוקן נשמר בהצלחה');
    }
    if (response.data && response.data.user && response.data.user._id) {
      pm.collectionVariables.set('user_id', response.data.user._id);
      console.log('מזהה משתמש נשמר בהצלחה');
    }
  }
}
```

## זרימת עבודה מומלצת ב-Postman

1. **התחברות ראשונית**: הרץ `POST /auth/general-login` או `POST /auth/signup`
2. **בדיקת טוקן**: הטוקן יישמר אוטומטיקית במשתנה `auth_token`
3. **שימוש ב-API**: כל הבקשות האחרות יכללו את הטוקן אוטומטית
4. **בדיקת תוקף**: אם תקבל שגיאה 401, הרץ שוב התחברות

## טיפים חשובים

1. **תוקף הטוקן**: הטוקן תקף ל-24 שעות
2. **אבטחה**: אל תשתף את הטוקן עם אחרים
3. **ניפוי שגיאות**: בדוק את הלוגים בקונסול של Postman
4. **משתני סביבה**: השתמש במשתני הקולקשן לגמישות

## הבדלי גישה לתוכן

### רשימת שיעורים vs תוכן שיעור

המערכת מבחינה בין שני סוגי גישה:

#### 1. רשימת שיעורים בסיסית
```http
GET /api/training-programs/{id}/lessons
```
- **זמין לכל המשתמשים** (לאחר אימות)
- מחזיר מידע בסיסי על השיעורים: כותרת, תיאור, משך זמן, סדר
- כולל שדה `hasAccess` המציין אם למשתמש יש גישה לתוכן המלא
- **לא כולל** תוכן מפורט, מדיה, תרגילים

#### 2. תוכן שיעור מלא
```http
GET /api/lessons/{id}
```
- **זמין רק למשתמשים עם הרשאה מתאימה**
- מחזיר את התוכן המלא: וידאו, אודיו, מסמכים, תרגילים
- נבדק לפי סוג מנוי והרשאות ספציפיות

### דוגמה לתשובה - רשימת שיעורים
```json
{
  "status": "success",
  "results": 24,
  "data": {
    "lessons": [
      {
        "_id": "lesson_id_1",
        "title": "שיעור מבוא",
        "description": "מבוא לתוכנית",
        "duration": 15,
        "order": 0,
        "hasAccess": true
      },
      {
        "_id": "lesson_id_2", 
        "title": "הכדורגלן העתידי שאני רוצה להיות",
        "description": "תרגיל ויזואליזציה",
        "duration": 30,
        "order": 1,
        "hasAccess": false
      }
    ]
  }
}
```

## בדיקת חיבור

לבדיקת חיבור בסיסי למערכת:
```http
GET /api/general/data
```

לא דורש אימות ויחזיר נתונים כלליים על המערכת. 