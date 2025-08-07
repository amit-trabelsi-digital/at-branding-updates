# Static Deployment Branch - Important Note

⚠️ **הערה חשובה**: בניגוד לפרויקט הFlutter, פרויקט ה-API **לא יכול** להיפרס כאתר סטטי מכיוון שזה שרת Node.js שדורש להתקיים כתהליך פעיל.

## מה השתנה בבראנץ הזה?

- `railway.json` עודכן להשתמש ב-NIXPACKS במקום Dockerfile
- זה עדיין דורש שהשרת ירוץ כתהליך פעיל, לא כאתר סטטי

## למה NIXPACKS?

NIXPACKS הוא בנאי אוטומטי שמזהה את סוג הפרויקט ובונה אותו בהתאם, זה יכול להיות יותר יעיל מ-Docker במקרים מסוימים.

## הגדרות Railway

```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 300,
    "startCommand": "node dist/server.js",
    "restartPolicyType": "on_failure",
    "restartPolicyMaxRetries": 10
  }
}
```

## מגבלות

- **לא אתר סטטי**: השרת חייב להתקיים כתהליך פעיל
- **דורש משתני סביבה**: MongoDB, Firebase, וכל השירותים החיצוניים
- **צרך בחיבור למסד נתונים**: בניגוד לאתר סטטי שיכול לעבוד ללא שרת

## המלצה

עבור פרויקט ה-API, השתמש בבראנץ הראשי עם הגדרות Docker המוכנות, אלא אם כן אתה רוצה לנסות את NIXPACKS כאלטרנטיבה.