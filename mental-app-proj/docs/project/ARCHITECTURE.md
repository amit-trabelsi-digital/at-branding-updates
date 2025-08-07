# 🏗️ Mental Coach - ארכיטקטורת מיקרו-שירותים

## 📐 סקירת הארכיטקטורה

Mental Coach בנוי כארכיטקטורת מיקרו-שירותים עם 3 שירותים עצמאיים:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Flutter Web    │────▶│   API Server    │◀────│  Admin Panel    │
│   (Frontend)    │     │   (Backend)     │     │  (Management)   │
│                 │     │                 │     │                 │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                        │
         │                       ▼                        │
         │              ┌─────────────────┐               │
         │              │                 │               │
         │              │  MongoDB Atlas  │               │
         │              │   (Database)    │               │
         │              │                 │               │
         │              └─────────────────┘               │
         │                                                │
         │              ┌─────────────────┐               │
         └─────────────▶│                 │◀──────────────┘
                        │ Firebase Auth   │
                        │  (Auth Service) │
                        │                 │
                        └─────────────────┘
```

## 🎯 עקרונות מנחים

1. **עצמאות מלאה** - כל שירות יכול לרוץ באופן עצמאי
2. **Repository נפרד** - כל שירות ב-Git repository נפרד
3. **CI/CD עצמאי** - כל שירות עם pipeline משלו
4. **תקשורת דרך API** - שירותים מתקשרים דרך REST API
5. **משתני סביבה** - קונפיגורציה דרך environment variables
6. **הפרדת גישות** - רק ה-API ניגש ל-Database, כל השאר דרך API

## 🔄 זרימת נתונים

### קריאת נתונים:
```
Flutter/Admin → GET /api/users → API Server → MongoDB → Response
```

### כתיבת נתונים:
```
Flutter/Admin → POST /api/users → API Server → MongoDB → Response
```

### אימות משתמש:
```
Flutter/Admin → Firebase Auth → Token → API Server (validates) → MongoDB
```

**לעולם לא:**
```
Flutter/Admin → MongoDB ❌
```

## 📦 מבנה הפרויקטים

```
mental-coach/
├── mental-coach-api/          # Backend API
│   ├── Dockerfile
│   ├── railway.toml
│   ├── package.json
│   └── src/
│
├── mental-coach-admin/        # Admin Panel
│   ├── Dockerfile
│   ├── railway.toml
│   ├── package.json
│   └── src/
│
└── mental-coach-flutter/      # Flutter Web App
    ├── Dockerfile.railway
    ├── railway.toml
    ├── pubspec.yaml
    └── lib/
```

## 🔌 נקודות קצה

### Production (Railway)
- **API**: `https://mental-coach-api.up.railway.app`
- **Admin**: `https://mental-coach-admin.up.railway.app`
- **Flutter**: `https://mental-coach-flutter.up.railway.app`

### Development (Local)
- **API**: `http://localhost:3000`
- **Admin**: `http://localhost:9977`
- **Flutter**: `http://localhost:8080`

## 🔐 אבטחה

### Authentication Flow
```
User ──▶ Flutter/Admin ──▶ Firebase Auth
              │                   │
              ▼                   ▼
         JWT Token           User UID
              │                   │
              └───────┬───────────┘
                      ▼
                  API Server
                      │
                      ▼
                  MongoDB
```

### Security Layers
1. **JWT Authentication** - לכל בקשה מאומתת ל-API
2. **API Keys** - לשירותים חיצוניים
3. **CORS** - רק domains מורשים ל-API
4. **Rate Limiting** - הגבלת בקשות ל-API
5. **Input Validation** - בדיקת כל input ב-API
6. **Database Access** - רק דרך API Server

## 🚀 Deployment Strategy

### 1. Development
```bash
git push origin develop
# Automatic deployment to dev environment
```

### 2. Staging
```bash
git push origin staging
# Automatic deployment to staging
```

### 3. Production
```bash
git push origin main
# Manual approval required
# Automatic deployment after approval
```

