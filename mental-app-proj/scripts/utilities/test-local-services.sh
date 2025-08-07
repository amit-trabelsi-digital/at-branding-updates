#!/bin/bash

# Test Local Services Independently
# ==================================

echo "🧪 Mental Coach - Local Service Testing"
echo "======================================="
echo ""
echo "בחר שירות לבדיקה מקומית:"
echo "1) API Service (port 3000)"
echo "2) Admin Panel (port 9977)"
echo "3) Flutter Web (port 8080)"
echo "4) הכל במקביל (3 terminals)"
echo "5) יציאה"

read -p "בחירה [1-5]: " choice

case $choice in
    1)
        echo "🚀 מריץ API Service..."
        cd mental-coach-api
        echo "בונה Docker image..."
        docker build -t mental-coach-api .
        echo "מריץ container..."
        docker run -p 3000:3000 \
          --env-file ../.env.local \
          --name mental-coach-api-local \
          --rm \
          mental-coach-api
        ;;
        
    2)
        echo "🚀 מריץ Admin Panel..."
        cd mental-coach-admin
        echo "בונה Docker image..."
        docker build \
          --build-arg VITE_API_URL=http://localhost:3000/api \
          --build-arg VITE_ENV=development \
          -t mental-coach-admin .
        echo "מריץ container..."
        docker run -p 9977:80 \
          --name mental-coach-admin-local \
          --rm \
          mental-coach-admin
        ;;
        
    3)
        echo "🚀 מריץ Flutter Web..."
        cd mental-coach-flutter
        echo "בונה Docker image..."
        docker build \
          --build-arg API_URL=http://localhost:3000/api \
          --build-arg FLUTTER_ENV=local \
          -f Dockerfile.railway \
          -t mental-coach-flutter .
        echo "מריץ container..."
        docker run -p 8080:80 \
          --name mental-coach-flutter-local \
          --rm \
          mental-coach-flutter
        ;;
        
    4)
        echo "🚀 מריץ את כל השירותים..."
        
        # API in background
        echo "Starting API..."
        cd mental-coach-api
        docker build -t mental-coach-api . &
        API_PID=$!
        
        # Admin in background
        echo "Starting Admin..."
        cd ../mental-coach-admin
        docker build \
          --build-arg VITE_API_URL=http://localhost:3000/api \
          -t mental-coach-admin . &
        ADMIN_PID=$!
        
        # Flutter in background
        echo "Starting Flutter..."
        cd ../mental-coach-flutter
        docker build \
          --build-arg API_URL=http://localhost:3000/api \
          -f Dockerfile.railway \
          -t mental-coach-flutter . &
        FLUTTER_PID=$!
        
        # Wait for builds
        wait $API_PID $ADMIN_PID $FLUTTER_PID
        
        echo "Starting containers..."
        docker run -d -p 3000:3000 --name api-local mental-coach-api
        docker run -d -p 9977:80 --name admin-local mental-coach-admin
        docker run -d -p 8080:80 --name flutter-local mental-coach-flutter
        
        echo ""
        echo "✅ Services running:"
        echo "   API: http://localhost:3000"
        echo "   Admin: http://localhost:9977"
        echo "   Flutter: http://localhost:8080"
        echo ""
        echo "To stop: docker stop api-local admin-local flutter-local"
        echo "To remove: docker rm api-local admin-local flutter-local"
        ;;
        
    5)
        echo "👋 להתראות!"
        exit 0
        ;;
        
    *)
        echo "❌ בחירה לא חוקית"
        exit 1
        ;;
esac