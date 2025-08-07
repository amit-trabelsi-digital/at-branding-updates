#!/bin/bash

# Mental Coach Flutter - עדכון pubspec.yaml
# מקבל version ו-build number ומעדכן את pubspec.yaml

set -e

if [ $# -lt 2 ]; then
    echo "שימוש: $0 <version> <build_number>"
    echo "דוגמה: $0 0.9.1 14"
    exit 1
fi

VERSION="$1"
BUILD_NUMBER="$2"
PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "❌ לא נמצא קובץ $PUBSPEC_FILE"
    exit 1
fi

# עדכון שורת הגרסה בpubspec.yaml
sed -i.bak "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" "$PUBSPEC_FILE"
rm -f "$PUBSPEC_FILE.bak"

echo "✅ pubspec.yaml עודכן ל-$VERSION+$BUILD_NUMBER"