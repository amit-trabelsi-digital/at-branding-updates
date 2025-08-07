#!/bin/bash

# Mental Coach - הרצת Flutter על סימולטור iPhone 16

set -e

# צבעים
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Mental Coach - הרצת Flutter על סימולטור${NC}"
echo ""

# בדיקה שאנחנו בתיקייה הנכונה
if [ ! -d "mental-coach-flutter" ]; then
    echo -e "${RED}[ERROR]${NC} הסקריפט חייב לרוץ מתיקיית mental-app-proj"
    exit 1
fi

# פונקציה לבחירת סימולטור
select_simulator() {
    echo -e "${BLUE}בוחר סימולטור...${NC}"
    
    # הצגת סימולטורים זמינים
    echo ""
    echo "סימולטורים זמינים:"
    xcrun simctl list devices available | grep -E "iPhone|iPad" | grep -v "unavailable" | nl
    
    echo ""
    echo "אפשרויות מומלצות:"
    echo "1) iPhone 16"
    echo "2) iPhone 16 Pro"
    echo "3) iPhone 16 Pro Max"
    echo "4) iPhone 15"
    echo "5) iPhone 15 Pro"
    echo "6) בחר מהרשימה המלאה"
    echo ""
    read -p "בחר אפשרות [1-6]: " choice
    
    case $choice in
        1) DEVICE_NAME="iPhone 16" ;;
        2) DEVICE_NAME="iPhone 16 Pro" ;;
        3) DEVICE_NAME="iPhone 16 Pro Max" ;;
        4) DEVICE_NAME="iPhone 15" ;;
        5) DEVICE_NAME="iPhone 15 Pro" ;;
        6) 
            read -p "הכנס את שם הסימולטור במדויק: " DEVICE_NAME
            ;;
        *)
            echo -e "${RED}בחירה לא תקינה${NC}"
            exit 1
            ;;
    esac
}

# פונקציה להפעלת סימולטור
start_simulator() {
    echo -e "${BLUE}בודק אם הסימולטור פועל...${NC}"
    
    if ! xcrun simctl list devices | grep -q "$DEVICE_NAME.*Booted"; then
        echo -e "${YELLOW}מפעיל סימולטור $DEVICE_NAME...${NC}"
        
        # פתיחת אפליקציית Simulator
        open -a Simulator
        sleep 2
        
        # הפעלת הסימולטור הספציפי
        if xcrun simctl boot "$DEVICE_NAME" 2>/dev/null; then
            echo -e "${GREEN}סימולטור $DEVICE_NAME הופעל בהצלחה${NC}"
        else
            echo -e "${RED}שגיאה בהפעלת $DEVICE_NAME${NC}"
            echo "מנסה למצוא סימולטור דומה..."
            
            # חיפוש סימולטור דומה
            SIMILAR=$(xcrun simctl list devices available | grep -i "${DEVICE_NAME%% *}" | head -1 | sed 's/.*(\(.*\)).*/\1/')
            if [ ! -z "$SIMILAR" ]; then
                echo -e "${YELLOW}מנסה להפעיל סימולטור דומה...${NC}"
                xcrun simctl boot "$SIMILAR" 2>/dev/null && DEVICE_NAME="$SIMILAR"
            else
                echo -e "${RED}לא נמצא סימולטור מתאים${NC}"
                exit 1
            fi
        fi
        
        echo -e "${BLUE}ממתין לסימולטור להיות מוכן...${NC}"
        sleep 10
    else
        echo -e "${GREEN}סימולטור $DEVICE_NAME כבר פועל${NC}"
    fi
}

# פונקציה להרצת Flutter
run_flutter() {
    echo -e "${BLUE}מריץ את אפליקציית Flutter על $DEVICE_NAME...${NC}"
    cd mental-coach-flutter
    
    # ניסיון להריץ על הסימולטור הנבחר
    if flutter run -d "$DEVICE_NAME"; then
        echo -e "${GREEN}האפליקציה רצה בהצלחה${NC}"
    else
        # אם נכשל, מנסה עם device ID
        echo -e "${YELLOW}מנסה עם device ID...${NC}"
        DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -o '([A-F0-9-]*)' | tr -d '()')
        if [ ! -z "$DEVICE_ID" ]; then
            flutter run -d "$DEVICE_ID"
        else
            echo -e "${RED}לא הצלחתי להריץ את האפליקציה${NC}"
            exit 1
        fi
    fi
}

# פונקציה ראשית
main() {
    # ברירת מחדל - iPhone 16
    DEVICE_NAME="iPhone 16"
    
    # בדיקה אם יש פרמטר
    if [ $# -eq 1 ]; then
        case $1 in
            --select|-s)
                select_simulator
                ;;
            --help|-h)
                echo "שימוש: $0 [אפשרויות]"
                echo "אפשרויות:"
                echo "  --select, -s    בחר סימולטור ידנית"
                echo "  --help, -h      הצג עזרה"
                echo ""
                echo "ללא פרמטרים, יריץ על iPhone 16"
                exit 0
                ;;
            *)
                DEVICE_NAME="$1"
                ;;
        esac
    fi
    
    echo -e "${BLUE}מכין להרצה על: $DEVICE_NAME${NC}"
    echo ""
    
    # בדיקה ש-API רץ
    if ! curl -s http://localhost:3000 > /dev/null; then
        echo -e "${YELLOW}[WARNING] נראה ש-API לא רץ על פורט 3000${NC}"
        echo -e "${YELLOW}מומלץ להריץ קודם את ./run-all.sh או ./quick-start.sh${NC}"
        echo ""
        read -p "להמשיך בכל זאת? [y/N]: " continue
        if [[ ! $continue =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    start_simulator
    run_flutter
}

# הרצת הסקריפט
main "$@" 