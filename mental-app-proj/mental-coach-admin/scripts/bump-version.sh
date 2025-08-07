#!/bin/bash

# Mental Coach Admin - Version Bumping Script
# מנהל עדכון גרסאות אוטומטי על פי הנחיות Semantic Versioning

set -e

# צבעים לפלט
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# נתיבי קבצים
VERSION_FILE="version.json"
PACKAGE_FILE="package.json"
VERSION_TS_FILE="src/utils/version.ts"

# פונקציה לקריאת גרסה נוכחית
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        node -p "JSON.parse(require('fs').readFileSync('$VERSION_FILE', 'utf8')).version"
    else
        echo "1.0.1"
    fi
}

# פונקציה ליצירת build number
generate_build() {
    echo "$(date +'%Y.%m.%d').$(printf '%03d' $(($(date +'%H%M') % 1000)))"
}

# פונקציה לעדכון גרסה
update_version() {
    local new_version="$1"
    local build="$(generate_build)"
    local build_date="$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')"
    
    # עדכון version.json
    cat > "$VERSION_FILE" << EOF
{
  "version": "$new_version",
  "build": "$build",
  "name": "mental-coach-admin",
  "description": "Mental Coach Admin Panel - Management Interface",
  "buildDate": "$build_date"
}
EOF
    
    # עדכון package.json
    if [[ -f "$PACKAGE_FILE" ]]; then
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('$PACKAGE_FILE', 'utf8'));
            pkg.version = '$new_version';
            fs.writeFileSync('$PACKAGE_FILE', JSON.stringify(pkg, null, 2) + '\\n');
        "
    fi
    
    # עדכון version.ts
    if [[ -f "$VERSION_TS_FILE" ]]; then
        cat > "$VERSION_TS_FILE" << EOF
// גרסת הממשק - מתעדכן עם כל build חדש
export const ADMIN_VERSION = "$new_version";

// סביבת הרצה
export const getEnvironment = () => {
  return import.meta.env.MODE || 'production';
};

// צבע לפי סביבה
export const getEnvironmentColor = () => {
  const env = getEnvironment();
  switch (env) {
    case 'development':
      return 'warning';
    case 'production':
      return 'success';
    case 'test':
      return 'info';
    default:
      return 'default';
  }
};

// פרטי Build
export const BUILD_INFO = {
  version: "$new_version",
  build: "$build",
  buildDate: "$build_date"
};
EOF
    fi
    
    echo -e "${GREEN}✓ עודכן ל-$new_version (build: $build)${NC}"
}

# פונקציה להעלאת גרסה
bump_version() {
    local bump_type="$1"
    local current_version="$(get_current_version)"
    local new_version
    
    # פיצול הגרסה למרכיבים
    IFS='.' read -r -a version_parts <<< "$current_version"
    local major="${version_parts[0]}"
    local minor="${version_parts[1]}"
    local patch="${version_parts[2]}"
    
    case "$bump_type" in
        "major")
            new_version="$((major + 1)).0.0"
            ;;
        "minor")
            new_version="$major.$((minor + 1)).0"
            ;;
        "patch")
            new_version="$major.$minor.$((patch + 1))"
            ;;
        *)
            echo -e "${RED}❌ סוג bump לא תקין: $bump_type${NC}"
            exit 1
            ;;
    esac
    
    update_version "$new_version"
}

# פונקציה לזיהוי סוג השינוי מ-commit message
detect_bump_type() {
    local commit_msg="$1"
    
    if [[ "$commit_msg" =~ ^BREAKING || "$commit_msg" =~ BREAKING\ CHANGE ]]; then
        echo "major"
    elif [[ "$commit_msg" =~ ^feat: ]]; then
        echo "minor"
    elif [[ "$commit_msg" =~ ^fix: ]]; then
        echo "patch"
    else
        echo "patch"  # ברירת מחדל
    fi
}

# פונקציה לעזרה
show_help() {
    echo "Mental Coach Admin - Version Bumping Script"
    echo ""
    echo "שימוש:"
    echo "  $0 [major|minor|patch|auto]"
    echo ""
    echo "דוגמאות:"
    echo "  $0 patch    # הגדלת מספר תיקון"
    echo "  $0 minor    # הוספת תכונה"
    echo "  $0 major    # שינוי שובר תאימות"
    echo "  $0 auto     # זיהוי אוטומטי לפי commit message"
    echo ""
    echo "כללי Commit Messages:"
    echo "  feat: תכונה חדשה → minor"
    echo "  fix: תיקון באג → patch"
    echo "  BREAKING CHANGE: שינוי שובר → major"
    echo "  אחר → patch"
}

# עיבוד ארגומנטים
case "${1:-auto}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    "major"|"minor"|"patch")
        echo -e "${BLUE}🔄 מעדכן גרסה ($1)...${NC}"
        bump_version "$1"
        ;;
    "auto")
        # זיהוי אוטומטי מ-commit message האחרון
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            local last_commit=$(git log -1 --pretty=%B 2>/dev/null || echo "")
            local bump_type=$(detect_bump_type "$last_commit")
            echo -e "${BLUE}🔄 זיהוי אוטומטי: $bump_type (מסר: ${last_commit:0:50}...)${NC}"
            bump_version "$bump_type"
        else
            echo -e "${YELLOW}⚠️ לא בתיקיית Git, משתמש ב-patch${NC}"
            bump_version "patch"
        fi
        ;;
    *)
        echo -e "${RED}❌ ארגומנט לא תקין: $1${NC}"
        show_help
        exit 1
        ;;
esac

echo -e "${GREEN}✅ עדכון הגרסה הושלם${NC}"