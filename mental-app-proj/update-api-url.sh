#!/bin/bash

# Script to update API_URL after custom domain is configured

echo "This script will update the API_URL environment variable after your custom domains are configured."
echo ""
echo "IMPORTANT: Only run this after:"
echo "1. You've added the custom domains in Railway dashboard"
echo "2. DNS records have been updated"
echo "3. SSL certificates have been issued (check that https://api.eitanazaria.co.il works)"
echo ""
read -p "Have you completed all the above steps? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating API_URL to use the new custom domain..."
    
    # First, switch to the web service if it exists
    echo "Please select your web service when prompted..."
    railway service
    
    # Update the API_URL variable
    railway variables set API_URL=https://api.eitanazaria.co.il
    
    echo ""
    echo "API_URL has been updated to: https://api.eitanazaria.co.il"
    echo ""
    echo "To redeploy with the new configuration, run:"
    echo "railway up"
    echo ""
    echo "Or trigger a redeploy from the Railway dashboard."
else
    echo "Please complete the domain setup first, then run this script again."
fi
