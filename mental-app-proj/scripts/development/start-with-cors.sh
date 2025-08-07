#!/bin/bash

# Script to start the entire Mental Coach system with CORS support
# Usage: ./scripts/development/start-with-cors.sh [environment]

ENVIRONMENT=${1:-local}

echo "🚀 Starting Mental Coach System with CORS Support"
echo "=================================================="
echo "Environment: $ENVIRONMENT"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check if port is in use
check_port() {
  lsof -i:$1 > /dev/null 2>&1
  return $?
}

# Kill processes on ports if needed
echo -e "${YELLOW}🔍 Checking for running services...${NC}"

if check_port 3000; then
  echo "Port 3000 is in use, killing process..."
  lsof -ti:3000 | xargs kill -9 2>/dev/null
fi

if check_port 9977; then
  echo "Port 9977 is in use, killing process..."
  lsof -ti:9977 | xargs kill -9 2>/dev/null
fi

# Start API Server
echo ""
echo -e "${BLUE}1️⃣ Starting API Server...${NC}"
cd mental-coach-api

# Set environment variables
export NODE_ENV=development
export ALLOW_LOCAL_CORS=true

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing API dependencies..."
  npm install
fi

# Start the server in background
npm run dev &
API_PID=$!
echo -e "${GREEN}✅ API Server started (PID: $API_PID) on port 3000${NC}"

# Wait for API to be ready
echo "Waiting for API to be ready..."
sleep 5

# Test API health
curl -s http://localhost:3000/api/health > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ API is healthy${NC}"
else
  echo -e "${YELLOW}⚠️  API might not be ready yet${NC}"
fi

cd ..

# Start Admin Panel
echo ""
echo -e "${BLUE}2️⃣ Starting Admin Panel...${NC}"
cd mental-coach-admin

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing Admin dependencies..."
  npm install
fi

# Start admin panel in background
npm run dev -- --port 9977 &
ADMIN_PID=$!
echo -e "${GREEN}✅ Admin Panel started (PID: $ADMIN_PID) on port 9977${NC}"

cd ..

# Start Flutter App
echo ""
echo -e "${BLUE}3️⃣ Starting Flutter App...${NC}"
cd mental-coach-flutter

# Check Flutter dependencies
flutter pub get

# Run Flutter with CORS disabled for Chrome
echo ""
echo -e "${GREEN}Starting Flutter in Chrome with CORS disabled...${NC}"

case $ENVIRONMENT in
  "local")
    ./scripts/run-with-cors.sh local chrome
    ;;
  "dev")
    ./scripts/run-with-cors.sh dev chrome
    ;;
  "prod")
    ./scripts/run-with-cors.sh prod chrome
    ;;
  *)
    ./scripts/run-with-cors.sh local chrome
    ;;
esac

# Cleanup function
cleanup() {
  echo ""
  echo -e "${YELLOW}🛑 Stopping all services...${NC}"
  
  if [ ! -z "$API_PID" ]; then
    kill $API_PID 2>/dev/null
    echo "Stopped API Server"
  fi
  
  if [ ! -z "$ADMIN_PID" ]; then
    kill $ADMIN_PID 2>/dev/null
    echo "Stopped Admin Panel"
  fi
  
  # Kill any remaining processes on the ports
  lsof -ti:3000 | xargs kill -9 2>/dev/null
  lsof -ti:9977 | xargs kill -9 2>/dev/null
  
  echo -e "${GREEN}✅ All services stopped${NC}"
  exit 0
}

# Set up trap to cleanup on exit
trap cleanup EXIT INT TERM

# Keep script running
wait