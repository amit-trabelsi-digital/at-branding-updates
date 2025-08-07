# Mental Coach API

> Node.js/Express API server לפלטפורמת אימון מנטלי לספורטאים - עם MongoDB, Firebase ושירותי צד שלישי

\![API Status](https://img.shields.io/badge/API-Production_Ready-success) \![Node Version](https://img.shields.io/badge/Node.js-18+-green) \![Database](https://img.shields.io/badge/Database-MongoDB-green)

🌐 **Live API**: [https://dev-srv.eitanazaria.co.il](https://dev-srv.eitanazaria.co.il)

## 📋 תוכן עניינים

- [סקירה כללית](#-סקירה-כללית)
- [מאפיינים עיקריים](#-מאפיינים-עיקריים)
- [ארכיטקטורה טכנית](#-ארכיטקטורה-טכנית)
- [התקנה והרצה](#-התקנה-והרצה)
- [מבנה הפרויקט](#-מבנה-הפרויקט)
- [API Endpoints](#-api-endpoints)
- [משתני סביבה](#-משתני-סביבה)
- [סקריפטי ניהול](#-סקריפטי-ניהול)
- [פריסה לפרודקשן](#-פריסה-לפרודקשן)
- [תיעוד נוסף](#-תיעוד-נוסף)

## 🎯 סקירה כללית

**Mental Coach API** הוא שרת backend מקיף המספק שירותים לפלטפורמת האימון המנטלי. השרת מנהל את כל הנתונים, הלוגיקה העסקית, ומספק API RESTful לאפליקציות הלקוח.

### 🏆 תחומי שימוש
- **אימון מנטלי לספורטאים** - קורסים דיגיטליים ותרגילים
- **ניהול משחקים וליגות** - מעקב אחר ביצועים וסטטיסטיקות  
- **מערכת אימות מאובטחת** - עם Firebase וOTP
- **תקשורת אוטומטית** - SMS ואימיילים עם תבניות דינמיות

## ✨ מאפיינים עיקריים

### 🔐 אבטחה ואימות
- **Firebase Authentication** - אימות מאובטח עם JWT
- **Role-based Access Control** - הרשאות מבוססות תפקיד  
- **OTP Authentication** - אימות דו-שלבי עם Twilio SMS
- **Input Sanitization** - הגנה מפני SQL Injection ו-XSS
- **Rate Limiting** - הגבלת בקשות למניעת DDoS

### 📚 מערכת קורסים דיגיטליים
- **Training Programs** - תוכניות אימון היררכיות
- **Lessons & Exercises** - שיעורים ותרגילים אינטראקטיביים
- **Progress Tracking** - מעקב התקדמות אישית
- **Access Control** - ניהול גישה לתוכן לפי מנויים

### ⚽ ניהול ספורטיבי
- **Leagues & Teams** - ניהול ליגות וקבוצות
- **Match Management** - תיזמון משחקים ותוצאות
- **Performance Analytics** - ניתוח ביצועים וסטטיסטיקות
- **Goal Tracking** - מעקב אחר מטרות אישיות

### 📧 תקשורת ותבלוגים
- **Email Templates** - תבניות React Email מתקדמות
- **SMS Integration** - שליחת הודעות עם Twilio
- **Push Notifications** - הודעות דחף עם Firebase
- **Auto Notifications** - התראות אוטומטיות לאירועים

## 🏗️ ארכיטקטורה טכנית

### Technology Stack
```
┌─────────────────────────────────────────┐
│              Mental Coach API            │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   Node.js   │  │   TypeScript    │   │
│  │     +       │  │    (Strict)     │   │
│  │  Express.js │  └─────────────────┘   │
│  └─────────────┘                        │
│                                         │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │  MongoDB    │  │    Firebase     │   │
│  │     +       │  │     Admin       │   │
│  │  Mongoose   │  │      SDK        │   │
│  └─────────────┘  └─────────────────┘   │
│                                         │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   Twilio    │  │    SendGrid     │   │
│  │    SMS      │  │     Email       │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

### Core Dependencies
- **Runtime**: Node.js 18+ | TypeScript 5+
- **Framework**: Express.js 4+ עם middleware מתקדם
- **Database**: MongoDB 6+ עם Mongoose ODM
- **Authentication**: Firebase Admin SDK
- **Communication**: SendGrid Email | Twilio SMS
- **Security**: Helmet, CORS, HPP, Rate Limiting

## 🚀 התקנה והרצה

### דרישות מערכת
- **Node.js** 18.0.0 ומעלה
- **MongoDB** (מקומי או Atlas)
- **Firebase Project** עם Admin SDK
- **SendGrid Account** (אופציונלי)
- **Twilio Account** (אופציונלי)

### התקנה מהירה

```bash
# שכפול הפרויקט
git clone https://github.com/amit-trabelsi-digital/mental-coach-api.git
cd mental-coach-api

# התקנת תלויות
npm install

# הגדרת משתני סביבה
cp .env.example .env
# ערוך את .env עם הפרטים שלך

# בניית הפרויקט
npm run build

# הרצה בפיתוח
npm run dev

# הרצה בפרודקשן
npm start
```

### הרצה עם Docker

```bash
# בניית image
docker build -t mental-coach-api .

# הרצת container
docker run -p 3000:3000 mental-coach-api
```

## 📁 מבנה הפרויקט

```
mental-coach-api/
├── 📂 controllers/           # בקרים - לוגיקה עסקית
│   ├── auth-controller.ts    # אימות משתמשים
│   ├── user-controller.ts    # ניהול משתמשים
│   ├── training-program-controller.ts # קורסי אימון
│   ├── lesson-controller.ts  # שיעורים
│   ├── match-controller.ts   # ניהול משחקים
│   ├── otp-controller.ts     # אימות OTP/SMS
│   └── external-api-controller.ts # API חיצוני
├── 📂 models/                # מודלים - סכמות MongoDB
│   ├── user-model.ts         # מודל משתמש
│   ├── training-program-model.ts # תוכניות אימון
│   ├── lesson-model.ts       # שיעורים
│   ├── match-model.ts        # משחקים
│   └── otp-model.ts         # קודי OTP
├── 📂 routes/                # נתיבים - הגדרת API endpoints
│   ├── authRoutes.ts         # נתיבי אימות
│   ├── userRoutes.ts         # נתיבי משתמשים
│   ├── trainingProgramRoutes.ts # נתיבי אימון
│   ├── lessonRoutes.ts       # נתיבי שיעורים
│   ├── otpRoutes.ts          # נתיבי OTP
│   └── externalApiRoutes.ts  # API חיצוני
├── 📂 middlewares/           # Middleware functions
│   ├── appAuthMiddleware.ts  # אימות כללי
│   ├── trainingAuthMiddleware.ts # אימות קורסים
│   ├── externalApiAuthMiddleware.ts # אימות API חיצוני
│   └── deviceCheckMiddleware.ts # בדיקת מכשיר
├── 📂 utils/                 # פונקציות עזר
│   ├── appError.ts           # טיפול בשגיאות
│   ├── catchAsync.ts         # Async error handling
│   ├── helpers.ts            # פונקציות עזר כלליות
│   └── react-email.ts        # עזרים לאימייל
├── 📂 services/              # שירותים חיצוניים
│   └── twilio-service.ts     # שירות SMS
├── 📂 emails/                # תבניות React Email
│   ├── WelcomeEmail.tsx      # אימייל ברוכים הבאים
│   ├── PasswordResetEmail.tsx # איפוס סיסמה
│   └── components/           # רכיבי אימייל
├── 📂 scripts/               # סקריפטי ניהול
│   ├── create-user.mjs       # יצירת משתמש
│   ├── make-user-admin.mjs   # הפיכת משתמש למנהל
│   ├── seed-training.mjs     # זריעת תוכן אימון
│   ├── test-otp.mjs          # בדיקת מערכת OTP
│   └── app-token-generator.mjs # יצירת טוקני אפליקציה
├── 📂 data/                  # נתונים סטטיים
│   ├── lists.ts              # רשימות מובנות
│   └── training-program-data.ts # נתוני אימון מדגם
├── 📂 docs/                  # תיעוד מפורט
│   ├── 📂 api/               # תיעוד API
│   ├── 📂 deployment/        # מדריכי פריסה
│   ├── 📂 examples/          # דוגמאות קוד
│   ├── SUMMARY.md            # סיכום הפרויקט
│   └── tasks.md              # משימות ופיתוחים
├── 📂 logs/                  # קבצי לוג (בפרודקשן)
├── ⚙️ server.ts              # נקודת כניסה ראשית
├── 🐳 Dockerfile             # הגדרות Docker
├── 🚂 railway.json           # הגדרות Railway
├── 📦 package.json           # תלויות ו-scripts
├── 🔧 tsconfig.json          # הגדרות TypeScript
├── 🔑 .env.example           # תבנית משתני סביבה
└── 📖 README.md              # התיעוד הזה
```

## 🛣️ API Endpoints

### Authentication & Users
```
POST   /api/auth/login          # התחברות משתמש
POST   /api/auth/signup         # הרשמת משתמש
GET    /api/users               # רשימת משתמשים (admin)
POST   /api/users               # יצירת משתמש (admin)
PUT    /api/users/:id           # עדכון משתמש
DELETE /api/users/:id           # מחיקת משתמש (admin)
```

### OTP & SMS Authentication
```
POST   /api/otp/send            # שליחת קוד OTP
POST   /api/otp/verify          # אימות קוד OTP
GET    /api/otp/status          # סטטוס מערכת OTP
```

### Training System
```
GET    /api/training-programs   # רשימת תוכניות אימון
POST   /api/training-programs   # יצירת תוכנית אימון (admin)
GET    /api/training-programs/:id # פרטי תוכנית אימון
PUT    /api/training-programs/:id # עדכון תוכנית אימון (admin)

GET    /api/lessons             # רשימת שיעורים
GET    /api/lessons/:id         # פרטי שיעור
POST   /api/lessons             # יצירת שיעור (admin)

GET    /api/exercises           # רשימת תרגילים
POST   /api/exercises           # יצירת תרגיל (admin)

GET    /api/user/progress       # התקדמות משתמש
POST   /api/user/enroll         # הרשמה לקורס
```

### Sports Management
```
GET    /api/leagues             # רשימת ליגות
POST   /api/leagues             # יצירת ליגה (admin)
GET    /api/teams               # רשימת קבוצות
POST   /api/teams               # יצירת קבוצה (admin)
GET    /api/matches             # רשימת משחקים
POST   /api/matches             # יצירת משחק
PUT    /api/matches/:id         # עדכון משחק
```

### External API (Third-party)
```
GET    /api/external/health     # בדיקת בריאות API
GET    /api/external/users      # משתמשים (עם אימות)
GET    /api/external/programs   # תוכניות (עם אימות)
POST   /api/external/webhook    # Webhook לאירועים
```

### Health & Info
```
GET    /                       # Health check (Hebrew)
GET    /api/health             # Health check (English)
GET    /api/info/version       # גרסת API
```

## ⚙️ משתני סביבה

### `.env` - הגדרות חיוניות

```bash
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
MONGO_URI_DEV=mongodb://localhost:27017/mental-coach-dev
DB_NAME=mental-coach-dev

# Firebase Configuration (נדרש\!)
FIREBASE_PRIVATE_KEY=your_firebase_private_key_here
FIREBASE_PRIVATE_ID=your_firebase_project_id_here
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com

# Email Service (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# SMS Service (Twilio)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890

# External API Security
APP_TOKEN_SECRET=your_secret_key_for_external_api_access

# Redis (Optional - for caching)
REDIS_URL=redis://localhost:6379
```

### Production Environment (Railway)
```bash
# Production MongoDB
DATABASE_URL=mongodb+srv://username:password@cluster.mongodb.net/mental-coach-prod

# Firebase Service Account (JSON)
FIREBASE_SERVICE_ACCOUNT={"type":"service_account","project_id":"..."}
```

## 🔧 סקריפטי ניהול

### Management Scripts (`/scripts/`)

| Script | Description | Usage |
|--------|-------------|-------|
| `create-user.mjs` | יצירת משתמש חדש | `npm run create-user` |
| `make-user-admin.mjs` | הפיכת משתמש למנהל | `npm run make-user-admin` |
| `app-token-generator.mjs` | יצירת טוקן API חיצוני | `npm run app-token-generator` |
| `seed-training.mjs` | זריעת תוכן אימון | `npm run seed-training` |
| `seed-real-training-data.mjs` | זריעת נתונים אמיתיים | `npm run seed:real-training` |
| `test-otp.mjs` | בדיקת מערכת SMS/OTP | `npm run test-otp` |
| `clean-user-matches.mjs` | ניקוי נתוני משחקים | `npm run reset-matches` |
| `clean-user-profile-stages.mjs` | איפוס התקדמות | `npm run reset-profile-marks` |
| `kill-port.mjs` | סגירת תהליך על פורט | `npm run kill-port` |

### Development Scripts
```bash
# פיתוח
npm run dev              # הרצה עם nodemon + ts-node
npm run dev:fresh        # הרצה טרייה (kill port + dev)

# בניה והרצה
npm run build            # קומפילציה ל-JavaScript
npm start                # הרצת קבצי production
npm run kill-port        # סגירת תהליך על פורט

# ניהול נתונים
npm run create-user      # יצירת משתמש חדש
npm run make-user-admin  # הפיכה למנהל
npm run seed-training    # הזנת תוכן אימון
npm run test-otp         # בדיקת SMS
```

## 🌐 פריסה לפרודקשן

### Railway Deployment (מומלץ)

הפרויקט מוכן לפריסה ב-Railway עם:
- ✅ `Dockerfile` מותאם לפרודקשן
- ✅ `railway.json` עם הגדרות מתקדמות
- ✅ Health check נתיב: `/api/health`
- ✅ Multi-stage build לאופטימיזציה

```bash
# פריסה אוטומטית
git push origin main

# או באמצעות סקריפט
./deploy-to-railway.sh
```

### Docker Deployment

```bash
# בניית image מותאמת לפרודקשן
docker build -t mental-coach-api:latest .

# הרצה עם environment variables
docker run -d \
  -p 3000:3000 \
  --env-file .env.production \
  mental-coach-api:latest
```

### Environment Setup בRailway

1. **Database**: הוספת MongoDB דרך Railway או Atlas
2. **Firebase**: העלאת Service Account JSON
3. **Twilio**: הוספת credentials לSMS
4. **SendGrid**: הוספת API key לאימיילים

## 📚 תיעוד נוסף

### API Documentation
- 📖 [מדריך API מפורט](./docs/api/EXTERNAL_API_DOCUMENTATION.md)
- 🔧 [הגדרת API חיצוני](./docs/api/EXTERNAL_API_SETUP.md)
- 🔐 [מדריך Authentication](./docs/api/Authentication-Guide.md)
- 📱 [מדריך OTP/SMS](./docs/api/OTP-SMS-Authentication.md)

### Deployment Guides
- 🚂 [פריסה ל-Railway](./docs/deployment/RAILWAY_DEPLOYMENT.md)
- ✅ [Checklist לפריסה](./docs/deployment/DEPLOYMENT_CHECKLIST.md)
- 🌍 [תבנית משתני סביבה](./docs/deployment/RAILWAY_ENV_TEMPLATE.txt)

### Examples & Tools
- 🐍 [דוגמה Python](./docs/examples/python-example.py)
- 🟨 [דוגמה Node.js](./docs/examples/nodejs-example.js)
- 📮 [Postman Collections](./docs/api/)

### Project Management
- 📋 [סיכום הפרויקט](./docs/SUMMARY.md)
- 📝 [משימות ופיתוחים](./docs/tasks.md)
- 🔄 [CHANGELOG](./CHANGELOG.md)

## 🔒 אבטחה

### Security Features
- ✅ **JWT Authentication** עם Firebase
- ✅ **Role-based Access Control** (Admin/User)
- ✅ **Input Sanitization** (mongo-sanitize)
- ✅ **Rate Limiting** (1000 req/window)
- ✅ **CORS Protection** עם whitelist
- ✅ **Helmet Security Headers**
- ✅ **HPP Protection** (HTTP Parameter Pollution)
- ✅ **Environment Variables** לסודות

### Security Best Practices
```typescript
// מערכת Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000 // limit each IP to 1000 requests per windowMs
});

// Input Sanitization
app.use(mongoSanitize()); // מסיר query operators מזיקים
app.use(hpp()); // מונע HTTP Parameter Pollution

// CORS עם הגבלות
app.use(cors({
  origin: ['https://app.mentalgame.co.il', 'https://admin.mentalgame.co.il'],
  credentials: true
}));
```

## 📊 ביצועים

### Performance Metrics
- ⚡ **Response Time**: <200ms average
- 🗄️ **Database Queries**: אופטימציה עם indexes
- 📦 **Memory Usage**: ~150MB average
- 🔄 **Concurrent Users**: 1000+ supported

### Optimization Features
- 🏃‍♂️ **Connection Pooling** למסד נתונים
- 📊 **Database Indexing** לשאילתות מהירות  
- 🧹 **Garbage Collection** אופטימליני
- 📈 **Error Monitoring** עם לוגים מפורטים

## 🤝 תמיכה ותרומה

### Getting Help
- 📧 **Email**: amit@trabel.si
- 🌐 **Website**: [amit-trabelsi.co.il](https://amit-trabelsi.co.il)
- 🐛 **Issues**: [GitHub Issues](https://github.com/amit-trabelsi-digital/mental-coach-api/issues)

### Contributing
1. Fork the project
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Environment
```bash
# Setup development environment
git clone https://github.com/amit-trabelsi-digital/mental-coach-api.git
cd mental-coach-api
npm install
cp .env.example .env
# Configure .env with your settings
npm run dev
```

---

## 📄 License & Credits

© 2025 **עמית טרבלסי** - All Rights Reserved

**Built with** ❤️ **using:**
- Node.js + TypeScript
- Express.js + MongoDB  
- Firebase + SendGrid + Twilio

---

<div align="center">

**🧠 Mental Coach API** - Powering Athletic Mental Excellence

[\![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[\![TypeScript](https://img.shields.io/badge/TypeScript-5+-blue)](https://www.typescriptlang.org/)
[\![MongoDB](https://img.shields.io/badge/MongoDB-6+-green)](https://mongodb.com/)
[\![Express](https://img.shields.io/badge/Express-4+-lightgrey)](https://expressjs.com/)

</div>