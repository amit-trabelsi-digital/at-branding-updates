#!/bin/bash

# Mental Coach - סקריפט התקנה והרצה מלא
# מריץ את כל שלושת הרכיבים של המערכת

set -e  # יציאה במקרה של שגיאה

# צבעים להדפסות
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# פונקציות עזר
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# בדיקת תלויות מערכת
check_dependencies() {
    print_status "בודק תלויות מערכת..."
    
    # בדיקת Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js לא מותקן. אנא התקן Node.js לפני הרצת הסקריפט."
        exit 1
    fi
    print_success "Node.js מותקן - גרסה: $(node --version)"
    
    # בדיקת npm
    if ! command -v npm &> /dev/null; then
        print_error "npm לא מותקן. אנא התקן npm לפני הרצת הסקריפט."
        exit 1
    fi
    print_success "npm מותקן - גרסה: $(npm --version)"
    
    # בדיקת Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter לא מותקן. אנא התקן Flutter לפני הרצת הסקריפט."
        exit 1
    fi
    print_success "Flutter מותקן - גרסה: $(flutter --version | head -n 1)"
    
    # בדיקת MongoDB
    if ! pgrep -x "mongod" > /dev/null; then
        print_warning "MongoDB לא רץ. מנסה להפעיל..."
        if command -v mongod &> /dev/null; then
            mongod --fork --logpath /tmp/mongodb.log --dbpath /usr/local/var/mongodb || {
                print_warning "לא הצלחתי להפעיל את MongoDB אוטומטית. אנא הפעל ידנית."
            }
        else
            print_warning "MongoDB לא מותקן או לא רץ. אנא וודא ש-MongoDB פועל."
        fi
    else
        print_success "MongoDB רץ"
    fi
}

# התקנת תלויות API
install_api_dependencies() {
    print_status "מתקין תלויות עבור mental-coach-api..."
    cd mental-coach-api
    
    if [ -f "package.json" ]; then
        npm install
        print_success "תלויות API הותקנו בהצלחה"
    else
        print_error "לא נמצא package.json בתיקיית API"
        exit 1
    fi
    
    # בדיקת קובץ .env
    if [ ! -f ".env" ]; then
        print_warning "לא נמצא קובץ .env, יוצר קובץ דוגמה..."
        cat > .env << EOL
PORT=3000
NODE_ENV=development
MONGO_URI_DEV=mongodb://localhost:27017/
DB_NAME=mental-coach
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here
EOL
        print_warning "נוצר קובץ .env עם הגדרות ברירת מחדל. אנא עדכן את SENDGRID_API_KEY"
    fi
    
    cd ..
}

# התקנת תלויות Admin
install_admin_dependencies() {
    print_status "מתקין תלויות עבור mental-coach-admin..."
    cd mental-coach-admin
    
    if [ -f "package.json" ]; then
        npm install
        print_success "תלויות Admin הותקנו בהצלחה"
    else
        print_error "לא נמצא package.json בתיקיית Admin"
        exit 1
    fi
    
    cd ..
}

# התקנת תלויות Flutter
install_flutter_dependencies() {
    print_status "מתקין תלויות עבור mental-coach-flutter..."
    cd mental-coach-flutter
    
    if [ -f "pubspec.yaml" ]; then
        flutter pub get
        print_success "תלויות Flutter הותקנו בהצלחה"
    else
        print_error "לא נמצא pubspec.yaml בתיקיית Flutter"
        exit 1
    fi
    
    cd ..
}

# הרצת API Server
run_api_server() {
    print_status "מפעיל את שרת ה-API..."
    cd mental-coach-api
    
    # שימוש בסקריפט הקיים להרוג תהליכים על הפורט
    print_status "מנקה תהליכים קיימים על פורט 3000..."
    npm run kill-port
    
    # הרצת השרת ברקע עם dev:fresh שכולל ניקוי פורט
    npm run dev:fresh > ../api.log 2>&1 &
    API_PID=$!
    
    print_status "ממתין לשרת API להיות מוכן..."
    sleep 8
    
    # בדיקה שהשרת רץ
    if curl -s http://localhost:3000 > /dev/null || curl -s http://localhost:3000/api > /dev/null; then
        print_success "שרת API רץ בהצלחה על פורט 3000 (PID: $API_PID)"
    else
        print_error "שרת API לא הצליח לעלות. בדוק את api.log לפרטים."
        exit 1
    fi
    
    cd ..
}

# הרצת Admin Panel
run_admin_panel() {
    print_status "מפעיל את פאנל הניהול..."
    cd mental-coach-admin
    
    # בדיקה אם הפורט תפוס
    if lsof -Pi :9977 -sTCP:LISTEN -t >/dev/null ; then
        print_warning "פורט 9977 כבר תפוס. מנסה לסגור תהליך קיים..."
        kill $(lsof -Pi :9977 -sTCP:LISTEN -t) 2>/dev/null || true
        sleep 2
    fi
    
    # הרצת האדמין ברקע
    npm run dev > ../admin.log 2>&1 &
    ADMIN_PID=$!
    
    print_status "ממתין לפאנל הניהול להיות מוכן..."
    sleep 5
    
    # בדיקה שהאדמין רץ
    if curl -s http://localhost:9977 > /dev/null; then
        print_success "פאנל הניהול רץ בהצלחה על http://localhost:9977 (PID: $ADMIN_PID)"
    else
        print_error "פאנל הניהול לא הצליח לעלות. בדוק את admin.log לפרטים."
        exit 1
    fi
    
    cd ..
}

