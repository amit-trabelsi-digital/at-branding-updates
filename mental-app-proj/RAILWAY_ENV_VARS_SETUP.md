# Railway Environment Variables Setup for mental-coach-web

## Step-by-Step Guide to Add Environment Variables in Railway

### 1. Access Railway Dashboard
1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Navigate to your project: **"zesty-happiness"**
3. Click on the **mental-coach-flutter** service (this is your web service)

### 2. Navigate to Variables Tab
1. Once in the service, click on the **"Variables"** tab
2. You'll see the environment variables configuration panel

### 3. Add Required Environment Variables

Add the following environment variables by clicking "New Variable" for each:

#### Core Variables (Required)
| Variable Name | Value | Description |
|--------------|-------|-------------|
| `API_URL` | `https://mental-coach-api.up.railway.app/api` | Backend API endpoint |
| `FLUTTER_ENV` | `production` | Flutter environment setting |

#### Firebase Configuration (Add if using Firebase)
| Variable Name | Value | Description |
|--------------|-------|-------------|
| `FIREBASE_WEB_API_KEY` | Your Firebase API key | Firebase Web API Key |
| `FIREBASE_WEB_AUTH_DOMAIN` | Your project.firebaseapp.com | Firebase Auth Domain |
| `FIREBASE_WEB_PROJECT_ID` | Your project ID | Firebase Project ID |
| `FIREBASE_WEB_STORAGE_BUCKET` | Your project.appspot.com | Firebase Storage Bucket |
| `FIREBASE_WEB_MESSAGING_SENDER_ID` | Your sender ID | Firebase Messaging Sender ID |
| `FIREBASE_WEB_APP_ID` | Your app ID | Firebase App ID |

#### ReCAPTCHA Configuration (Add if using)
| Variable Name | Value | Description |
|--------------|-------|-------------|
| `RECAPTCHA_SITE_KEY` | Your ReCAPTCHA site key | ReCAPTCHA site key for web |

### 4. How These Variables Are Used

The environment variables are injected at build time through the `env-config.js` file:

1. During deployment, Railway runs the Docker build process
2. The Dockerfile uses these environment variables
3. They are injected into `build/web/env-config.js`
4. The Flutter web app reads them from `window.ENV_CONFIG`

### 5. Verify Configuration

After adding the variables:
1. Click **"Deploy"** to trigger a new deployment
2. Wait for the deployment to complete
3. Check the deployment logs for any errors
4. Visit your deployed app to verify it's connecting to the API correctly

### 6. Testing the Configuration

You can verify the variables are working by:
1. Opening your deployed app in a browser
2. Opening Developer Tools (F12)
3. In the Console, type: `window.ENV_CONFIG`
4. You should see your configured values

## Important Notes

- ⚠️ **API URL Update**: Based on the RAILWAY_CONFIG.md, your actual API URL might be `https://app-srv.eitanazaria.co.il` instead of `https://mental-coach-api.up.railway.app/api`. Verify which one is correct for your setup.

- 🔒 **Security**: Never commit sensitive keys to your repository. Always use environment variables for API keys and secrets.

- 🔄 **Updates**: When you change environment variables, Railway will automatically trigger a new deployment.

## Alternative: Using Railway CLI

If you prefer using the CLI:

```bash
# Install Railway CLI if not already installed
npm install -g @railway/cli

# Login to Railway
railway login

# Link to your project
railway link

# Set environment variables
railway variables set API_URL=https://mental-coach-api.up.railway.app/api
railway variables set FLUTTER_ENV=production
# Add other variables as needed...

# Deploy
railway up
```

## Troubleshooting

If the variables aren't being injected properly:

1. Check the Dockerfile to ensure it's using the environment variables correctly
2. Verify the `env-config.js` file is being created during build
3. Check that `index.html` includes the script tag for `env-config.js`
4. Review deployment logs in Railway for any errors

## Next Steps

After setting up the environment variables:
1. Monitor the deployment in Railway
2. Test the web app to ensure it connects to the API
3. Configure CORS on the API if needed to accept requests from the web domain
