#!/bin/bash
# Setup script for TEST environment v1.1.0

echo "Setting up TEST environment configuration for v1.1.0..."

# Copy test environment files to their respective locations
# Note: These files need to be manually copied to submodules if they are separate repos

# Create test environment markers
echo "test-v1.1.0" > .env-version

# Environment variables for the main project
cat > .env.test << 'EOF'
# Mental Coach App - TEST Environment v1.1.0
APP_ENV=test
APP_VERSION=1.1.0-test
DEPLOYMENT_TARGET=test

# API Configuration
API_URL=http://localhost:3001
API_TIMEOUT=30000

# Feature Flags
ENABLE_DEBUG=true
ENABLE_MOCK_DATA=false
ENABLE_ERROR_REPORTING=true
EOF

echo "Test environment files created."
echo ""
echo "IMPORTANT: If submodules are separate repositories, please:"
echo "1. Copy mental-coach-api/.env.test to the API submodule"
echo "2. Copy mental-coach-admin/.env.test to the Admin submodule"
echo "3. Copy mental-coach-flutter/lib/firebase_options_test.dart to the Flutter submodule"
echo ""
echo "Then commit changes in each submodule separately."
