# External API Setup Guide / מדריך הגדרת API חיצוני

## Environment Variables Setup / הגדרת משתני סביבה

Add the following to your `.env` file:

```bash
# External API Keys
# Comma-separated list of API keys for external services
# Generate secure keys using: openssl rand -hex 32
EXTERNAL_API_KEYS=mc_development_key_123456789abcdef,mc_production_key_fedcba987654321
```

### Generate Secure API Keys / יצירת מפתחות API מאובטחים

#### Linux/Mac:
```bash
openssl rand -hex 32
```

#### Node.js:
```javascript
const crypto = require('crypto');
const apiKey = 'mc_' + crypto.randomBytes(32).toString('hex');
console.log(apiKey);
```

#### Online Generator:
Use a secure password generator and prefix with `mc_`

### Example Configuration / דוגמת הגדרה

#### Development:
```bash
EXTERNAL_API_KEYS=mc_dev_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd
```

#### Production (multiple services):
```bash
EXTERNAL_API_KEYS=mc_partner1_key_xxxxx,mc_partner2_key_yyyyy,mc_partner3_key_zzzzz
```

## Security Best Practices / עקרונות אבטחה

### English:
1. **Never commit API keys to version control**
2. **Use different keys for each environment** (dev, staging, production)
3. **Rotate keys regularly** (every 90 days recommended)
4. **Monitor API usage** for unusual patterns
5. **Use HTTPS only** in production
6. **Store keys securely** (use environment variables or secret management services)
7. **Implement IP whitelisting** for additional security (optional)
8. **Log all API access** for audit purposes

### עברית:
1. **לעולם אל תעלו מפתחות API ל-Git**
2. **השתמשו במפתחות שונים לכל סביבה** (פיתוח, בדיקות, ייצור)
3. **החליפו מפתחות באופן קבוע** (מומלץ כל 90 יום)
4. **נטרו את השימוש ב-API** לזיהוי חריגות
5. **השתמשו ב-HTTPS בלבד** בסביבת ייצור
6. **אחסנו מפתחות באופן מאובטח** (משתני סביבה או שירותי ניהול סודות)
7. **הטמיעו רשימת IP מורשים** לאבטחה נוספת (אופציונלי)
8. **תעדו כל גישה ל-API** למטרות ביקורת

## Testing the API / בדיקת ה-API

### 1. Health Check / בדיקת תקינות
```bash
curl -X GET http://localhost:3000/api/external/health \
  -H "X-API-Key: mc_dev_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd"
```

### 2. Create Test User / יצירת משתמש בדיקה
```bash
curl -X POST http://localhost:3000/api/external/users \
  -H "X-API-Key: mc_dev_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "phone": "0501234567",
    "externalId": "TEST123"
  }'
```

## Monitoring / ניטור

### Recommended Monitoring Setup:
1. **API Key Usage**: Track requests per key
2. **Error Rates**: Monitor 4xx and 5xx errors
3. **Response Times**: Track API latency
4. **Rate Limit Hits**: Monitor when limits are reached
5. **Geographic Distribution**: Track request origins

### Log Format:
```
[timestamp] [API_KEY_PREFIX] [METHOD] [ENDPOINT] [STATUS] [RESPONSE_TIME] [CLIENT_ID]
```

Example:
```
2024-01-27T10:00:00Z mc_dev_123... POST /api/external/users 201 150ms partner-app
```

## Troubleshooting / פתרון בעיות

### Common Issues / בעיות נפוצות:

#### 401 Unauthorized
- Check API key is correct
- Verify key is in EXTERNAL_API_KEYS environment variable
- Ensure header name is correct: `X-API-Key`

#### 429 Too Many Requests
- Rate limit exceeded (100 requests/minute)
- Wait for reset time in `X-RateLimit-Reset` header
- Consider implementing request queuing

#### 500 Internal Server Error
- Check server logs for details
- Verify MongoDB connection
- Check Firebase configuration

## API Key Management Script / סקריפט לניהול מפתחות

Create `scripts/manage-api-keys.js`:

```javascript
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Generate new API key
function generateApiKey(clientName) {
  const key = 'mc_' + clientName + '_' + crypto.randomBytes(24).toString('hex');
  return key;
}

// Add key to environment
function addApiKey(key) {
  const envPath = path.join(__dirname, '../.env');
  const envContent = fs.readFileSync(envPath, 'utf8');
  
  const lines = envContent.split('\n');
  const keyLineIndex = lines.findIndex(line => line.startsWith('EXTERNAL_API_KEYS='));
  
  if (keyLineIndex >= 0) {
    const currentKeys = lines[keyLineIndex].split('=')[1];
    lines[keyLineIndex] = `EXTERNAL_API_KEYS=${currentKeys},${key}`;
  } else {
    lines.push(`EXTERNAL_API_KEYS=${key}`);
  }
  
  fs.writeFileSync(envPath, lines.join('\n'));
  console.log('API Key added successfully');
}

// Usage
const clientName = process.argv[2];
if (!clientName) {
  console.error('Usage: node manage-api-keys.js <client-name>');
  process.exit(1);
}

const newKey = generateApiKey(clientName);
console.log('Generated API Key:', newKey);
console.log('Add this to your .env file under EXTERNAL_API_KEYS');
```

## Contact / יצירת קשר

For API access or technical support / לקבלת גישה ל-API או תמיכה טכנית:
- Email: api-support@mentalcoach.app
- Documentation: https://api.mentalcoach.app/docs

---

**Version**: 1.0.0  
**Last Updated**: 27.01.2025