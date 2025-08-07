#!/bin/bash

# סקריפט להרצת האפליקציה על iOS עם העלאת גרסה אוטומטית

set -e # יציאה במקרה של שגיאה

# צבעים להדפסות
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Mental Coach - הרצה על iOS${NC}"
echo ""

# העלאת גרסה
echo -e "${YELLOW}📱 מעלה גרסה...${NC}"
./bump-version.sh
echo ""

# חיפוש מכשירי iOS
echo -e "${YELLOW}🔍 מחפש מכשירי iOS...${NC}"
flutter devices | grep -E "iPhone|iPad"
echo ""

# קבלת ה-device ID של האייפון
DEVICE_ID=$(flutter devices | grep "iPhone" | grep -oE "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}⚠️  לא נמצא אייפון מחובר${NC}"
    echo "מנסה להריץ על סימולטור..."
    flutter run
else
    echo -e "${GREEN}✅ נמצא אייפון: $DEVICE_ID${NC}"
    echo ""
    echo -e "${BLUE}🏃 מריץ את האפליקציה...${NC}"
    flutter run -d "$DEVICE_ID"
fi