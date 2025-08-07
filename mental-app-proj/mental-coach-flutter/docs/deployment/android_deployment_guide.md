# מדריך העלאת אפליקציית "המאמן המנטלי" ל-Google Play (Internal Testing)

## סקירה כללית
מדריך זה מסביר כיצד להכין ולהעלות את האפליקציה למסלול Internal Testing ב-Google Play Console, 
מה שיאפשר למשתמשי אנדרואיד מורשים להוריד ולבדוק את האפליקציה.

## שלב 1: הכנות ראשוניות

### עדכון Application ID
בדוק את ה-Application ID בקובץ `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.mentalcoach.app"  // עדכן בהתאם לחשבון הלקוח
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### עדכון גרסת האפליקציה
וודא שהגרסה ב-`pubspec.yaml` מתואמת:
```yaml
version: 1.0.0+1  # versionName+versionCode
```

## שלב 2: יצירת מפתח חתימה

1. צור מפתח חדש (אם אין קיים):
```bash
keytool -genkey -v -keystore ~/mental-coach-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mental-coach-key
```

2. שמור את הפרטים במקום בטוח:
   - סיסמת keystore
   - סיסמת מפתח
   - alias

3. צור קובץ `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=mental-coach-key
storeFile=/Users/YOUR_USER/mental-coach-keystore.jks
```

4. עדכן את `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## שלב 3: בניית האפליקציה

1. נקה את הפרויקט:
```bash
flutter clean
```

2. בנה App Bundle (מומלץ) או APK:
```bash
# App Bundle (מומלץ לGoogle Play)
flutter build appbundle --release

# או APK (לבדיקה ישירה)
flutter build apk --release
```

הקבצים יווצרו ב:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

## שלב 4: העלאה ל-Google Play Console

### הגדרת Internal Testing:

1. היכנס ל-[Google Play Console](https://play.google.com/console)
2. בחר באפליקציה או צור חדשה
3. נווט ל: **Testing > Internal testing**

### יצירת מסלול בדיקה:

1. לחץ על "Create new release"
2. העלה את קובץ ה-`.aab`
3. הוסף release notes (בעברית):
   ```
   גרסת בדיקה ראשונה של אפליקציית המאמן המנטלי
   - ממשק משתמש בעברית
   - תמיכה במסכי אימון מנטלי
   - ניהול משחקים ואימונים
   ```

4. לחץ על "Save" ואז "Review release"

### הוספת בודקים:

1. ב-"Testers" לחץ על "Manage testers"
2. הוסף כתובות דוא"ל של הבודקים
3. או צור רשימת דוא"ל ב-Google Groups

### שיתוף קישור הבדיקה:

לאחר פרסום המסלול, תקבל קישור בפורמט:
```
https://play.google.com/apps/internaltest/XXXXXXXXXXXXX
```

שלח את הקישור לבודקים עם ההוראות הבאות:

## הוראות לבודקים:

1. **הצטרפות לתוכנית הבדיקה:**
   - פתח את הקישור שקיבלת
   - לחץ על "Become a tester"
   - אשר את ההצטרפות

2. **הורדת האפליקציה:**
   - המתן כ-15 דקות להפצה
   - חפש "המאמן המנטלי" ב-Play Store
   - או השתמש בקישור הישיר מדף הבדיקה

3. **דיווח על בעיות:**
   - שלח משוב דרך האפליקציה
   - או דווח ישירות למפתחים

## בדיקות נדרשות לפני העלאה:

- [ ] האפליקציה רצה ללא קריסות
- [ ] כל המסכים נטענים כראוי
- [ ] התחברות עובדת (Google/Apple/Email)
- [ ] הרשאות (מצלמה, מיקרופון) מבוקשות נכון
- [ ] ביצועים סבירים על מכשירים שונים

## הגדרות נוספות ב-Play Console:

### פרטי האפליקציה:
- **שם**: המאמן המנטלי
- **תיאור קצר**: אימון מנטלי מקצועי לכדורגלנים
- **תיאור מלא**: (הוסף תיאור מפורט)
- **קטגוריה**: ספורט
- **תגיות**: כדורגל, אימון מנטלי, ספורט

### צילומי מסך:
נדרשים לפחות 2 צילומי מסך לכל סוג:
- טלפון (1080x1920 או דומה)
- טאבלט 7" (אם תומך)
- טאבלט 10" (אם תומך)

### מדיניות תוכן:
- [ ] מלא את שאלון דירוג התוכן
- [ ] אשר את מדיניות הפרטיות
- [ ] הוסף קישור למדיניות פרטיות

## טיפים לבדיקה יעילה:

1. **בדוק על מגוון מכשירים:**
   - גרסאות Android שונות (7.0+)
   - גדלי מסך שונים
   - יצרנים שונים

2. **בדוק תרחישים קריטיים:**
   - התחברות/התנתקות
   - אובדן חיבור לאינטרנט
   - מעבר בין מסכים
   - שמירת נתונים

3. **ניטור ביצועים:**
   - השתמש ב-Play Console לניטור קריסות
   - בדוק דוחות ANR (Application Not Responding)
   - עקוב אחר ביקורות הבודקים

## מעבר ל-Production:

לאחר בדיקה מוצלחת ב-Internal Testing:
1. תקן את כל הבאגים שנמצאו
2. העלה גרסה מתוקנת
3. שקול מעבר ל-Closed Testing (אלפא/בטא)
4. לבסוף - Open Testing או Production

## בעיות נפוצות:

### האפליקציה לא מופיעה לבודקים:
- וודא שעברו 15 דקות מההעלאה
- בדוק שהבודק הצטרף לתוכנית
- נסה לנקות את המטמון של Play Store

### שגיאות חתימה:
- וודא שה-keystore נכון
- בדוק שה-passwords נכונים
- וודא שה-alias תואם

### דחייה ע"י Google:
- בדוק הפרות מדיניות
- תקן הרשאות לא מוסברות
- הסר תוכן בעייתי 