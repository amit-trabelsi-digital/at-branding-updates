#!/bin/bash

# Script to test CORS configuration
# Usage: ./scripts/utilities/test-cors.sh [server_url]

SERVER_URL=${1:-"http://localhost:3000"}
ORIGIN=${2:-"http://localhost:5858"}

echo "🧪 Testing CORS Configuration"
echo "================================"
echo "Server: $SERVER_URL"
echo "Origin: $ORIGIN"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Simple GET request
echo "1️⃣ Testing simple GET request..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Origin: $ORIGIN" \
  -H "Accept: application/json" \
  "$SERVER_URL/api/health")

if [ "$RESPONSE" = "200" ]; then
  echo -e "${GREEN}✅ Simple GET request successful${NC}"
else
  echo -e "${RED}❌ Simple GET request failed (HTTP $RESPONSE)${NC}"
fi

# Test 2: Preflight OPTIONS request
echo ""
echo "2️⃣ Testing preflight OPTIONS request..."
PREFLIGHT_RESPONSE=$(curl -s -i -X OPTIONS \
  -H "Origin: $ORIGIN" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization" \
  "$SERVER_URL/api/auth/login" | head -n 20)

if echo "$PREFLIGHT_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
  echo -e "${GREEN}✅ Preflight request returned CORS headers${NC}"
  echo "$PREFLIGHT_RESPONSE" | grep "Access-Control"
else
  echo -e "${RED}❌ Preflight request missing CORS headers${NC}"
fi

# Test 3: Check specific headers
echo ""
echo "3️⃣ Checking CORS headers in response..."
HEADERS=$(curl -s -I \
  -H "Origin: $ORIGIN" \
  "$SERVER_URL/api/health")

echo "$HEADERS" | grep -E "Access-Control|Vary: Origin" | while read -r line; do
  echo -e "${YELLOW}  📋 $line${NC}"
done

# Test 4: Test with credentials
echo ""
echo "4️⃣ Testing request with credentials..."
CRED_RESPONSE=$(curl -s -i \
  -H "Origin: $ORIGIN" \
  -H "Cookie: test=value" \
  "$SERVER_URL/api/health" | head -n 20)

if echo "$CRED_RESPONSE" | grep -q "Access-Control-Allow-Credentials: true"; then
  echo -e "${GREEN}✅ Credentials support enabled${NC}"
else
  echo -e "${YELLOW}⚠️  Credentials support might not be enabled${NC}"
fi

# Test 5: Test different origins
echo ""
echo "5️⃣ Testing different origins..."
ORIGINS=("http://localhost:3000" "http://localhost:5173" "https://app-srv.eitanazaria.co.il" "http://evil.com")

for origin in "${ORIGINS[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Origin: $origin" \
    "$SERVER_URL/api/health")
  
  if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}  ✅ $origin - Allowed${NC}"
  else
    echo -e "${RED}  ❌ $origin - Blocked (HTTP $RESPONSE)${NC}"
  fi
done

echo ""
echo "================================"
echo "🏁 CORS Test Complete"

# Summary
echo ""
echo "📊 Summary:"
echo "- Server URL: $SERVER_URL"
echo "- Test Origin: $ORIGIN"
echo ""
echo "💡 Tips:"
echo "- If all tests pass, CORS is configured correctly"
echo "- If some origins are blocked, check cors.config.ts"
echo "- For production, ensure only trusted origins are allowed"