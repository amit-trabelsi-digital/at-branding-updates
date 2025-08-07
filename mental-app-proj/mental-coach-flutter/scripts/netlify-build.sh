#!/bin/bash

# Build script for Netlify deployment
# This script installs Flutter and builds the web app

echo "🚀 Starting Netlify build for Mental Coach Flutter"
echo "================================================"

# Set Flutter version
FLUTTER_VERSION=${FLUTTER_VERSION:-"3.19.0"}
FLUTTER_CHANNEL=${FLUTTER_CHANNEL:-"stable"}

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter SDK v$FLUTTER_VERSION..."
    
    # Download Flutter
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_CHANNEL --depth 1
    export PATH="$PWD/flutter/bin:$PATH"
    
    # Verify installation
    flutter --version
    flutter doctor -v
else
    echo "✅ Flutter already installed"
    flutter --version
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --web-renderer html

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Build successful!"
    echo "📁 Output directory: build/web"
    ls -la build/web/
else
    echo "❌ Build failed!"
    exit 1
fi

# Create a _redirects file for SPA routing
echo "📝 Creating _redirects file for SPA..."
echo "/*    /index.html   200" > build/web/_redirects

echo "🎉 Netlify build completed successfully!"