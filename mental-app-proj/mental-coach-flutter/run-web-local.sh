#!/bin/bash

# סקריפט להרצת האפליקציה בווב עם חיבור לשרת מקומי

echo "🌐 מפעיל את האפליקציה בדפדפן עם חיבור לשרת מקומי..."

# וידוא שהשרת רץ
if ! curl -s http://localhost:3000 > /dev/null; then
    echo "❌ השרת לא רץ על פורט 3000"
    echo "💡 הפעל את השרת עם: cd ../mental-coach-api && npm run dev"
    exit 1
fi

echo "✅ השרת רץ על פורט 3000"

# הרצת האפליקציה בווב
flutter run -d chrome --web-port=8080

echo "🎉 האפליקציה רצה בכתובת: http://localhost:8080"