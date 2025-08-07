# תיקון עדכון משתמש במערכת הניהול

**תאריך**: 27.01.2025

## בעיות שזוהו ותוקנו:

### 1. שגיאת 500 בעדכון משתמש
**בעיה**: המערכת שלחה בקשת `PATCH` אבל ה-API מצפה ל-`PUT`.
**תיקון**: שינוי השיטה מ-`PATCH` ל-`PUT` בקובץ `UserDialog.tsx`.

```typescript
// לפני:
const method = isCreationMode ? "POST" : "PATCH";

// אחרי:
const method = isCreationMode ? "POST" : "PUT";
```

### 2. שדות חובה מיותרים
**בעיה**: שדות גיל וסיסמה הוגדרו כחובה למרות שהם אופציונליים.

**תיקונים**:
1. עדכון סכמת Yup עבור שדה גיל ב-`validators.ts`:
   ```typescript
   // לפני:
   export const yupNumberSchema_optional = yup.number().nullable().default(null);
   
   // אחרי:
   export const yupNumberSchema_optional = yup.number().nullable().optional().default(null);
   ```

2. עדכון סכמת Yup עבור שדה סיסמה ב-`UserDialog.tsx`:
   ```typescript
   // לפני:
   password: yup.string().trim().min(6, "לפחות 6 תווים").notRequired()
   
   // אחרי:
   password: yup.string().trim().min(6, "לפחות 6 תווים").optional().nullable()
   ```

3. הוספת הבהרה בממשק שהשדה גיל הוא אופציונלי.

## קבצים שעודכנו:
- `/mental-coach-admin/src/components/dialogs/UserDialog.tsx`
- `/mental-coach-admin/src/utils/validators.ts`

## בדיקת התיקונים:
1. הרץ את מערכת הניהול: `npm run dev`
2. נווט לעמוד המשתמשים
3. נסה לערוך משתמש קיים
4. וודא שאפשר לשמור בלי למלא גיל או סיסמה
5. וודא שהשמירה עוברת בהצלחה ללא שגיאת 500