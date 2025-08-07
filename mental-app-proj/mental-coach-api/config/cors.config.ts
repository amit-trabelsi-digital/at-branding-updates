import { CorsOptions } from 'cors';

// פונקציה לבדיקה אם המקור הוא תחת הדומיין המורשה
const isAllowedDomain = (origin: string): boolean => {
  try {
    const url = new URL(origin);
    const hostname = url.hostname;
    
    // רשימת דומיינים מורשים
    const allowedDomains = [
      'eitanazaria.co.il',  // הדומיין הראשי וכל הסאב-דומיינים שלו
      'localhost',          // לפיתוח מקומי
      '127.0.0.1',         // לפיתוח מקומי
      '10.0.2.2',          // Android emulator
    ];
    
    // בודק אם המקור מסתיים באחד הדומיינים המורשים
    return allowedDomains.some(domain => {
      // מאפשר גם סאב-דומיינים (כולל multi-level)
      return hostname === domain || hostname.endsWith(`.${domain}`);
    });
  } catch (e) {
    // אם לא ניתן לפרסר את ה-URL, מחזיר false
    return false;
  }
};

// רשימת מקורות מותרים לפי סביבה (לתמיכה לאחור)
const getAllowedOrigins = (): string[] => {
  const baseOrigins = [];

  // הוספת localhost וכתובות פיתוח
  if (process.env.NODE_ENV === 'development' || process.env.ALLOW_LOCAL_CORS === 'true') {
    baseOrigins.push(
      // Localhost variations
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:5173',
      'http://localhost:5174',
      'http://localhost:5858',
      'http://localhost:8080',
      'http://localhost:9977',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001',
      'http://127.0.0.1:5173',
      'http://127.0.0.1:5174',
      'http://127.0.0.1:5858',
      'http://127.0.0.1:8080',
      'http://127.0.0.1:9977',
      
      // Local IP addresses for mobile testing
      'http://10.0.2.2:3000', // Android emulator
      'http://192.168.0.153:3000',
      'http://192.168.1.100:3000',
      'http://192.168.1.101:3000',
      
      // Flutter web
      'http://localhost:50505',
      'http://localhost:63342',
      
      // Allow any local IP in dev mode
      'http://192.168.0.0/16',
      'http://10.0.0.0/8',
      'http://172.16.0.0/12'
    );

    // הוספת כתובות מותאמות אישית מ-ENV
    if (process.env.ADDITIONAL_CORS_ORIGINS) {
      const additionalOrigins = process.env.ADDITIONAL_CORS_ORIGINS.split(',');
      baseOrigins.push(...additionalOrigins);
    }
  }

  return baseOrigins;
};

// יצירת הגדרות CORS
export const corsOptions: CorsOptions = {
  origin: function (origin, callback) {
    // בסביבת פיתוח - מאפשרים הכל
    if (process.env.NODE_ENV === 'development') {
      console.log(`[CORS] Development mode - allowing origin: ${origin || 'undefined (same-origin)'}`);
      callback(null, true);
      return;
    }

    // מאפשרים בקשות ללא origin (כמו Postman או בקשות מהשרת עצמו)
    if (!origin) {
      console.log('[CORS] No origin header - allowing request');
      callback(null, true);
      return;
    }

    // בודקים אם המקור הוא תחת דומיין מורשה
    const isDomainAllowed = isAllowedDomain(origin);
    
    if (isDomainAllowed) {
      console.log(`[CORS] Allowed origin (domain check): ${origin}`);
      callback(null, true);
    } else {
      // בדיקה נוספת מול רשימת origins ספציפיים (לתמיכה לאחור)
      const allowedOrigins = getAllowedOrigins();
      const isInList = allowedOrigins.some(allowedOrigin => {
        // בדיקה מדויקת
        if (allowedOrigin === origin) return true;
        
        // בדיקה עם wildcard לכתובות IP
        if (allowedOrigin.includes('/')) {
          try {
            const originHost = new URL(origin).hostname;
            const [network] = allowedOrigin.replace(/^https?:\/\//, '').split('/');
            // פישוט - בודקים אם מתחיל באותה רשת
            if (originHost.startsWith(network.split('.').slice(0, -1).join('.'))) {
              return true;
            }
          } catch (e) {
            return false;
          }
        }
        
        return false;
      });

      if (isInList) {
        console.log(`[CORS] Allowed origin (list check): ${origin}`);
        callback(null, true);
      } else {
        console.warn(`[CORS] Blocked origin: ${origin}`);
        console.warn(`[CORS] Origin must be under *.eitanazaria.co.il or in allowed list`);
        callback(new Error(`Not allowed by CORS - ${origin}`));
      }
    }
  },
  
  // הגדרות נוספות של CORS
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers',
    'X-Auth-Token',
    'X-Device-Id',
    'X-App-Version'
  ],
  exposedHeaders: [
    'Content-Length',
    'X-Total-Count',
    'X-Page',
    'X-Per-Page',
    'X-Auth-Token'
  ],
  preflightContinue: false,
  optionsSuccessStatus: 204,
  maxAge: 86400 // Cache preflight requests for 24 hours
};

// פונקציה לטיפול מיוחד ב-preflight requests
export const handlePreflight = (req: any, res: any, next: any) => {
  if (req.method === 'OPTIONS') {
    console.log(`[CORS] Handling OPTIONS preflight for: ${req.path}`);
    res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,PATCH,OPTIONS');
    res.header('Access-Control-Allow-Headers', req.headers['access-control-request-headers'] || '*');
    res.header('Access-Control-Allow-Credentials', 'true');
    res.header('Access-Control-Max-Age', '86400');
    return res.status(204).send();
  }
  next();
};

export default corsOptions;