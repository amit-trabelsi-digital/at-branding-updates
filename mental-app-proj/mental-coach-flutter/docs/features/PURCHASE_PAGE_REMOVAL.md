# הסרת עמוד ניהול המנוי (Purchase Page)

## תאריך: 28/01/2025

## סיכום השינויים
עמוד ניהול המנוי (PurchasePlan) בוטל והוסרו כל ההפניות אליו מהאפליקציה.

## קבצים שעודכנו:

### 1. **goals_profile.dart**
- **מיקום**: `mental-coach-flutter/lib/screens/login/goals_profile.dart`
- **שינוי**: החלפת הפניות מ-`/purchase` ל-`/dashboard/0`
- **שורות**: 120, 128
- **לוגיקה חדשה**: אחרי השלמת הגדרת המטרות, המשתמש עובר ישירות לדשבורד

### 2. **main_screen.dart**
- **מיקום**: `mental-coach-flutter/lib/screens/main/main_screen.dart`
- **שינויים**:
  - הוסר case 'manage_subscription' מה-switch statement
  - הוסרה אפשרות "ניהול מנוי" מתפריט ה-PopupMenu

### 3. **support_service.dart**
- **מיקום**: `mental-coach-flutter/lib/service/support_service.dart`
- **שינוי**: הוסר מיפוי '/purchase': 'ניהול מנוי' מרשימת הנתיבים

### 4. **קבצי purchase_plan.dart**
- **קבצים**:
  - `mental-coach-flutter/lib/screens/general/purchase_plan.dart`
  - `lib/screens/general/purchase_plan.dart`
- **פעולה**: שונו ל-`.disabled` כדי להוציאם משימוש
- **הוספה ל-gitignore**: נוסף pattern `*.disabled`

## הערות:
- לא נמצאה הגדרת נתיב `/purchase` בקובץ הראוטר (היה חסר מלכתחילה)
- לא נמצאו imports לקבצי purchase_plan
- אין עוד הפניות לעמוד זה בכל הקוד

## בדיקות נדרשות:
1. ודא שהאפליקציה עולה ללא שגיאות
2. בדוק תהליך רישום חדש - אמור לעבור מהגדרת מטרות ישר לדשבורד
3. ודא שתפריט "עוד" לא מציג אפשרות "ניהול מנוי"