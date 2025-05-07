# Israeli Bank API
## התקנה

```bash
# התקן את התלויות
npm install

# התקן דפדפן כרום/כרומיום (לינוקס)
sudo apt update && sudo apt install -y chromium-browser

# הפעל את השרת
npm start
```

השרת יפעל בפורט 3000 כברירת מחדל. ניתן לשנות את הפורט על ידי הגדרת משתנה סביבה `PORT`.

## תצורה

### נתיב לדפדפן כרום/כרומיום

בסביבות מסוימות, ייתכן שיהיה צורך להגדיר במפורש את הנתיב לקובץ הפעלה של דפדפן כרום או כרומיום. ניתן לעשות זאת באמצעות משתנה הסביבה `CHROMIUM_PATH`.

לדוגמה, בקובץ `.env`:
```
CHROMIUM_PATH=/usr/bin/chromium-browser
```
או:
```
CHROMIUM_PATH=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome
```
יש להתאים את הנתיב למערכת הפעלה ולהתקנה הספציפית שלך.

## שימוש

### קבלת רשימת הבנקים הנתמכים

```
GET /api/supported-banks
```

### קבלת נתוני חשבון

```
POST /api/bank-data
```

גוף הבקשה:
```json
{
  "bankType": "hapoalim",
  "credentials": {
    "username": "your-username",
    "password": "your-password"
  },
  "startDate": "2023-01-01" // אופציונלי, ברירת מחדל: 30 ימים אחורה
}
```

## המלצות לאחסון

ניתן להשתמש במספר שירותי אחסון חינמיים להפעלת השרת:

1. **Render** - מציע תכנית חינמית עם:
   - 750 שעות שימוש בחודש
   - 100GB תעבורת רשת
   - פריסה אוטומטית מ-GitHub

2. **Railway** - מציע תכנית חינמית עם:
   - $5 קרדיט חודשי
   - פריסה אוטומטית
   - ניטור מובנה

3. **Fly.io** - מציע תכנית חינמית עם:
   - 3 מכונות וירטואליות קטנות
   - 160GB תעבורת רשת
   - פריסה גלובלית

## אבטחה

השירות משתמש באימות באמצעות מפתח API. יש להגדיר את המפתח במשתני הסביבה ולכלול אותו בכל בקשה בכותרת `x-api-key`.

דוגמה לשימוש עם מפתח API:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: your-api-key" \
  -d '{"bankType":"hapoalim","credentials":{"username":"your-username","password":"your-password"}}' \
  http://localhost:3000/api/bank-data
```

חשוב לשים לב:
- השתמש תמיד בחיבור HTTPS
- הגדר מפתח API מורכב וייחודי
- אחסן פרטי התחברות באופן מאובטח
- אל תשמור פרטי התחברות במסד נתונים