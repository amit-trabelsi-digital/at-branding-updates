#!/bin/bash

# סקריפט לבניית גרסת production ל-iOS

set -e # יציאה במקרה של שגיאה

# צבעים להדפסות
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️  Mental Coach - בניית גרסת Production ל-iOS${NC}"
echo ""

# קריאת הגרסה הנוכחית
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION_PART=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

echo -e "${YELLOW}גרסה נוכחית: $CURRENT_VERSION${NC}"
echo ""

# שאלה אם להעלות גרסה
read -p "האם להעלות את מספר הגרסה האמצעי (0.9.0 -> 0.10.0)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # העלאת הגרסה האמצעית
    IFS='.' read -ra VERSION_ARRAY <<< "$VERSION_PART"
    MAJOR=${VERSION_ARRAY[0]}
    MINOR=${VERSION_ARRAY[1]}
    PATCH=${VERSION_ARRAY[2]}
    
    NEW_MINOR=$((MINOR + 1))
    NEW_VERSION="${MAJOR}.${NEW_MINOR}.${PATCH}+${BUILD_NUMBER}"
    
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    echo -e "${GREEN}✅ גרסה עודכנה ל-$NEW_VERSION${NC}"
else
    # רק העלאת build number
    NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
    NEW_VERSION="${VERSION_PART}+${NEW_BUILD_NUMBER}"
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    echo -e "${GREEN}✅ Build number עודכן ל-$NEW_VERSION${NC}"
fi

echo ""

# ניקוי
echo -e "${YELLOW}🧹 מנקה build ישן...${NC}"
flutter clean

# עדכון dependencies
echo -e "${YELLOW}📦 מעדכן dependencies...${NC}"
flutter pub get

# עדכון pods
echo -e "${YELLOW}🍎 מעדכן CocoaPods...${NC}"
cd ios
pod install --repo-update
cd ..

# בנייה
echo -e "${BLUE}🔨 בונה את האפליקציה...${NC}"
flutter build ios --release

echo ""
echo -e "${GREEN}✅ הבנייה הושלמה בהצלחה!${NC}"
echo -e "${BLUE}📱 הגרסה מוכנה להעלאה ל-App Store${NC}"
echo ""
echo -e "${YELLOW}השלבים הבאים:${NC}"
echo "1. פתח את Xcode: cd ios && open Runner.xcworkspace"
echo "2. בחר Product > Archive"
echo "3. העלה ל-App Store Connect"