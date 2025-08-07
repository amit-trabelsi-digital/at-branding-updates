#!/bin/bash

# סקריפט לזיהוי כתובת IP מקומית

echo "🔍 מזהה כתובת IP מקומית..."
echo ""

# macOS - מציאת IP של Wi-Fi או Ethernet
if [[ "$OSTYPE" == "darwin"* ]]; then
    # נסיון למצוא IP של Wi-Fi
    WIFI_IP=$(ipconfig getifaddr en0 2>/dev/null)
    if [ ! -z "$WIFI_IP" ]; then
        echo "📶 Wi-Fi IP: $WIFI_IP"
    fi
    
    # נסיון למצוא IP של Ethernet
    ETH_IP=$(ipconfig getifaddr en1 2>/dev/null)
    if [ ! -z "$ETH_IP" ]; then
        echo "🔌 Ethernet IP: $ETH_IP"
    fi
    
    # כתובות נוספות
    echo ""
    echo "כתובות IP נוספות:"
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print "  • " $2}'
fi

echo ""
echo "💡 טיפים לחיבור מסימולטור/מכשיר:"
echo "  • מסימולטור iOS: השתמש ב-127.0.0.1 או בכתובת IP המקומית"
echo "  • ממכשיר פיזי: השתמש בכתובת IP המקומית (לא localhost)"
echo "  • וודא שהמכשיר והמחשב באותה רשת"
echo ""
echo "📝 לעדכון בקובץ environment_config.dart:"
echo "  שנה את: http://localhost:3000/api"
echo "  ל: http://YOUR_IP:3000/api" 