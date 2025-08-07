#!/bin/bash

# סקריפט לבניית Flutter עם משתני סביבה
# שימוש: ./scripts/build-env.sh [dev|test|prod] [platform] [output-dir]

ENV=${1:-prod}
PLATFORM=${2:-apk}  # apk, appbundle, ios, web
OUTPUT_DIR=${3:-build/output}

echo "🏗️  Building Flutter app for $ENV environment ($PLATFORM)"

# הגדרת משתני סביבה לפי סביבה
case $ENV in
  "dev")
    DART_DEFINES="--dart-define=ENV=dev"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://dev-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=false"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=false"
    echo "🔧 Building with development configuration"
    ;;
  "test")
    DART_DEFINES="--dart-define=ENV=test"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://dev-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=true"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=false"
    echo "🧪 Building with test configuration"
    ;;
  "prod")
    DART_DEFINES="--dart-define=ENV=prod"
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=https://app-srv.eitanazaria.co.il/api"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=true"
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=true"
    echo "🌟 Building with production configuration"
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    echo "Usage: $0 [dev|test|prod] [platform] [output-dir]"
    exit 1
    ;;
esac

# יצירת תיקיית output
mkdir -p $OUTPUT_DIR

# בנייה לפי פלטפורמה
case $PLATFORM in
  "apk")
    echo "🤖 Building APK..."
    flutter build apk --release $DART_DEFINES
    cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_DIR/mental-coach-$ENV.apk"
    echo "✅ APK saved to: $OUTPUT_DIR/mental-coach-$ENV.apk"
    ;;
  "appbundle")
    echo "🤖 Building App Bundle..."
    flutter build appbundle --release $DART_DEFINES
    cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/mental-coach-$ENV.aab"
    echo "✅ App Bundle saved to: $OUTPUT_DIR/mental-coach-$ENV.aab"
    ;;
  "ios")
    echo "📱 Building iOS..."
    flutter build ios --release $DART_DEFINES
    echo "✅ iOS build complete. Archive using Xcode."
    ;;
  "ipa")
    echo "📱 Building IPA..."
    flutter build ipa --release $DART_DEFINES
    cp build/ios/ipa/*.ipa "$OUTPUT_DIR/mental-coach-$ENV.ipa"
    echo "✅ IPA saved to: $OUTPUT_DIR/mental-coach-$ENV.ipa"
    ;;
  "web")
    echo "🌐 Building Web..."
    flutter build web --release $DART_DEFINES
    cp -r build/web/* "$OUTPUT_DIR/"
    echo "✅ Web build saved to: $OUTPUT_DIR/"
    ;;
  *)
    echo "❌ Unknown platform: $PLATFORM"
    echo "Supported platforms: apk, appbundle, ios, ipa, web"
    exit 1
    ;;
esac

echo "🎉 Build complete!"
echo "Environment: $ENV"
echo "Platform: $PLATFORM"
echo "Output: $OUTPUT_DIR" 