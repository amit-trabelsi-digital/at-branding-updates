#!/bin/bash

# Docker Configuration Check Script
# =================================

echo "🔍 בודק קונפיגורציית Docker..."
echo "================================"

# בדיקת Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker מותקן: $(docker --version)"
else
    echo "❌ Docker לא מותקן!"
    exit 1
fi

# בדיקת Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose מותקן: $(docker-compose --version)"
else
    echo "❌ Docker Compose לא מותקן!"
    exit 1
fi

# בדיקת קבצים חיוניים
echo ""
echo "📁 בדיקת קבצים:"

files_to_check=(
    "docker-compose.yml"
    ".env"
    "mental-coach-flutter/Dockerfile"
    "mental-coach-flutter/nginx.conf"
    "mental-coach-flutter/docker-entrypoint.sh"
    "mental-coach-admin/Dockerfile"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file קיים"
    else
        echo "⚠️  $file חסר"
    fi
done

# בדיקת משתני סביבה
echo ""
echo "🔐 בדיקת משתני סביבה חשובים:"

if [ -f .env ]; then
    source .env
    
    # רשימת משתנים לבדיקה
    vars_to_check=(
        "DATABASE_URL"
        "FLUTTER_API_URL"
        "ADMIN_API_URL"
        "JWT_SECRET"
    )
    
    for var in "${vars_to_check[@]}"; do
        if [ -n "${!var}" ]; then
            echo "✅ $var מוגדר"
        else
            echo "⚠️  $var לא מוגדר"
        fi
    done
else
    echo "❌ קובץ .env לא נמצא!"
fi

# בדיקת תיקיות assets
echo ""
echo "🖼️  בדיקת תיקיות תמונות:"

asset_dirs=(
    "mental-coach-flutter/assets"
    "mental-coach-flutter/images"
    "mental-coach-flutter/icons"
)

for dir in "${asset_dirs[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f | wc -l)
        echo "✅ $dir קיים ($count קבצים)"
    else
        echo "⚠️  $dir לא קיים"
    fi
done

# סיכום
echo ""
echo "================================"
echo "📊 סיכום:"
echo "- השתמש ב-'./docker-run.sh' להרצה"
echo "- ערוך את .env לפי הצורך"
echo "- בדוק את DOCKER_SETUP_GUIDE.md למידע נוסף"