# הגדרת Twilio למערכת OTP

## משתני סביבה נדרשים

הוסף את המשתנים הבאים לקובץ `.env` שלך:

```bash
# Twilio Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  
TWILIO_PHONE_NUMBER=+1234567890
```

## איך להשיג את הפרטים מ-Twilio

1. **Account SID:**
   - היכנס ל-[Twilio Console](https://console.twilio.com)
   - העתק את ה-Account SID מה-Dashboard

2. **Auth Token:**
   - באותו Dashboard, לחץ על "View" ליד Auth Token
   - העתק את הטוקן

3. **Phone Number:**
   - נווט ל-Phone Numbers → Manage → Active Numbers
   - אם אין לך מספר, לחץ על "Buy a Number"
   - בחר מספר עם יכולת SMS
   - העתק את המספר בפורמט E.164 (עם +)

## מצב פיתוח

אם לא מגדירים את משתני הסביבה של Twilio:
- המערכת תעבוד במצב פיתוח
- הקוד יוחזר בתגובת ה-API (לא יישלח SMS)
- מושלם לבדיקות ללא עלויות

## בדיקת הגדרות

בדוק את סטטוס השירות:
```bash
curl http://localhost:5001/api/otp/status
```

תגובה צפויה:
```json
{
  "success": true,
  "service": "Twilio SMS OTP",
  "status": "active",
  "hasCredentials": true,
  "environment": "development"
}
```