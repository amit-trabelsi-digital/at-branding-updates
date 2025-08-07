#!/bin/bash

# סקריפט להרצת Flutter עם משתני סביבה
# שימוש: ./scripts/run-env.sh [dev|test|prod|local]

ENV=${1:-dev}
PLATFORM=${2:-}  # אופציונלי: ios, android, web

echo "🚀 Running Flutter app in $ENV environment"

# הגדרת משתני סביבה לפי סביבה
case $ENV in
  "local")
    DART_DEFINES="--dart-define=ENV=local"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=http://localhost:3000/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=false"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=false"
    echo "📍 Using local server"
    ;;
  "dev")
    DART_DEFINES="--dart-define=ENV=dev"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://dev-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=false"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=false"
    echo "🔧 Using development server"
    ;;
  "test")
    DART_DEFINES="--dart-define=ENV=test"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://dev-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=true"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=false"
    echo "🧪 Using test server"
    ;;
  "prod")
    DART_DEFINES="--dart-define=ENV=prod"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://app-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=true"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=true"
    echo "🌟 Using production server"
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    echo "Usage: $0 [dev|test|prod|local] [platform]"
    exit 1
    ;;
esac

# הרצה לפי פלטפורמה
if [ -z "$PLATFORM" ]; then
  echo "📱 Running on default platform..."
  flutter run $DART_DEFINES
else
  case $PLATFORM in
    "ios")
      echo "📱 Running on iOS..."
      flutter run -d iphone $DART_DEFINES
      ;;
    "android")
      echo "🤖 Running on Android..."
      flutter run -d android $DART_DEFINES
      ;;
    "web")
      echo "🌐 Running on Web..."
      if [ "$ENV" == "local" ]; then
        # הרצה עם CORS מבוטל לפיתוח מקומי
        flutter run -d chrome --web-browser-flag "--disable-web-security" $DART_DEFINES
      else
        flutter run -d chrome $DART_DEFINES
      fi
      ;;
    *)
      echo "❌ Unknown platform: $PLATFORM"
      echo "Supported platforms: ios, android, web"
      exit 1
      ;;
  esac
fi 