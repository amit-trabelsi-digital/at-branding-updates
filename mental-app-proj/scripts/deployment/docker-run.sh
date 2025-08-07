#!/bin/bash

# Mental Coach Docker Runner Script
# ================================

set -e

echo "🐳 Mental Coach Docker Setup"
echo "============================"

# בדיקת קובץ .env
if [ ! -f .env ]; then
    echo "⚠️  קובץ .env לא נמצא!"
    echo "📝 יוצר קובץ .env מהדוגמה..."
    cp env.docker.example .env
    echo "✏️  אנא ערוך את קובץ .env עם הערכים שלך ואז הרץ שוב"
    exit 1
fi

# בדיקת Firebase Service Account (אופציונלי לAPI)
if [ -f "mental-coach-api/serviceAccount.json" ]; then
    echo "✅ Firebase Service Account נמצא"
else
    echo "⚠️  Firebase Service Account לא נמצא (נדרש רק אם מריצים API)"
fi

# אפשרויות הרצה
echo ""
echo "בחר אפשרות הרצה:"
echo "1) הרץ הכל (API, Admin, Flutter)"
echo "2) הרץ רק Flutter Web"
echo "3) הרץ רק Admin Panel"
echo "4) הרץ Flutter + Admin (ללא API מקומי)"
echo "5) בנה מחדש והרץ הכל"
echo "6) עצור הכל"
echo "7) נקה הכל"

read -p "בחירה [1-7]: " choice

case $choice in
    1)
        echo "🚀 מריץ את כל השירותים..."
        docker-compose up -d
        echo "✅ השירותים פועלים:"
        echo "   - Flutter Web: http://localhost:8080"
        echo "   - Admin Panel: http://localhost:9977"
        echo "   - API Server: http://localhost:3000"
        ;;
    2)
        echo "🚀 מריץ רק Flutter Web..."
        docker-compose up -d flutter-web
        echo "✅ Flutter Web פועל: http://localhost:8080"
        ;;
    3)
        echo "🚀 מריץ רק Admin Panel..."
        docker-compose up -d admin
        echo "✅ Admin Panel פועל: http://localhost:9977"
        ;;
    4)
        echo "🚀 מריץ Flutter + Admin (ללא API מקומי)..."
        docker-compose up -d flutter-web admin
        echo "✅ השירותים פועלים:"
        echo "   - Flutter Web: http://localhost:8080"
        echo "   - Admin Panel: http://localhost:9977"
        ;;
    5)
        echo "🔨 בונה מחדש..."
        docker-compose build --no-cache
        echo "🚀 מריץ את כל השירותים..."
        docker-compose up -d
        echo "✅ השירותים פועלים:"
        echo "   - Flutter Web: http://localhost:8080"
        echo "   - Admin Panel: http://localhost:9977"
        echo "   - API Server: http://localhost:3000"
        ;;
    6)
        echo "⏹️  עוצר את כל השירותים..."
        docker-compose down
        echo "✅ כל השירותים נעצרו"
        ;;
    7)
        echo "🧹 מנקה הכל..."
        docker-compose down -v
        docker system prune -f
        echo "✅ הניקוי הושלם"
        ;;
    *)
        echo "❌ בחירה לא חוקית"
        exit 1
        ;;
esac

# הצגת סטטוס
if [ "$choice" != "6" ] && [ "$choice" != "7" ]; then
    echo ""
    echo "📊 סטטוס שירותים:"
    docker-compose ps
    echo ""
    echo "📝 לצפייה בלוגים: docker-compose logs -f [service-name]"
fi