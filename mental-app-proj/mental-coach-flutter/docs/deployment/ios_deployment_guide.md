# מדריך העלאת אפליקציית "המאמן המנטלי" ל-App Store

## שלב 1: הכנות ראשוניות

### עדכון Bundle Identifier
הBundle ID הנוכחי בפרויקט אינו תקני. יש לעדכון אותו:

1. פתח את הפרויקט ב-Xcode:
   ```bash
   cd mental-coach-flutter/ios
   open Runner.xcworkspace
   ```

2. בחר בפרויקט Runner בסייד בר השמאלי
3. לחץ על TARGETS > Runner
4. בטאב General, עדכן את Bundle Identifier ל:
   ```
   com.mentalcoach.app
   ```
   (או כל Bundle ID אחר שרשום בחשבון ה-Developer של הלקוח)

### עדכון גרסת האפליקציה
עדכן את הגרסה ב-`pubspec.yaml`:
```yaml
version: 1.0.0+1
```

## שלב 2: הגדרת חתימה דיגיטלית

1. ב-Xcode, בטאב "Signing & Capabilities":
   - סמן את "Automatically manage signing"
   - בחר את ה-Team של חשבון הפיתוח של הלקוח
   - וודא שה-Bundle Identifier תואם לזה שהוגדר ב-App Store Connect

2. אם יש בעיות חתימה:
   - היכנס ל-Apple Developer Portal
   - צור App ID חדש עם ה-Bundle Identifier
   - צור Provisioning Profile חדש

## שלב 3: בדיקת הגדרות נוספות

### הגדרות חובה ל-App Store:
1. תמיכה באייפד - כרגע האפליקציה תומכת רק ב-iPhone. אם רוצים להעלות ל-App Store:
   - או להוסיף תמיכה מלאה באייפד
   - או להגדיר שהאפליקציה ל-iPhone בלבד

2. הרשאות נדרשות - יש להוסיף ל-Info.plist:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>האפליקציה צריכה גישה למצלמה לצורך העלאת תמונת פרופיל</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>האפליקציה צריכה גישה לספריית התמונות לצורך בחירת תמונת פרופיל</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>האפליקציה צריכה גישה למיקרופון לצורך הקלטת הודעות קוליות</string>
   ```

## שלב 4: בניית האפליקציה

1. נקה את הפרויקט:
   ```bash
   flutter clean
   cd ios && pod install
   ```

2. בנה את האפליקציה ב-Release mode:
   ```bash
   flutter build ios --release
   ```

## שלב 5: ארכוב והעלאה

1. ב-Xcode:
   - בחר Generic iOS Device בתור היעד
   - Product > Archive
   - המתן לסיום תהליך הארכוב

2. ב-Organizer שנפתח:
   - בחר את הארכיב שנוצר
   - לחץ על "Distribute App"
   - בחר "App Store Connect"
   - עקוב אחר ההוראות

## שלב 6: הכנת App Store Connect

1. היכנס ל-App Store Connect עם חשבון הלקוח
2. צור אפליקציה חדשה או עדכן קיימת
3. הוסף את המידע הנדרש:
   - תיאור האפליקציה
   - צילומי מסך (לכל גודל מכשיר נתמך)
   - אייקון האפליקציה
   - מילות מפתח
   - קטגוריה

## בעיות נפוצות ופתרונות

### Bundle ID לא תואם
- וודא שה-Bundle ID זהה ב-Xcode וב-App Store Connect
- בדוק שאין רווחים או תווים לא חוקיים

### בעיות חתימה
- וודא שאתה מחובר עם Apple ID הנכון ב-Xcode
- בדוק שיש לך הרשאות Developer בחשבון

### דחיית האפליקציה
סיבות נפוצות:
- חסרות הרשאות ב-Info.plist
- באגים או קריסות
- תוכן לא הולם
- הפרת הנחיות Apple

## פרמטרים לעדכון עבור חשבון הלקוח:

1. **Bundle Identifier**: `com.mentalcoach.app` (או לפי מה שהוגדר בחשבון)
2. **Team ID**: יש להחליף עם ה-Team ID של הלקוח
3. **App Name**: "המאמן המנטלי"
4. **App ID**: יווצר אוטומטית ב-App Store Connect

## צ'קליסט סופי:
- [ ] Bundle ID מעודכן ותואם
- [ ] גרסה עודכנה ב-pubspec.yaml
- [ ] חתימה דיגיטלית מוגדרת נכון
- [ ] כל ההרשאות הוגדרו ב-Info.plist
- [ ] האפליקציה נבדקה על מכשיר אמיתי
- [ ] צילומי מסך הוכנו לכל הגדלים
- [ ] תיאור ומידע באפליקציה מוכנים 