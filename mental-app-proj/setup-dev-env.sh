#!/bin/bash
# Setup script for DEV environment v1.1.0

echo "Setting up DEV environment configuration for v1.1.0..."

# Copy dev environment files to their respective locations
# Note: These files need to be manually copied to submodules if they are separate repos

# Create dev environment markers
echo "dev-v1.1.0" > .env-version

# Environment variables for the main project
cat > .env.dev << 'EOF'
# Mental Coach App - DEV Environment v1.1.0
APP_ENV=development
APP_VERSION=1.1.0-dev
DEPLOYMENT_TARGET=dev

# API Configuration
API_URL=http://localhost:3000
API_TIMEOUT=30000

# Feature Flags
ENABLE_DEBUG=true
ENABLE_MOCK_DATA=false
ENABLE_ERROR_REPORTING=true
ENABLE_HOT_RELOAD=true
ENABLE_DEV_TOOLS=true
EOF

echo "Dev environment files created."
echo ""
echo "IMPORTANT: If submodules are separate repositories, please:"
echo "1. Copy mental-coach-api/.env.dev to the API submodule"
echo "2. Copy mental-coach-admin/.env.dev to the Admin submodule"
echo "3. Copy mental-coach-flutter/lib/firebase_options_dev.dart to the Flutter submodule"
echo ""
echo "Then commit changes in each submodule separately."
