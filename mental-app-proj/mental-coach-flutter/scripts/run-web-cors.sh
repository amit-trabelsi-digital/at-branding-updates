#!/bin/bash

# Script for running Flutter Web with CORS disabled (for development)
# Usage: ./scripts/run-web-cors.sh [port]

PORT=${1:-5858}

echo "🌐 Starting Flutter Web with CORS disabled"
echo "=========================================="
echo "Port: $PORT"
echo ""

# Kill any existing Flutter processes on the port
lsof -ti:$PORT | xargs kill -9 2>/dev/null

# Run Flutter with CORS disabled
echo "🚀 Starting Flutter Web on http://localhost:$PORT"
echo "⚠️  CORS is disabled for development"
echo ""

flutter run -d chrome \
  --web-port=$PORT \
  --web-browser-flag="--disable-web-security" \
  --web-browser-flag="--disable-gpu" \
  --web-browser-flag="--user-data-dir=/tmp/chrome_dev"

echo ""
echo "✅ Flutter Web stopped"