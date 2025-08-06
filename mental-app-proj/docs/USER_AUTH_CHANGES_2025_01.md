# שינויים במערכת ההרשאה והוספת משתמשים
תאריך: 29/01/2025
עדכון אחרון: 29/01/2025 - תיקונים נוספים

## רקע
המשתמש ביקש לבצע שינויים במסך הוספת משתמש כדי להתאים את המערכת לשיטות ההתחברות הנדרשות.

## השינויים שבוצעו

### 1. הסרת חובה משדה סיסמה ✅
- **מטרה**: לאפשר יצירת משתמשים שמתחברים רק עם SMS או Google, ללא סיסמה
- **שינויים שבוצעו**:
  - **Frontend** (mental-coach-admin):
    - הסרת validation של required משדה הסיסמה ב-UserDialog.tsx
    - השדה עדיין מאומת למינימום 6 תווים אם מכניסים סיסמה
  
  - **Backend** (mental-coach-api):
    - עדכון user-controller.ts כך שסיסמה לא חובה
    - יצירת סיסמה אקראית אוטומטית אם לא סופקה סיסמה
    - נוסחת הסיסמה האקראית: `Math.random().toString(36).slice(-12) + "Aa1!"`

### 2. הסרת התחברות עם Apple ✅
- **מטרה**: להשאיר רק SMS ו-Google כאפשרויות התחברות
- **שינויים שבוצעו**:
  - **Frontend**:
    - הסרת ה-checkbox של Apple מהממשק
    - הסרת Apple מ-validation schema של yup
    - הסרת Apple מברירות המחדל
    - עדכון TypeScript interfaces
  
  - **Backend**:
    - הסרת Apple מ-user-model.ts (גם מה-interface וגם מה-schema)
    - עדכון auth-controller.ts ו-otp-controller.ts
    - הסרת Apple מברירות המחדל של allowedAuthMethods

### 3. SMS כברירת מחדל ✅
- **מטרה**: להגדיר SMS כשיטת ההתחברות הראשית
- **שינויים שבוצעו**:
  - שינוי ברירות המחדל ל:
    ```javascript
    {
      email: false,
      sms: true,
      google: true
    }
    ```

### 4. התחברות מנהלים ✅
- **מטרה**: מנהלים צריכים להיות מסומנים גם ב-SMS וגם ב-Google
- **שינויים שבוצעו**:
  - **Frontend**: הוספת watcher שמאזין לשדה isAdmin ומעדכן אוטומטית את allowedAuthMethods
  - **Backend**: לוגיקה מיוחדת למשתמשי admin שמוודאת ש-SMS ו-Google מופעלים

## קבצים שעודכנו

### Frontend (mental-coach-admin)
- `src/components/dialogs/UserDialog.tsx`
- `src/utils/types.ts`
- `src/layouts/Layout.tsx`
- `src/components/dialogs/SupportDialog.tsx`

### Backend (mental-coach-api)
- `controllers/user-controller.ts`
- `controllers/auth-controller.ts`
- `controllers/otp-controller.ts`
- `models/user-model.ts`

## בדיקות שבוצעו
- ✅ בניית Frontend בהצלחה
- ✅ בניית Backend בהצלחה
- ✅ אין שגיאות TypeScript
- ✅ אין שגיאות lint

## תיקונים נוספים (29/01/2025)

### 1. שיפור יצירת סיסמה אקראית ✅
- יצירת פונקציה חזקה יותר ליצירת סיסמה אקראית
- הסיסמה כוללת אותיות גדולות, קטנות, מספרים ותווים מיוחדים
- אורך: 16 תווים לביטחון מרבי

### 2. שיפור UI ✅
- הוספת placeholder לשדה סיסמה: "השאר ריק אם משתמש רק ב-SMS/Google"
- שינוי label הסיסמה ל"סיסמה (אופציונלי)"

### 3. ניהול ליגות ✅
- ייבוא ISRAELY_LEAGUES מקובץ lists.ts
- שימוש ברשימת ליגות מרכזית במקום hardcoded values
- תיקון כל שגיאות ה-TypeScript

### 4. שיפור טיפול בשגיאות ✅
- הוספת console.error מפורט לדיבאג
- טיפול מיוחד בשגיאות Firebase שונות
- הודעות שגיאה ברורות יותר בעברית

## הערות חשובות
1. משתמשים חדשים שנוצרים ללא סיסמה יקבלו סיסמה אקראית אוטומטית ב-Firebase
2. משתמשי אדמין תמיד יוכלו להתחבר גם עם SMS וגם עם Google
3. Apple הוסר לחלוטין מהמערכת ולא ניתן יותר להתחבר באמצעותו
4. הסיסמה אינה שדה חובה יותר - מתאים למשתמשים שמתחברים רק עם SMS/Google

## פתרון בעיות
אם מתקבלת שגיאה בעת יצירת משתמש חדש:
1. וודא שכל השינויים נפרסו לשרת
2. בדוק שה-API מחזיר את allowedAuthMethods בפורמט הנכון
3. וודא ש-Firebase מוגדר נכון עם SMS authentication מופעל

---
פותח על ידי: עמית טרבלסי
https://amit-trabelsi.co.il