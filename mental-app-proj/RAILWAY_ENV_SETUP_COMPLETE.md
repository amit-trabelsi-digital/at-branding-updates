# ✅ Railway Environment Variables Setup - COMPLETED

## What Was Done

### 1. **Created Runtime Environment Injection System**
- Created `docker-entrypoint.sh` script that injects environment variables at container startup
- Updated `Dockerfile` to use the entrypoint script
- This ensures environment variables from Railway are properly injected into the web app

### 2. **Files Modified/Created**

#### Created Files:
1. **`docker-entrypoint.sh`** - Script to inject environment variables at runtime
2. **`RAILWAY_ENV_VARS_SETUP.md`** - Complete guide for setting up Railway variables
3. **`RAILWAY_ENV_SETUP_COMPLETE.md`** - This summary document

#### Modified Files:
1. **`Dockerfile`** - Updated to use the entrypoint script for runtime injection

### 3. **Environment Variables to Add in Railway Dashboard**

You need to add these variables in the Railway dashboard for the `mental-coach-flutter` service:

#### Required Variables:
```
API_URL=https://mental-coach-api.up.railway.app/api
FLUTTER_ENV=production
```

#### Optional Firebase Variables (if using):
```
FIREBASE_WEB_API_KEY=<your-firebase-api-key>
FIREBASE_WEB_AUTH_DOMAIN=<your-project>.firebaseapp.com
FIREBASE_WEB_PROJECT_ID=<your-project-id>
FIREBASE_WEB_STORAGE_BUCKET=<your-project>.appspot.com
FIREBASE_WEB_MESSAGING_SENDER_ID=<your-sender-id>
FIREBASE_WEB_APP_ID=<your-app-id>
```

#### Optional ReCAPTCHA Variable (if using):
```
RECAPTCHA_SITE_KEY=<your-recaptcha-site-key>
```

## How to Add Variables in Railway

### Option 1: Via Railway Dashboard (Recommended)
1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Navigate to project: **"zesty-happiness"**
3. Click on **mental-coach-flutter** service
4. Click on **"Variables"** tab
5. Add each variable using "New Variable" button
6. Railway will automatically redeploy with new variables

### Option 2: Via Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and link to project
railway login
railway link

# Set variables
railway variables set API_URL=https://mental-coach-api.up.railway.app/api
railway variables set FLUTTER_ENV=production

# Deploy
railway up
```

## How the System Works

1. **Build Time**: Flutter web app is built with placeholder in `env-config.js`
2. **Deploy Time**: Docker image is created with the entrypoint script
3. **Runtime**: When container starts on Railway:
   - `docker-entrypoint.sh` runs first
   - Reads Railway environment variables
   - Writes them to `/app/build/web/env-config.js`
   - Starts the web server
4. **Browser**: When user loads the app:
   - `index.html` loads `env-config.js`
   - JavaScript reads `window.ENV_CONFIG`
   - App connects to the correct API

## Verification Steps

After deployment, verify everything works:

1. **Check Deployment Logs** in Railway for any errors
2. **Visit Your App** at the Railway URL
3. **Open Browser Console** (F12) and type:
   ```javascript
   window.ENV_CONFIG
   ```
   You should see your configured values

4. **Check API Connection** - The app should connect to the API without CORS errors

## Important Notes

⚠️ **API URL**: Based on `RAILWAY_CONFIG.md`, you might need to use:
- `https://app-srv.eitanazaria.co.il` (custom domain)
- Instead of: `https://mental-coach-api.up.railway.app/api`

Verify which URL is correct for your setup.

## Next Steps

1. ✅ **Commit and push these changes**:
   ```bash
   git add docker-entrypoint.sh Dockerfile
   git commit -m "Add runtime environment variable injection for Railway"
   git push
   ```

2. ✅ **Add environment variables in Railway dashboard** (as described above)

3. ✅ **Railway will automatically redeploy** with the new configuration

4. ✅ **Test the deployment** to ensure variables are properly injected

## Troubleshooting

If variables aren't working:

1. **Check Railway logs** for the deployment
2. **Verify `env-config.js`** is being created (check browser DevTools)
3. **Check CORS settings** on your API to allow requests from Railway domain
4. **Ensure Firebase config** matches your actual Firebase project

## Files Reference

- `docker-entrypoint.sh` - Injects variables at runtime
- `Dockerfile` - Uses entrypoint for runtime configuration
- `build/web/index.html` - Already includes `<script src="/env-config.js"></script>`
- `env-config.js` - Created at runtime with actual values
