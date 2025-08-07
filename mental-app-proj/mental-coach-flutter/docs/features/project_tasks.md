# משימות פרויקט - המאמן המנטלי

## תאריך: 11 יולי 2024

### משימות:
- [ ] יצירת גרסת אנדרואיד (AAB) והעלאה לחנות.
- [ ] עדכון מאגר ה-GitHub עם כל השינויים.

---

## תאריך: 9 יולי 2024

### משימות שבוצעו:
1. ✅ עדכון גרסה ל-0.8.0+2 בקובץ pubspec.yaml
2. ✅ יצירת מפתח חתימה חדש לאנדרואיד (mental-coach-upload-keystore.jks)
3. ✅ יצירת קובץ key.properties עם פרטי החתימה
4. ✅ בנייה מוצלחת של Android App Bundle (AAB)
5. ✅ בנייה מוצלחת של iOS App
6. ✅ תיקון שגיאות Google Play Console:
   - עדכון targetSdk ו-compileSdk ל-35
   - הוספת הרשאת com.google.android.gms.permission.AD_ID
7. 🔄 בנייה מחדש של AAB עם התיקונים

### קבצים שנוצרו/עודכנו:
- `pubspec.yaml` - עדכון גרסה
- `android/key.properties` - פרטי חתימה (לא בגיט)
- `android/app/build.gradle` - עדכון SDK levels
- `android/app/src/main/AndroidManifest.xml` - הוספת הרשאת AD_ID
- `~/mental-coach-upload-keystore.jks` - מפתח חתימה (לא בגיט)

### קבצי פלט:
- `build/app/outputs/bundle/release/app-release.aab` - קובץ AAB לאנדרואיד
- `build/ios/iphoneos/Runner.app` - אפליקציית iOS

### משימות הבאות:
- [ ] השלמת בנייה מחדש של AAB
- [ ] יצירת IPA ל-iOS
- [ ] העלאה לחנויות