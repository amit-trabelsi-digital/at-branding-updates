# ניהול שיטות התחברות למשתמשים

## סקירה כללית

המערכת תומכת כעת בניהול מפורט של שיטות ההתחברות המורשות לכל משתמש, כולל:
- התחברות עם אימייל וסיסמה
- התחברות עם SMS (OTP)
- התחברות עם Google
- התחברות עם Apple

## שדות חדשים במודל המשתמש

### `allowedAuthMethods`
אובייקט המגדיר אילו שיטות התחברות מורשות למשתמש:
```javascript
{
  email: true,    // ברירת מחדל: true
  sms: false,     // ברירת מחדל: false
  google: true,   // ברירת מחדל: true
  apple: true     // ברירת מחדל: true
}
```

### `firebasePhoneNumber`
מספר הטלפון של המשתמש בפורמט בינלאומי E.164 (לדוגמה: `+972501234567`).
שדה זה משמש להתחברות באמצעות SMS ומסונכרן אוטומטית עם Firebase Auth.

## שימוש בממשק הניהול

### עריכת משתמש
1. נכנסים לדף "משתמשים"
2. לוחצים על כפתור העריכה ליד המשתמש הרצוי
3. בסעיף "הגדרות התחברות":
   - **מספר טלפון בפיירבייס**: מזינים מספר בפורמט בינלאומי (חייב להתחיל ב-+)
   - **שיטות התחברות מורשות**: מסמנים/מבטלים סימון של השיטות הרצויות

### הצגת שיטות התחברות בטבלה
בטבלת המשתמשים מופיעה עמודה "שיטות התחברות" עם אייקונים המציינים:
- 📧 - התחברות עם אימייל
- 💬 - התחברות עם SMS
- 🔍 - התחברות עם Google
- 🍎 - התחברות עם Apple

## API Endpoints

### בדיקת שיטת התחברות
```
POST /api/auth/check-auth-method
```

Body:
```json
{
  "email": "user@example.com",
  "authMethod": "sms"  // אפשרויות: "email", "sms", "google", "apple"
}
```

Response (Success):
```json
{
  "allowed": true,
  "authMethod": "sms",
  "firebasePhoneNumber": "+972501234567"  // רק אם authMethod הוא "sms"
}
```

Response (Forbidden):
```json
{
  "status": "fail",
  "message": "Authentication method 'sms' is not allowed for this user"
}
```

### עדכון משתמש
```
PUT /api/users/:id
```

Body:
```json
{
  "firebasePhoneNumber": "+972501234567",
  "allowedAuthMethods": {
    "email": true,
    "sms": true,
    "google": true,
    "apple": false
  }
}
```

## שילוב באפליקציה

### בדיקה לפני התחברות
לפני ביצוע התחברות באפליקציה, יש לבדוק האם שיטת ההתחברות מורשית:

```dart
// דוגמה ב-Flutter
Future<bool> checkAuthMethod(String email, String authMethod) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/check-auth-method'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'authMethod': authMethod,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['allowed'] == true;
  }
  
  return false;
}
```

### טיפול בשגיאות
אם שיטת ההתחברות אינה מורשית, יש להציג הודעה מתאימה למשתמש:
- "שיטת התחברות זו אינה מורשית עבור חשבונך"
- "אנא פנה למנהל המערכת לקבלת הרשאה"

## הערות חשובות

1. **פורמט מספר טלפון**: חובה להזין מספרי טלפון בפורמט E.164 (מתחיל ב-+ ואז קוד המדינה)
2. **סנכרון Firebase**: בעת עדכון `firebasePhoneNumber`, המספר מתעדכן אוטומטית גם ב-Firebase Auth
3. **ברירות מחדל**: משתמשים חדשים מקבלים אוטומטית הרשאה ל-email, Google ו-Apple, אך לא ל-SMS
4. **בטיחות**: אין לאפשר למשתמשים לערוך את הגדרות ההתחברות שלהם - רק מנהלי מערכת

## דוגמאות לשימוש

### הפעלת התחברות SMS למשתמש
1. עריכת המשתמש בממשק הניהול
2. הזנת מספר טלפון בפורמט: `+972501234567`
3. סימון התיבה "התחברות עם SMS"
4. שמירת השינויים

### ביטול גישת Google למשתמש
1. עריכת המשתמש בממשק הניהול
2. ביטול סימון התיבה "התחברות עם Google"
3. שמירת השינויים

המשתמש לא יוכל יותר להתחבר עם Google, גם אם החשבון שלו מקושר ל-Google.