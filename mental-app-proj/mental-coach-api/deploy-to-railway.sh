#!/bin/bash

# 🚂 Deploy Mental Coach API to Railway
# ------------------------------------

echo "🚂 Starting Railway Deployment Process..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit for Railway deployment"
else
    echo -e "${GREEN}✅ Git repository already initialized${NC}"
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}📝 You have uncommitted changes. Committing them now...${NC}"
    git add .
    echo "Enter commit message (or press Enter for default):"
    read commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="Update for Railway deployment"
    fi
    git commit -m "$commit_msg"
fi

# Check if remote origin exists
if ! git remote | grep -q "origin"; then
    echo -e "${YELLOW}🔗 No remote origin found.${NC}"
    echo "Please enter your GitHub repository URL:"
    echo "Format: https://github.com/USERNAME/REPO_NAME.git"
    read repo_url
    if [ ! -z "$repo_url" ]; then
        git remote add origin "$repo_url"
        echo -e "${GREEN}✅ Remote origin added${NC}"
    else
        echo -e "${RED}❌ No repository URL provided. Exiting.${NC}"
        exit 1
    fi
fi

# Test build
echo -e "${YELLOW}🔨 Testing build locally...${NC}"
npm run build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed. Please fix errors before deploying.${NC}"
    exit 1
fi

# Push to GitHub
echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
git push -u origin main
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
else
    echo -e "${YELLOW}⚠️  Push failed. Trying with 'master' branch...${NC}"
    git branch -M master
    git push -u origin master
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully pushed to GitHub (master branch)!${NC}"
    else
        echo -e "${RED}❌ Failed to push to GitHub. Please check your credentials.${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}🎉 Code is ready for Railway deployment!${NC}"
echo ""
echo "📋 Next steps:"
echo "1. Go to https://railway.app"
echo "2. Click 'New Project'"
echo "3. Select 'Deploy from GitHub repo'"
echo "4. Choose your repository"
echo "5. Add environment variables (see RAILWAY_DEPLOYMENT.md)"
echo ""
echo "🔑 Required environment variables:"
echo "   - DATABASE (MongoDB connection string)"
echo "   - FIREBASE_SERVICE_ACCOUNT"
echo "   - SENDGRID_API_KEY"
echo "   - TWILIO_ACCOUNT_SID"
echo "   - TWILIO_AUTH_TOKEN"
echo "   - TWILIO_PHONE_NUMBER"
echo ""
echo -e "${GREEN}Good luck! 🚀${NC}"