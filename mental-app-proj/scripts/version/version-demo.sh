#!/bin/bash

# Mental Coach - הדגמת מערכת ניהול גרסאות
# מריץ דוגמאות לעדכון גרסאות בכל הפרויקטים

set -e

# צבעים
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Mental Coach - הדגמת מערכת ניהול גרסאות${NC}"
echo ""

# בדיקה שאנחנו בתיקייה הנכונה
if [ ! -d "mental-coach-api" ] || [ ! -d "mental-coach-admin" ] || [ ! -d "mental-coach-flutter" ]; then
    echo -e "${RED}❌ הסקריפט חייב לרוץ מתיקיית mental-app-proj${NC}"
    exit 1
fi

# פונקציה להצגת גרסה נוכחית
show_current_versions() {
    echo -e "${CYAN}📊 גרסאות נוכחיות:${NC}"
    
    if [ -f "mental-coach-api/version.json" ]; then
        local api_version=$(node -p "JSON.parse(require('fs').readFileSync('mental-coach-api/version.json', 'utf8')).version")
        echo "  • API Server: $api_version"
    fi
    
    if [ -f "mental-coach-admin/version.json" ]; then
        local admin_version=$(node -p "JSON.parse(require('fs').readFileSync('mental-coach-admin/version.json', 'utf8')).version")
        echo "  • Admin Panel: $admin_version"
    fi
    
    if [ -f "mental-coach-flutter/version.json" ]; then
        local flutter_version=$(node -p "JSON.parse(require('fs').readFileSync('mental-coach-flutter/version.json', 'utf8')).version")
        local flutter_build=$(node -p "JSON.parse(require('fs').readFileSync('mental-coach-flutter/version.json', 'utf8')).buildNumber")
        echo "  • Flutter App: $flutter_version+$flutter_build"
    fi
    echo ""
}

# פונקציה לדוגמה של עדכון גרסה
demo_version_bump() {
    local project_dir="$1"
    local project_name="$2"
    local bump_type="$3"
    
    echo -e "${YELLOW}🔄 מעדכן $project_name ($bump_type)...${NC}"
    
    cd "$project_dir"
    
    if [ -f "scripts/bump-version.sh" ]; then
        ./scripts/bump-version.sh "$bump_type"
    else
        echo "  ⚠️ לא נמצא סקריפט bump-version.sh"
    fi
    
    cd ..
    sleep 1
}

# פונקציה לבדיקת npm scripts
check_npm_scripts() {
    local project_dir="$1"
    local project_name="$2"
    
    echo -e "${YELLOW}📦 בודק npm scripts ב-$project_name...${NC}"
    
    cd "$project_dir"
    
    if [ -f "package.json" ]; then
        if npm run | grep -q "version:"; then
            echo -e "${GREEN}  ✅ נמצאו scripts לניהול גרסאות:${NC}"
            npm run | grep "version:" | sed 's/^/    /'
        else
            echo -e "${RED}  ❌ לא נמצאו scripts לניהול גרסאות${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️ לא נמצא package.json${NC}"
    fi
    
    cd ..
    echo ""
}

# תפריט ראשי
echo "בחר פעולה לביצוע:"
echo "1) הצגת גרסאות נוכחיות"
echo "2) דוגמה לעדכון PATCH בכל הפרויקטים"
echo "3) דוגמה לעדכון MINOR בפרויקט אחד"
echo "4) בדיקת npm scripts"
echo "5) התקנת Git Hooks"
echo "6) הדגמה מלאה (כל הפונקציות)"
echo "0) יציאה"
echo ""

read -p "הכנס מספר (0-6): " choice

case $choice in
    1)
        show_current_versions
        ;;
    2)
        echo -e "${BLUE}🔄 מעדכן PATCH בכל הפרויקטים...${NC}"
        echo ""
        demo_version_bump "mental-coach-api" "API Server" "patch"
        demo_version_bump "mental-coach-admin" "Admin Panel" "patch"
        demo_version_bump "mental-coach-flutter" "Flutter App" "patch"
        echo ""
        show_current_versions
        ;;
    3)
        echo -e "${BLUE}🔄 מעדכן MINOR ב-API Server...${NC}"
        echo ""
        demo_version_bump "mental-coach-api" "API Server" "minor"
        echo ""
        show_current_versions
        ;;
    4)
        check_npm_scripts "mental-coach-api" "API Server"
        check_npm_scripts "mental-coach-admin" "Admin Panel"
        ;;
    5)
        if [ -f "scripts/install-git-hooks.sh" ]; then
            echo -e "${BLUE}🔧 מתקין Git Hooks...${NC}"
            ./scripts/install-git-hooks.sh
        else
            echo -e "${RED}❌ לא נמצא סקריפט install-git-hooks.sh${NC}"
        fi
        ;;
    6)
        echo -e "${BLUE}🎬 הדגמה מלאה של מערכת ניהול הגרסאות${NC}"
        echo ""
        
        show_current_versions
        
        echo -e "${CYAN}בודק npm scripts...${NC}"
        check_npm_scripts "mental-coach-api" "API Server"
        
        echo -e "${CYAN}מדמה עדכון minor ב-API...${NC}"
        demo_version_bump "mental-coach-api" "API Server" "minor"
        
        echo -e "${CYAN}מדמה עדכון patch באדמין...${NC}"
        demo_version_bump "mental-coach-admin" "Admin Panel" "patch"
        
        show_current_versions
        
        echo -e "${GREEN}✅ הדגמה הושלמה בהצלחה!${NC}"
        ;;
    0)
        echo -e "${GREEN}👋 להתראות!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ אפשרות לא תקינה${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ הפעולה הושלמה${NC}"
echo -e "${BLUE}💡 לפרטים נוספים: cat VERSION_MANAGEMENT_GUIDE.md${NC}"