# Twilio OTP SMS Authentication System

## סקירה כללית

מערכת אימות היברידית המשלבת Twilio לשליחת SMS עם Firebase Custom Tokens לניהול sessions.
הפתרון מספק שליטה מלאה על תהליך האימות תוך שימוש ביכולות האימות של Firebase.

## דרישות מקדימות

### משתני סביבה נדרשים (.env)
```bash
# Twilio Configuration
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890  # Your Twilio phone number

# Firebase (צריך להיות מוגדר כבר)
FIREBASE_SERVICE_ACCOUNT=path/to/serviceAccount.json
```

## API Endpoints

### 1. שליחת OTP
```
POST /api/otp/send
```

**Request Body:**
```json
{
  "phoneNumber": "0501234567",  // או "+972501234567"
  "email": "user@example.com"   // אופציונלי
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "קוד אימות נשלח בהצלחה",
  "phoneNumber": "+972501234567",
  "expiresIn": 300
}
```

**Development Mode Response (200):**
```json
{
  "success": true,
  "message": "קוד אימות נשלח (מצב פיתוח)",
  "development": true,
  "testCode": "123456",
  "phoneNumber": "+972501234567",
  "expiresIn": 300
}
```

**Error Responses:**
- `400` - מספר טלפון לא תקין
- `403` - התחברות עם SMS לא מאושרת למשתמש
- `404` - משתמש לא נמצא
- `429` - יותר מדי בקשות (המתן דקה)
- `500` - שגיאה בשליחת SMS

### 2. אימות OTP
```
POST /api/otp/verify
```

**Request Body:**
```json
{
  "phoneNumber": "0501234567",
  "code": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "אימות הושלם בהצלחה",
  "token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "65abc123...",
    "firstName": "ישראל",
    "lastName": "ישראלי",
    "email": "user@example.com",
    "phone": "0501234567",
    "firebasePhoneNumber": "+972501234567",
    "role": 3,
    "setProfileComplete": true,
    "setGoalAndProfileComplete": true,
    "subscriptionType": "basic"
  }
}
```

**Error Responses:**
- `400` - חסרים פרמטרים
- `401` - קוד שגוי
- `404` - קוד לא נמצא או פג תוקף
- `429` - יותר מדי ניסיונות שגויים
- `500` - שגיאה ביצירת טוקן

### 3. שליחה חוזרת של OTP
```
POST /api/otp/resend
```

**Request Body:**
```json
{
  "phoneNumber": "0501234567"
}
```

**Response:** זהה ל-`/api/otp/send`

### 4. בדיקת סטטוס השירות
```
GET /api/otp/status
```

**Response (200):**
```json
{
  "success": true,
  "service": "Twilio SMS OTP",
  "status": "active",
  "hasCredentials": true,
  "environment": "development"
}
```

## מודל נתונים - OTP

```typescript
{
  phoneNumber: string;      // מספר טלפון בפורמט E.164
  email?: string;          // אימייל המשתמש
  code: string;            // קוד 6 ספרות
  purpose: string;         // "login" | "verification" | "reset"
  attempts: number;        // מספר ניסיונות (מקסימום 3)
  isVerified: boolean;     // האם אומת
  expiresAt: Date;        // תוקף (5 דקות)
  verifiedAt?: Date;      // זמן אימות
  ipAddress?: string;     // כתובת IP
  userAgent?: string;     // פרטי דפדפן
  createdAt: Date;
  updatedAt: Date;
}
```

## תהליך האימות המלא

1. **משתמש מזין מספר טלפון** באפליקציה
2. **אפליקציה שולחת בקשה** ל-`/api/otp/send`
3. **השרת:**
   - בודק אם המשתמש קיים והאם מורשה SMS
   - יוצר קוד OTP אקראי (6 ספרות)
   - שומר במסד נתונים עם תוקף 5 דקות
   - שולח SMS דרך Twilio
