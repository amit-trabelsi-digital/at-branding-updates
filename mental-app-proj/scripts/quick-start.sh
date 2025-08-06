#!/bin/bash

# Mental Coach - סקריפט הרצה מהירה
# מריץ את כל הרכיבים ללא תפריט

set -e

# צבעים
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Mental Coach - הרצה מהירה${NC}"
echo ""

# בדיקה שאנחנו בתיקייה הנכונה
if [ ! -d "mental-coach-api" ] || [ ! -d "mental-coach-admin" ] || [ ! -d "mental-coach-flutter" ]; then
    echo -e "${RED}[ERROR]${NC} הסקריפט חייב לרוץ מתיקיית mental-app-proj"
    exit 1
fi

# פונקציה לעצירת כל השירותים
cleanup() {
    echo -e "\n${YELLOW}עוצר את כל השירותים...${NC}"
    pkill -f "node.*mental-coach" 2>/dev/null || true
    echo -e "${GREEN}השירותים נעצרו${NC}"
}

trap cleanup EXIT

# הרצת API
echo -e "${GREEN}[1/3]${NC} מפעיל את שרת ה-API..."
cd mental-coach-api
npm run dev:fresh > ../api.log 2>&1 &
API_PID=$!
cd ..
sleep 8

# הרצת Admin
echo -e "${GREEN}[2/3]${NC} מפעיל את פאנל הניהול..."
cd mental-coach-admin
npm run dev > ../admin.log 2>&1 &
ADMIN_PID=$!
cd ..
sleep 5

# הצגת כתובות
echo ""
echo -e "${GREEN}השירותים פועלים:${NC}"
echo "  • API Server: http://localhost:3000"
echo "  • Admin Panel: http://localhost:5173"
echo ""
echo -e "${YELLOW}לחץ Ctrl+C כדי לעצור את כל השירותים${NC}"
echo ""

# הרצת Flutter
echo -e "${GREEN}[3/3]${NC} מפעיל את אפליקציית Flutter..."
cd mental-coach-flutter

# בדיקה והפעלת סימולטור iPhone 16
if ! xcrun simctl list devices | grep -q "iPhone 16.*Booted"; then
    echo -e "${GREEN}מפעיל סימולטור iPhone 16...${NC}"
    open -a Simulator
    sleep 3
    xcrun simctl boot "iPhone 16" 2>/dev/null || xcrun simctl boot "iPhone 16 Pro" 2>/dev/null
    sleep 10
fi

echo -e "${GREEN}מריץ על סימולטור iPhone 16${NC}"
flutter run -d "iPhone 16" || flutter run -d "iPhone 16 Pro" 