## 📊 Monitoring & Logging

### Services Monitored
- **API Health**: `/api/health`
- **Admin Health**: `/health`
- **Flutter Health**: `/health`

### Metrics Tracked
- Response times
- Error rates
- User sessions
- Database queries
- Memory usage
- CPU usage

## 🔄 Scaling Strategy

### Horizontal Scaling
```
┌──────────┐
│ Load     │
│ Balancer │
└────┬─────┘
     │
┌────▼────┬────────┬────────┐
│ API-1   │ API-2  │ API-3  │
└─────────┴────────┴────────┘
```

### Database Scaling
- **MongoDB Atlas** - Auto-scaling clusters
- **Read Replicas** - לקריאות
- **Sharding** - לנתונים גדולים

## 🛠️ Technology Stack

### Backend (API) - השרת היחיד שניגש ל-DB
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB (גישה בלעדית)
- **Auth**: Firebase Admin SDK
- **Email**: SendGrid
- **SMS**: Twilio

### Admin Panel - ניגש רק ל-API
- **Framework**: React 18
- **Build**: Vite
- **UI**: Material-UI
- **State**: React Context
- **Router**: React Router v6
- **Auth**: Firebase Client SDK
- **API Client**: Axios/Fetch

### Flutter Web - ניגש רק ל-API
- **Framework**: Flutter 3.x
- **State**: Provider
- **Router**: GoRouter
- **Storage**: SharedPreferences
- **HTTP**: Dio
- **Auth**: Firebase Client SDK

## 🔧 Development Setup

### Prerequisites
```bash
# Install Docker
brew install docker

# Install Railway CLI
brew install railway

# Install Flutter
brew install flutter
```

### Local Development
```bash
# Clone all repositories
git clone https://github.com/YOUR_ORG/mental-coach-api
git clone https://github.com/YOUR_ORG/mental-coach-admin
git clone https://github.com/YOUR_ORG/mental-coach-flutter

# Run services locally
./test-local-services.sh
```

## 📝 Environment Variables

### Critical Variables
- `DATABASE_URL` - MongoDB connection
- `JWT_SECRET` - Authentication secret
- `API_URL` - API endpoint
- `FIREBASE_*` - Firebase configuration

### Service Discovery
```javascript
// API Server knows about:
DATABASE_URL=mongodb://...        // Database connection
CORS_ORIGINS=admin-url,flutter-url // Allowed origins
FIREBASE_SERVICE_ACCOUNT=...      // Firebase admin SDK

// Admin Panel knows about:
VITE_API_URL=api-url              // API endpoint only
FIREBASE_CONFIG=...               // Firebase client SDK

// Flutter Web knows about:
API_URL=api-url                   // API endpoint only
FIREBASE_CONFIG=...               // Firebase client SDK
```

**חשוב:** Admin ו-Flutter לא ניגשים ישירות ל-Database!

## 🔒 Backup & Recovery

### Database Backup
- **Frequency**: Daily
- **Retention**: 30 days
- **Location**: MongoDB Atlas Backups

### Code Backup
- **Git**: All code in GitHub
- **Branches**: Protected main branch
- **Tags**: Version releases

## 📈 Performance Optimization

### API
- Response caching
- Database indexing
- Query optimization
- Connection pooling

### Frontend
- Code splitting
- Lazy loading
- Image optimization
- CDN for assets

## 🚨 Disaster Recovery

### RTO (Recovery Time Objective)
- **Target**: < 1 hour

### RPO (Recovery Point Objective)
- **Target**: < 24 hours

### Recovery Steps
1. Restore database from backup
2. Redeploy services from Git
3. Update DNS if needed
4. Verify all services

## 📞 Support & Maintenance

### Monitoring Tools
- **Railway Metrics** - Service health
- **MongoDB Atlas** - Database monitoring
- **Sentry** - Error tracking
- **Google Analytics** - User analytics

### Alert Channels
- Email notifications
- Discord webhooks
- SMS for critical issues

---
*Architecture Version: 2.0*
*Last Updated: January 2025*