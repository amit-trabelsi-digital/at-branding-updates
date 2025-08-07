# External API Documentation / תיעוד API חיצוני

[English](#english) | [עברית](#hebrew)

---

## <a name="english"></a>English Documentation

### Overview
The Mental Coach External API allows third-party services to create user accounts programmatically. This API is secured with API key authentication and includes rate limiting to prevent abuse.

### Base URL
```
Production: https://api.mentalcoach.app/api/external
Development: http://localhost:3000/api/external
```

### Authentication
All requests must include an API key in one of the following ways:

#### Header Authentication (Recommended)
```http
X-API-Key: your-api-key-here
```

#### Query Parameter Authentication
```http
GET /api/external/users/exists?api_key=your-api-key-here
```

### Rate Limiting
- **Limit**: 100 requests per minute per API key
- **Headers**: Rate limit information is included in response headers:
  - `X-RateLimit-Limit`: Maximum requests allowed
  - `X-RateLimit-Remaining`: Requests remaining
  - `X-RateLimit-Reset`: Time when the limit resets

### Endpoints

#### 1. Create User
Create a single user account.

**Endpoint**: `POST /api/external/users`

**Request Body**:
```json
{
  "firstName": "John",           // Required
  "lastName": "Doe",             // Required
  "email": "john@example.com",   // Required
  "phone": "0501234567",         // Optional
  "password": "securePass123",   // Optional (min 6 chars)
  "age": 25,                     // Optional
  "nickName": "JD",              // Optional
  "position": "RB",              // Optional
  "strongLeg": "right",          // Optional
  "team": "Team Name",           // Optional
  "league": "League Name",       // Optional
  "subscriptionType": "premium", // Optional (default: "premium")
  "subscriptionExpiresAt": "2024-12-31", // Optional
  "transactionId": "TXN123",    // Optional
  "coachWhatsappNumber": "0521234567", // Optional
  "allowedAuthMethods": {        // Optional
    "email": false,
    "sms": true,
    "google": true
  },
  "externalId": "EXT123",       // Optional - Your system's ID
  "externalSource": "PartnerApp" // Optional - Your service name
}
```

**Success Response** (201 Created):
```json
{
  "status": "success",
  "message": "User created successfully",
  "data": {
    "user": {
      "_id": "mongodb-id",
      "uid": "firebase-uid",
      "email": "john@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "phone": "0501234567",
      "subscriptionType": "premium",
      "subscriptionExpiresAt": "2024-12-31T00:00:00.000Z",
      "externalId": "EXT123",
      "createdAt": "2024-01-27T10:00:00.000Z"
    }
  }
}
```

**Error Responses**:
- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Invalid or missing API key
- `409 Conflict`: User already exists
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

#### 2. Bulk Create Users
Create multiple users in a single request (max 100 users).

**Endpoint**: `POST /api/external/users/bulk`

**Request Body**:
```json
{
  "users": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "externalId": "EXT123"
    },
    {
      "firstName": "Jane",
      "lastName": "Smith",
      "email": "jane@example.com",
      "externalId": "EXT124"
    }
  ]
}
```

**Success Response** (207 Multi-Status):
```json
{
  "status": "multi-status",
  "message": "Processed 2 users",
  "data": {
    "total": 2,
    "succeeded": 2,
    "failed": 0,
    "results": {
      "success": [
        {
          "email": "john@example.com",
          "externalId": "EXT123"
        }
      ],
      "failed": []
    }
  }
}
```

#### 3. Check User Exists
Check if a user exists by email or external ID.

**Endpoint**: `GET /api/external/users/exists`

**Query Parameters**:
- `email` (optional): User's email address
- `externalId` (optional): Your system's user ID

**Example**:
```http
GET /api/external/users/exists?email=john@example.com
```

**Success Response** (200 OK):
```json
{
  "status": "success",
  "data": {
    "exists": true,
    "user": {
      "_id": "mongodb-id",
      "email": "john@example.com",
      "externalId": "EXT123"
    }
  }
}
```

#### 4. Health Check
Verify API connectivity and authentication.

**Endpoint**: `GET /api/external/health`

**Success Response** (200 OK):
```json
{
  "status": "success",
  "message": "External API is operational",
  "timestamp": "2024-01-27T10:00:00.000Z",
  "version": "1.0.0"
}
```

### Code Examples

#### Node.js / JavaScript
```javascript
const axios = require('axios');

const API_KEY = 'your-api-key-here';
const BASE_URL = 'https://api.mentalcoach.app/api/external';

// Create a user
async function createUser() {
  try {
    const response = await axios.post(
      `${BASE_URL}/users`,
      {
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '0501234567',
        externalId: 'USER123'
      },
      {
        headers: {
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json'
        }
      }
    );
    console.log('User created:', response.data);
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}
```

#### Python
```python
import requests

API_KEY = 'your-api-key-here'
BASE_URL = 'https://api.mentalcoach.app/api/external'

def create_user():
    headers = {
        'X-API-Key': API_KEY,
        'Content-Type': 'application/json'
    }
    
    data = {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'phone': '0501234567',
        'externalId': 'USER123'
    }
    
    response = requests.post(f'{BASE_URL}/users', json=data, headers=headers)
    
    if response.status_code == 201:
        print('User created:', response.json())
    else:
        print('Error:', response.json())
```

#### cURL
```bash
curl -X POST https://api.mentalcoach.app/api/external/users \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "0501234567",
    "externalId": "USER123"
  }'
```

---

## <a name="hebrew"></a>תיעוד בעברית

### סקירה כללית
ה-API החיצוני של Mental Coach מאפשר לשירותים חיצוניים ליצור חשבונות משתמש באופן תכנותי. ה-API מאובטח עם אימות מפתח API וכולל הגבלת קצב למניעת שימוש לרעה.

### כתובת בסיס
```
Production: https://api.mentalcoach.app/api/external
Development: http://localhost:3000/api/external
```

### אימות
כל הבקשות חייבות לכלול מפתח API באחת מהדרכים הבאות:

#### אימות דרך Header (מומלץ)
```http
X-API-Key: your-api-key-here
```

#### אימות דרך Query Parameter
```http
GET /api/external/users/exists?api_key=your-api-key-here
```

### הגבלת קצב
- **מגבלה**: 100 בקשות לדקה למפתח API
- **Headers**: מידע על הגבלת הקצב נכלל בתגובות:
  - `X-RateLimit-Limit`: מספר בקשות מקסימלי
  - `X-RateLimit-Remaining`: בקשות שנותרו
  - `X-RateLimit-Reset`: זמן איפוס המגבלה

### נקודות קצה

#### 1. יצירת משתמש
יצירת חשבון משתמש בודד.

**נקודת קצה**: `POST /api/external/users`

**גוף הבקשה**:
```json
{
  "firstName": "יוחנן",           // חובה
  "lastName": "כהן",              // חובה
  "email": "yohanan@example.com", // חובה
  "phone": "0501234567",          // אופציונלי
  "password": "סיסמה123",         // אופציונלי (מינימום 6 תווים)
  "age": 25,                      // אופציונלי
  "nickName": "יוני",             // אופציונלי
  "position": "RB",               // אופציונלי
  "strongLeg": "ימין",            // אופציונלי
  "team": "שם הקבוצה",            // אופציונלי
  "league": "שם הליגה",           // אופציונלי
  "subscriptionType": "premium",  // אופציונלי (ברירת מחדל: "premium")
  "subscriptionExpiresAt": "2024-12-31", // אופציונלי
  "transactionId": "TXN123",      // אופציונלי
  "coachWhatsappNumber": "0521234567", // אופציונלי
  "allowedAuthMethods": {          // אופציונלי
    "email": false,
    "sms": true,
    "google": true
  },
  "externalId": "EXT123",         // אופציונלי - המזהה במערכת שלכם
  "externalSource": "PartnerApp"  // אופציונלי - שם השירות שלכם
}
```

**תגובת הצלחה** (201 Created):
```json
{
  "status": "success",
  "message": "User created successfully",
  "data": {
    "user": {
      "_id": "mongodb-id",
      "uid": "firebase-uid",
      "email": "yohanan@example.com",
      "firstName": "יוחנן",
      "lastName": "כהן",
      "phone": "0501234567",
      "subscriptionType": "premium",
      "subscriptionExpiresAt": "2024-12-31T00:00:00.000Z",
      "externalId": "EXT123",
      "createdAt": "2024-01-27T10:00:00.000Z"
    }
  }
}
```

**תגובות שגיאה**:
- `400 Bad Request`: נתונים לא תקינים
- `401 Unauthorized`: מפתח API לא תקין או חסר
- `409 Conflict`: המשתמש כבר קיים
- `429 Too Many Requests`: חריגה ממגבלת הקצב
- `500 Internal Server Error`: שגיאת שרת

#### 2. יצירת משתמשים בכמות
יצירת מספר משתמשים בבקשה אחת (מקסימום 100 משתמשים).

**נקודת קצה**: `POST /api/external/users/bulk`

**גוף הבקשה**:
```json
{
  "users": [
    {
      "firstName": "יוחנן",
      "lastName": "כהן",
      "email": "yohanan@example.com",
      "externalId": "EXT123"
    },
    {
      "firstName": "שרה",
      "lastName": "לוי",
      "email": "sara@example.com",
      "externalId": "EXT124"
    }
  ]
}
```

#### 3. בדיקת קיום משתמש
בדיקה האם משתמש קיים לפי אימייל או מזהה חיצוני.

**נקודת קצה**: `GET /api/external/users/exists`

**פרמטרים**:
- `email` (אופציונלי): כתובת אימייל של המשתמש
- `externalId` (אופציונלי): מזהה המשתמש במערכת שלכם

**דוגמה**:
```http
GET /api/external/users/exists?email=yohanan@example.com
```

#### 4. בדיקת תקינות
אימות קישוריות ואימות ל-API.

**נקודת קצה**: `GET /api/external/health`

### דוגמאות קוד

#### Node.js / JavaScript
```javascript
const axios = require('axios');

const API_KEY = 'your-api-key-here';
const BASE_URL = 'https://api.mentalcoach.app/api/external';

// יצירת משתמש
async function createUser() {
  try {
    const response = await axios.post(
      `${BASE_URL}/users`,
      {
        firstName: 'יוחנן',
        lastName: 'כהן',
        email: 'yohanan@example.com',
        phone: '0501234567',
        externalId: 'USER123'
      },
      {
        headers: {
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json'
        }
      }
    );
    console.log('משתמש נוצר:', response.data);
  } catch (error) {
    console.error('שגיאה:', error.response?.data || error.message);
  }
}
```

### הערות אבטחה
1. שמרו את מפתח ה-API במקום מאובטח
2. אל תחשפו את המפתח בקוד צד לקוח
3. השתמשו ב-HTTPS בסביבת Production
4. נטרו את השימוש ב-API למניעת חריגות

### תמיכה
לתמיכה טכנית, פנו אל: support@mentalcoach.app

---

**גרסה**: 1.0.0  
**עדכון אחרון**: 27.01.2025