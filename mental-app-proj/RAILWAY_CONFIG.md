# Railway Project Configuration

## Current Setup Status

You have **TWO separate Railway projects** with the required services:

### 1. Project: "Mental App - Eitan Azaria"
- **Service**: `mental-coach-api` (Backend API)
- **Domain**: `https://app-srv.eitanazaria.co.il`
- **Environment**: production
- **Directory**: `/mental-coach-api`

### 2. Project: "zesty-happiness"
- **Service**: `mental-coach-flutter` (Flutter Web)
- **Domain**: `https://mental-coach-flutter-production.up.railway.app`
- **Environment**: production
- **Directory**: `/mental-coach-flutter`

## Important Configuration Note

⚠️ **The services are currently in DIFFERENT Railway projects**, which may cause deployment and communication issues. 

## Recommended Action

For better organization and easier management, you should consider consolidating both services into ONE Railway project. You can either:

1. **Option A**: Move both services to "Mental App - Eitan Azaria" project
2. **Option B**: Move both services to "zesty-happiness" project
3. **Option C**: Create a new project with both services

## API URL for Environment Variable

For your Flutter web Docker configuration, use:
```
API_URL=https://app-srv.eitanazaria.co.il
```

This is the backend API URL that your Flutter web app will communicate with.

## Next Steps

1. Decide if you want to consolidate the services into one project
2. Update your Flutter web app's environment configuration with the API_URL
3. Ensure CORS is properly configured on the API to accept requests from the Flutter web domain
