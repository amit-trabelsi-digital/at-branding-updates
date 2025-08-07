# פתרון בעיות הרצת האפליקציה על iOS

## תאריך: 27/01/2025

### בעיות נפוצות ופתרונות:

## 1. בעיית webview_flutter_wkwebview

**שגיאה:**
```
Build input file cannot be found: webview_flutter_wkwebview_privacy.bundle
```

**פתרונות:**

### פתרון א' - ניקוי מלא והתקנה מחדש:
```bash
# 1. מחק את כל הקבצים הזמניים
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf build/
rm -rf .dart_tool/

# 2. נקה את Flutter
flutter clean

# 3. עדכן dependencies
flutter pub get

# 4. התקן pods מחדש
cd ios
pod install --repo-update
cd ..

# 5. נסה להריץ שוב
flutter run -d [device-id]
```

### פתרון ב' - בנייה דרך Xcode:
```bash
# 1. פתח את הפרויקט ב-Xcode
cd ios
open Runner.xcworkspace

# 2. ב-Xcode:
# - בחר את המכשיר שלך
# - לחץ על Product > Clean Build Folder (Shift+Cmd+K)
# - לחץ על Product > Build (Cmd+B)
# - אם הבנייה הצליחה, לחץ על Product > Run (Cmd+R)
```

## 2. בעיות חתימה (Code Signing)

**פתרונות:**

### ב-Xcode:
1. פתח את Runner.xcworkspace
2. בחר את הפרויקט Runner בסייד-בר
3. לך ל-Signing & Capabilities
4. וודא ש:
   - "Automatically manage signing" מסומן
   - Team נבחר (GXNJSXP8RL)
   - Bundle Identifier נכון

## 3. בעיות CocoaPods

**אזהרה נפוצה:**
```
CocoaPods did not set the base configuration...
```

**פתרון:**
זו רק אזהרה ולא אמורה למנוע הרצה. אם יש בעיות:

```bash
cd ios
pod deintegrate
pod install
```

## 4. הרצה על מכשיר פיזי

### וודא ש:
1. המכשיר מחובר ונמצא באותה רשת WiFi
2. Developer Mode מופעל במכשיר (Settings > Privacy & Security > Developer Mode)
3. המכשיר סומך במחשב (Trust This Computer)

### מציאת ה-Device ID:
```bash
flutter devices
```

### הרצה עם Device ID:
```bash
flutter run -d [device-id]
# לדוגמה:
flutter run -d 00008140-0016010E146B001C
```

## 5. טיפים נוספים

### הרצה עם מידע מפורט:
```bash
flutter run -d [device-id] --verbose
```

### בדיקת סטטוס:
```bash
flutter doctor -v
```

### עדכון Flutter ו-Pods:
```bash
flutter upgrade
cd ios && pod update && cd ..
```

## 6. אם כלום לא עובד

1. **צור פרויקט Flutter חדש לבדיקה:**
   ```bash
   flutter create test_app
   cd test_app
   flutter run
   ```
   אם זה עובד, הבעיה ספציפית לפרויקט.

2. **בדוק את ה-logs:**
   - ב-Xcode: View > Debug Area > Activate Console
   - בטרמינל: הוסף `--verbose` לפקודת flutter run

3. **עדכן את Xcode:**
   - App Store > Updates > Xcode

4. **אתחל את המכשיר:**
   - לפעמים אתחול פשוט פותר בעיות תקשורת