4. **משתמש מקבל SMS** ומזין את הקוד
5. **אפליקציה שולחת** ל-`/api/otp/verify`
6. **השרת:**
   - מאמת את הקוד
   - יוצר/מעדכן משתמש Firebase
   - יוצר Custom Token
   - מחזיר טוקן ופרטי משתמש
7. **אפליקציה מתחברת** ל-Firebase עם ה-Custom Token

## הגבלות ואבטחה

### הגבלות מערכת
- **תוקף קוד:** 5 דקות
- **ניסיונות:** מקסימום 3 לכל קוד
- **קצב שליחה:** מינימום דקה בין בקשות
- **ניקוי אוטומטי:** קודים נמחקים אחרי 10 דקות

### אבטחה
- ולידציה של פורמט מספר טלפון
- בדיקת הרשאות משתמש לפני שליחה
- שמירת IP address ו-user agent
- מחיקת קודים ישנים לפני יצירת חדש
- הצפנת תקשורת HTTPS

## מצב פיתוח

כאשר אין Twilio מוגדר (חסרים credentials):
- המערכת עובדת במצב פיתוח
- הקוד מוחזר בתגובת API (לא נשלח SMS)
- ניתן לבדוק את כל התהליך ללא עלויות SMS

## טיפול בשגיאות באפליקציה

```dart
// דוגמה ב-Flutter
try {
  // שליחת OTP
  final response = await http.post(
    Uri.parse('$baseUrl/api/otp/send'),
    body: jsonEncode({'phoneNumber': phoneNumber}),
  );
  
  if (response.statusCode == 429) {
    // יותר מדי בקשות
    showError('אנא המתן דקה לפני ניסיון נוסף');
  } else if (response.statusCode == 403) {
    // לא מורשה SMS
    showError('התחברות עם SMS לא מאושרת לחשבונך');
  }
  
} catch (e) {
  showError('שגיאה בשליחת קוד אימות');
}
```

## התקנת Twilio

1. **יצירת חשבון Twilio:**
   - הרשמה ב-[twilio.com](https://www.twilio.com)
   - אימות החשבון

2. **קבלת Credentials:**
   - Account SID מ-Console Dashboard
   - Auth Token מ-Console Dashboard

3. **רכישת מספר טלפון:**
   - Phone Numbers → Buy a Number
   - בחירת מספר עם יכולת SMS
   - עבור ישראל: מספר ארה"ב או UK

4. **הגדרת משתני סביבה:**
```bash
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890
```

## עלויות Twilio

- **מספר טלפון:** ~$1-2 לחודש
- **SMS לישראל:** ~$0.06 לסמס
- **חבילת Trial:** $15 קרדיט חינם להתחלה

## בעיות נפוצות ופתרונות

### SMS לא נשלח
- בדוק שה-credentials נכונים
- וודא שהמספר של Twilio תומך ב-SMS
- בדוק יתרת חשבון Twilio

### קוד לא מתקבל
- בדוק שהמספר בפורמט נכון
- וודא שהמספר יכול לקבל SMS בינלאומי
- בדוק בלוגים של Twilio Console

### שגיאת אימות
- וודא שהקוד הוזן תוך 5 דקות
- בדוק שלא עברו 3 ניסיונות
- נסה לשלוח קוד חדש

## דוגמת שימוש מלאה

```javascript
// 1. שליחת OTP
const sendOTP = async (phoneNumber) => {
  const response = await fetch('/api/otp/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phoneNumber })
  });
  
  const data = await response.json();
  
  if (data.development) {
    console.log('Test code:', data.testCode);
  }
  
  return data;
};

// 2. אימות קוד
const verifyOTP = async (phoneNumber, code) => {
  const response = await fetch('/api/otp/verify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phoneNumber, code })
  });
  
  const data = await response.json();
  
  if (data.success) {
    // שמירת טוקן
    localStorage.setItem('firebaseToken', data.token);
    // התחברות ל-Firebase
    await firebase.auth().signInWithCustomToken(data.token);
  }
  
  return data;
};
```