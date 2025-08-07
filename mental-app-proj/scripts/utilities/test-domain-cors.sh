#!/bin/bash

# Script to test CORS with various eitanazaria.co.il subdomains
# Usage: ./scripts/utilities/test-domain-cors.sh [server_url]

SERVER_URL=${1:-"http://localhost:3000"}

echo "🧪 Testing CORS for eitanazaria.co.il Subdomains"
echo "================================================"
echo "Server: $SERVER_URL"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test domains
DOMAINS=(
  # Main domain and subdomains
  "https://eitanazaria.co.il"
  "https://www.eitanazaria.co.il"
  "https://app.eitanazaria.co.il"
  "https://admin.eitanazaria.co.il"
  "https://api.eitanazaria.co.il"
  "https://mental.eitanazaria.co.il"
  "https://mntl.eitanazaria.co.il"
  
  # Multi-level subdomains
  "https://admin.mental.eitanazaria.co.il"
  "https://api.mental.eitanazaria.co.il"
  "https://dev.api.mntl.eitanazaria.co.il"
  
  # New potential subdomains
  "https://new-feature.eitanazaria.co.il"
  "https://test123.eitanazaria.co.il"
  "https://super.deep.subdomain.eitanazaria.co.il"
  
  # Local development
  "http://localhost:3000"
  "http://localhost:5173"
  "http://127.0.0.1:3000"
  
  # Should be blocked
  "https://evil.com"
  "https://fake-eitanazaria.co.il.evil.com"
  "https://eitanazaria.co.il.fake.com"
)

echo -e "${BLUE}Testing domains against $SERVER_URL/api/health${NC}"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

for domain in "${DOMAINS[@]}"; do
  # Make OPTIONS preflight request
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X OPTIONS \
    -H "Origin: $domain" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: Content-Type" \
    "$SERVER_URL/api/health" 2>/dev/null)
  
  # Check if domain should be allowed
  SHOULD_ALLOW=false
  
  # Check if it's under eitanazaria.co.il
  if [[ "$domain" == *"eitanazaria.co.il"* ]] && [[ "$domain" != *"fake"* ]]; then
    SHOULD_ALLOW=true
  fi
  
  # Check if it's localhost
  if [[ "$domain" == *"localhost"* ]] || [[ "$domain" == *"127.0.0.1"* ]]; then
    SHOULD_ALLOW=true
  fi
  
  # Display result
  if [ "$RESPONSE" = "204" ] || [ "$RESPONSE" = "200" ]; then
    if [ "$SHOULD_ALLOW" = true ]; then
      echo -e "${GREEN}✅ PASS${NC} - $domain (Expected: Allow, Got: Allow)"
      ((SUCCESS_COUNT++))
    else
      echo -e "${RED}❌ FAIL${NC} - $domain (Expected: Block, Got: Allow)"
      ((FAIL_COUNT++))
    fi
  else
    if [ "$SHOULD_ALLOW" = false ]; then
      echo -e "${GREEN}✅ PASS${NC} - $domain (Expected: Block, Got: Block)"
      ((SUCCESS_COUNT++))
    else
      echo -e "${RED}❌ FAIL${NC} - $domain (Expected: Allow, Got: Block - HTTP $RESPONSE)"
      ((FAIL_COUNT++))
    fi
  fi
done

echo ""
echo "================================================"
echo -e "${BLUE}📊 Test Results:${NC}"
echo -e "${GREEN}✅ Passed: $SUCCESS_COUNT${NC}"
echo -e "${RED}❌ Failed: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed! CORS is configured correctly.${NC}"
else
  echo -e "${YELLOW}⚠️  Some tests failed. Please check the CORS configuration.${NC}"
fi

echo ""
echo -e "${BLUE}💡 Configuration Details:${NC}"
echo "• All *.eitanazaria.co.il subdomains are automatically allowed"
echo "• Multi-level subdomains (e.g., api.mental.eitanazaria.co.il) are supported"
echo "• New subdomains will work automatically without code changes"
echo "• Localhost and 127.0.0.1 are allowed in development mode"