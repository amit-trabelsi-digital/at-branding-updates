# Custom Domain & HTTPS Setup Checklist

## Current Status
- ✅ API Service has domain: `dev-srv.eitanazaria.co.il`
- ⏳ Need to set up production domains

## Steps to Complete

### 1. Railway Dashboard - Add Domains
- [ ] Open Railway dashboard: `railway open`
- [ ] Navigate to Settings → Domains
- [ ] For Web Service (if exists):
  - [ ] Click "Add Domain"
  - [ ] Enter: `app.eitanazaria.co.il`
  - [ ] Copy the CNAME target: ________________________
- [ ] For API Service:
  - [ ] Click "Add Domain" 
  - [ ] Enter: `api.eitanazaria.co.il`
  - [ ] Copy the CNAME target: ________________________

### 2. DNS Configuration
- [ ] Log into your DNS provider (where eitanazaria.co.il is registered)
- [ ] Add CNAME records:
  ```
  app.eitanazaria.co.il → CNAME → [Railway target for web]
  api.eitanazaria.co.il → CNAME → [Railway target for API]
  ```
- [ ] Save DNS changes
- [ ] Wait for DNS propagation (5-30 minutes)

### 3. Verify SSL Certificates
- [ ] Check API: `curl -I https://api.eitanazaria.co.il` (should return 200 or redirect)
- [ ] Check Web: `curl -I https://app.eitanazaria.co.il` (should return 200)
- [ ] Verify certificates in Railway dashboard show as "Active"

### 4. Update Environment Variables
- [ ] Run the update script: `./update-api-url.sh`
- [ ] Or manually:
  ```bash
  railway service  # Select web service
  railway variables set API_URL=https://api.eitanazaria.co.il
  ```

### 5. Redeploy Services
- [ ] Redeploy web service to use new API_URL
- [ ] Test the application with new domains

## Testing Commands

```bash
# Test API endpoint
curl https://api.eitanazaria.co.il/health

# Test web app
curl -I https://app.eitanazaria.co.il

# Check DNS resolution
nslookup api.eitanazaria.co.il
nslookup app.eitanazaria.co.il

# Check SSL certificate
openssl s_client -connect api.eitanazaria.co.il:443 -servername api.eitanazaria.co.il < /dev/null
```

## Notes
- Railway automatically provisions Let's Encrypt SSL certificates
- DNS propagation can take 5-30 minutes
- If you're using Cloudflare, ensure proxy is OFF initially (grey cloud)
- After everything works, you can enable Cloudflare proxy if desired

## Current Environment Variables
- Current API domain: `dev-srv.eitanazaria.co.il`
- Need to update `API_URL` variable after new domain is active
