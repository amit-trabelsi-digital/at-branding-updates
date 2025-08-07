#!/bin/bash

# Mental Coach - התקנת Git Hooks לעדכון גרסאות אוטומטי
# מתקין pre-commit hooks בכל שלושת הפרויקטים

set -e

# צבעים
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 מתקין Git Hooks לעדכון גרסאות אוטומטי${NC}"
echo ""

# בדיקה שאנחנו בתיקיית הפרויקט הראשית
if [ ! -d "mental-coach-api" ] || [ ! -d "mental-coach-admin" ] || [ ! -d "mental-coach-flutter" ]; then
    echo -e "${RED}❌ הסקריפט חייב לרוץ מתיקיית mental-app-proj${NC}"
    exit 1
fi

# פונקציה להתקנת hook בפרויקט ספציפי
install_hook_for_project() {
    local project_dir="$1"
    local project_name="$2"
    
    echo -e "${YELLOW}📁 מתקין hook עבור $project_name...${NC}"
    
    cd "$project_dir"
    
    # יצירת תיקיית hooks אם לא קיימת
    mkdir -p .git/hooks
    
    # יצירת pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Mental Coach - Pre-commit Hook לעדכון גרסה אוטומטי

# בדיקה אם יש סקריפט bump-version
if [ -f "scripts/bump-version.sh" ]; then
    echo "🔄 מעדכן גרסה אוטומטית..."
    
    # הרצת סקריפט עדכון גרסה
    bash scripts/bump-version.sh auto
    
    # הוספת קבצי הגרסה ל-staging
    git add version.json 2>/dev/null || true
    git add package.json 2>/dev/null || true
    git add pubspec.yaml 2>/dev/null || true
    git add src/utils/version.ts 2>/dev/null || true
    
    echo "✅ הגרסה עודכנה ונוספה ל-commit"
else
    echo "⚠️ לא נמצא סקריפט bump-version.sh"
fi

# המשך עם commit רגיל
exit 0
EOF
    
    # הפיכת ה-hook לקובץ הרץ
    chmod +x .git/hooks/pre-commit
    
    echo -e "${GREEN}✅ Hook הותקן בהצלחה עבור $project_name${NC}"
    cd ..
}

# התקנת hooks בכל הפרויקטים
install_hook_for_project "mental-coach-api" "API Server"
install_hook_for_project "mental-coach-admin" "Admin Panel"
install_hook_for_project "mental-coach-flutter" "Flutter App"

echo ""
echo -e "${GREEN}🎉 Git Hooks הותקנו בהצלחה!${NC}"
echo ""
echo -e "${BLUE}כעת כל commit יעדכן אוטומטית את הגרסה על פי:${NC}"
echo "  • feat: תכונה חדשה → MINOR version"
echo "  • fix: תיקון באג → PATCH version"
echo "  • BREAKING CHANGE → MAJOR version"
echo "  • אחר → PATCH version"
echo ""
echo -e "${YELLOW}לביטול ההתקנה, הרץ:${NC} rm -f */.*/.git/hooks/pre-commit"