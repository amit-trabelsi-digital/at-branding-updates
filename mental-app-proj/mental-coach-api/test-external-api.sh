#!/bin/bash

# Test script for External API
# סקריפט בדיקה ל-API החיצוני

echo "========================================"
echo "🧪 Mental Coach External API Test"
echo "========================================"
echo ""

# Set variables
API_KEY="test-key-development-only"
BASE_URL="http://localhost:3000/api/external"
TEST_EMAIL="test_$(date +%s)@example.com"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📍 Testing with:"
echo "   URL: $BASE_URL"
echo "   API Key: ${API_KEY:0:20}..."
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/health" \
  -H "X-API-Key: $API_KEY")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n 1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Health check passed!${NC}"
  echo "   Response: $BODY"
else
  echo -e "${RED}❌ Health check failed! HTTP Code: $HTTP_CODE${NC}"
  echo "   Response: $BODY"
fi
echo ""

# Test 2: Check User Exists (should not exist)
echo "2️⃣  Checking if test user exists..."
EXISTS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/users/exists?email=$TEST_EMAIL" \
  -H "X-API-Key: $API_KEY")
HTTP_CODE=$(echo "$EXISTS_RESPONSE" | tail -n 1)
BODY=$(echo "$EXISTS_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Check exists endpoint works!${NC}"
  echo "   Response: $BODY"
else
  echo -e "${RED}❌ Check exists failed! HTTP Code: $HTTP_CODE${NC}"
fi
echo ""

# Test 3: Create User
echo "3️⃣  Creating new user..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "'$TEST_EMAIL'",
    "phone": "0501234567",
    "age": 25,
    "position": "RB",
    "strongLeg": "right",
    "subscriptionType": "premium",
    "externalId": "TEST_'$(date +%s)'",
    "externalSource": "API_Test_Script"
  }')
HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n 1)
BODY=$(echo "$CREATE_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "201" ]; then
  echo -e "${GREEN}✅ User created successfully!${NC}"
  echo "   Response: $BODY" | python3 -m json.tool 2>/dev/null || echo "   Response: $BODY"
  
  # Extract user ID
  USER_ID=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['user']['_id'])" 2>/dev/null)
  if [ ! -z "$USER_ID" ]; then
    echo -e "${YELLOW}   User ID: $USER_ID${NC}"
  fi
else
  echo -e "${RED}❌ User creation failed! HTTP Code: $HTTP_CODE${NC}"
  echo "   Response: $BODY"
fi
echo ""

# Test 4: Try to create duplicate (should fail)
echo "4️⃣  Testing duplicate prevention..."
DUP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Duplicate",
    "lastName": "Test",
    "email": "'$TEST_EMAIL'"
  }')
HTTP_CODE=$(echo "$DUP_RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" = "409" ]; then
  echo -e "${GREEN}✅ Duplicate prevention works!${NC}"
else
  echo -e "${RED}❌ Duplicate prevention failed! HTTP Code: $HTTP_CODE${NC}"
fi
echo ""

# Test 5: Invalid API Key
echo "5️⃣  Testing invalid API key..."
INVALID_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/health" \
  -H "X-API-Key: invalid_key_123")
HTTP_CODE=$(echo "$INVALID_RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" = "401" ]; then
  echo -e "${GREEN}✅ API key validation works!${NC}"
else
  echo -e "${RED}❌ API key validation failed! HTTP Code: $HTTP_CODE${NC}"
fi
echo ""

# Test 6: Missing API Key
echo "6️⃣  Testing missing API key..."
MISSING_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/health")
HTTP_CODE=$(echo "$MISSING_RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" = "401" ]; then
  echo -e "${GREEN}✅ Missing API key handled correctly!${NC}"
else
  echo -e "${RED}❌ Missing API key not handled! HTTP Code: $HTTP_CODE${NC}"
fi

echo ""
echo "========================================"
echo "📊 Test Summary:"
echo "   • Health Check"
echo "   • User Existence Check"
echo "   • User Creation"
echo "   • Duplicate Prevention"
echo "   • API Key Validation"
echo "   • Missing API Key Handling"
echo "========================================"
echo ""
echo "📝 Created test user with email: $TEST_EMAIL"