# הרצת Flutter App
run_flutter_app() {
    print_status "מפעיל את אפליקציית Flutter..."
    cd mental-coach-flutter
    
    # בדיקת סימולטורים זמינים
    print_status "בודק סימולטורים זמינים..."
    flutter emulators
    
    # בדיקה אם יש סימולטור של iPhone 16 פועל
    if ! xcrun simctl list devices | grep -q "iPhone 16.*Booted"; then
        print_status "מפעיל סימולטור iPhone 16..."
        # נסיון להפעיל סימולטור iPhone 16
        open -a Simulator
        sleep 3
        # פתיחת iPhone 16 ספציפית
        xcrun simctl boot "iPhone 16" 2>/dev/null || {
            print_warning "לא הצלחתי להפעיל iPhone 16, מנסה iPhone 16 Pro..."
            xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || {
                print_error "לא נמצא סימולטור iPhone 16. אנא הפעל ידנית."
                print_status "רשימת סימולטורים זמינים:"
                xcrun simctl list devices available
                exit 1
            }
        }
        print_status "ממתין לסימולטור להיות מוכן..."
        sleep 10
    else
        print_success "סימולטור iPhone 16 כבר פועל"
    fi
    
    print_warning "מריץ את האפליקציה על סימולטור iPhone 16"
    print_warning "לחץ Ctrl+C כדי לעצור את כל השירותים"
    
    # הרצת Flutter על סימולטור ספציפי
    flutter run -d "iPhone 16" || flutter run -d "iPhone 16 Pro"
    
    cd ..
}

# פונקציה לעצירת כל השירותים
cleanup() {
    print_status "עוצר את כל השירותים..."
    
    if [ ! -z "$API_PID" ]; then
        kill $API_PID 2>/dev/null || true
        print_success "שרת API נעצר"
    fi
    
    if [ ! -z "$ADMIN_PID" ]; then
        kill $ADMIN_PID 2>/dev/null || true
        print_success "פאנל הניהול נעצר"
    fi
    
    # עצירת תהליכי Node.js נוספים שעלולים להישאר
    pkill -f "node.*mental-coach" 2>/dev/null || true
    
    print_success "כל השירותים נעצרו"
}

# הגדרת trap לניקוי בעת יציאה
trap cleanup EXIT

# תפריט ראשי
show_menu() {
    echo ""
    echo "======================================"
    echo "   Mental Coach - סקריפט הרצה"
    echo "======================================"
    echo "1) התקנה והרצה מלאה"
    echo "2) התקנת תלויות בלבד"
    echo "3) הרצה בלבד (ללא התקנה)"
    echo "4) הרצת API בלבד"
    echo "5) הרצת Admin בלבד"
    echo "6) הרצת Flutter בלבד"
    echo "7) יציאה"
    echo ""
    read -p "בחר אפשרות [1-7]: " choice
}

# פונקציה ראשית
main() {
    clear
    print_status "Mental Coach - סקריפט התקנה והרצה"
    
    # בדיקה שאנחנו בתיקייה הנכונה
    if [ ! -d "mental-coach-api" ] || [ ! -d "mental-coach-admin" ] || [ ! -d "mental-coach-flutter" ]; then
        print_error "הסקריפט חייב לרוץ מתיקיית mental-app-proj שמכילה את כל הפרויקטים"
        exit 1
    fi
    
    show_menu
    
    case $choice in
        1)
            check_dependencies
            install_api_dependencies
            install_admin_dependencies
            install_flutter_dependencies
            run_api_server
            run_admin_panel
            run_flutter_app
            ;;
        2)
            check_dependencies
            install_api_dependencies
            install_admin_dependencies
            install_flutter_dependencies
            print_success "כל התלויות הותקנו בהצלחה!"
            ;;
        3)
            check_dependencies
            run_api_server
            run_admin_panel
            run_flutter_app
            ;;
        4)
            check_dependencies
            run_api_server
            print_warning "לחץ Ctrl+C כדי לעצור"
            wait $API_PID
            ;;
        5)
            check_dependencies
            run_admin_panel
            print_warning "לחץ Ctrl+C כדי לעצור"
            wait $ADMIN_PID
            ;;
        6)
            check_dependencies
            run_flutter_app
            ;;
        7)
            print_status "יוצא..."
            exit 0
            ;;
        *)
            print_error "בחירה לא תקינה"
            exit 1
            ;;
    esac
}

# הרצת הסקריפט
main 