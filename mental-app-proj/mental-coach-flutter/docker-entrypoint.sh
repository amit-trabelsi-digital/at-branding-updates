#!/bin/sh

# Mental Coach Flutter - Docker Entrypoint
# ========================================

echo "🚀 Starting Flutter Web Application"
echo "Environment: ${FLUTTER_ENV:-docker}"
echo "API URL: ${API_URL:-not set}"

# יצירת קובץ קונפיגורציה דינמי
if [ -f /usr/share/nginx/html/config.js.template ]; then
    envsubst < /usr/share/nginx/html/config.js.template > /usr/share/nginx/html/config.js
    echo "✅ Configuration file created"
fi

# עדכון index.html עם משתני סביבה (אם נדרש)
if [ -f /usr/share/nginx/html/index.html ]; then
    # הוספת סקריפט קונפיגורציה ל-index.html אם לא קיים
    if ! grep -q "config.js" /usr/share/nginx/html/index.html; then
        sed -i 's|</head>|<script src="/config.js"></script>\n</head>|' /usr/share/nginx/html/index.html
        echo "✅ Configuration script added to index.html"
    fi
fi

# בדיקת קיום assets
if [ -d /usr/share/nginx/html/assets ]; then
    echo "✅ Assets directory found"
    ls -la /usr/share/nginx/html/assets | head -5
fi

if [ -d /usr/share/nginx/html/images ]; then
    echo "✅ Images directory found"
    ls -la /usr/share/nginx/html/images | head -5
fi

# הפעלת nginx
echo "🌐 Starting Nginx server on port 80..."
nginx -g "daemon off;"