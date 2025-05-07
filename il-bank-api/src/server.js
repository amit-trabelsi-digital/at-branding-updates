import express from 'express';
import cors from 'cors';
import { CompanyTypes, createScraper } from 'israeli-bank-scrapers-core';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3003;
const API_KEY = process.env.API_KEY;

// Middleware לאימות מפתח API
const authenticateApiKey = (req, res, next) => {
  const providedApiKey = req.headers['x-api-key'];
  
  if (!API_KEY) {
    console.warn('אזהרה: מפתח API לא הוגדר במשתני הסביבה');
    next();
    return;
  }

  if (!providedApiKey || providedApiKey !== API_KEY) {
    return res.status(401).json({ 
      success: false, 
      error: 'מפתח API לא תקין' 
    });
  }

  next();
};

app.post('/api/bank-data', authenticateApiKey, async (req, res) => {
  try {
    const { bankType, credentials, startDate, timeout } = req.body;
    
    if (!bankType || !credentials || !CompanyTypes[bankType]) {
      return res.status(400).json({ 
        success: false, 
        error: 'נדרשים פרטי בנק ופרטי התחברות תקינים' 
      });
    }

    const waitForSelectorTimeout = timeout && !isNaN(timeout) ? Number(timeout) : 60000;

    const options = {
      companyId: CompanyTypes[bankType],
      startDate: startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago by default
      showBrowser: true,
      ...(process.env.CHROMIUM_PATH && { executablePath: process.env.CHROMIUM_PATH }),
      defaultTimeout: waitForSelectorTimeout,
      combineInstallments: false,
      verbose: true,
      puppeteerOptions: {
          args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-blink-features=AutomationControlled'],
          defaultViewport: { width: 1280, height: 800 },
          headless: false,
          timeout: waitForSelectorTimeout,
      },
    //   startDate: startDateString ? new Date(startDateString) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    //   combineInstallments: combineInstallmentsBoolean !== undefined ? combineInstallmentsBoolean : false,
    //   showBrowser: showBrowserBoolean !== undefined ? showBrowserBoolean : false, // Likely always false on Netlify
    //   executablePath: await chromium.executablePath, // For chrome-aws-lambda
    };
    console.log('הגדרות סקרייפר:', JSON.stringify(options, null, 2));
    const scraper = createScraper(options);
    let scrapeResult;
    try {
      console.log('מתחיל סקרייפינג עבור', bankType);
      scrapeResult = await scraper.scrape(credentials);
      console.log('סיום סקרייפינג בהצלחה');
      
      // בדיקת תקינות התוצאה
      if (!scrapeResult) {
        console.error('תוצאת הסקרייפר ריקה או לא מוגדרת');
        return res.status(500).json({
          success: false,
          errorType: 'GENERIC',
          errorMessage: 'תוצאת הסקרייפר ריקה או לא מוגדרת'
        });
      }
      
      // טיפול בבעיה ספציפית של "text is not iterable"
      if (typeof scrapeResult === 'string') {
        try {
          // ננסה לפרסר את התוצאה אם היא מחרוזת JSON
          const parsedResult = JSON.parse(scrapeResult);
          scrapeResult = parsedResult;
        } catch (parseError) {
          console.error('שגיאה בפרסור תוצאת הסקרייפר:', parseError);
          // אם המחרוזת אינה JSON תקין, נחזיר את התוצאה כפי שהיא במבנה מתאים
          return res.status(500).json({
            success: false,
            errorType: 'PARSE_ERROR',
            errorMessage: 'שגיאה בפרסור תוצאת הסקרייפר: ' + parseError.message,
            rawText: scrapeResult
          });
        }
      }
    } catch (scrapeError) {
      console.error('שגיאה בסקרייפר:', scrapeError);
      
      // בדיקת סוג שגיאה ספציפי - "text is not iterable"
      if (scrapeError.message && scrapeError.message.includes('is not iterable')) {
        console.error('שגיאת איטרציה על טקסט:', scrapeError.message);
        return res.status(500).json({
          success: false,
          errorType: 'ITERABLE_ERROR',
          errorMessage: 'התקבל ערך שאינו ניתן לאיטרציה: ' + scrapeError.message
        });
      } 
      // בדיקת שגיאת timeout
      else if (scrapeError.message && scrapeError.message.includes('waiting for selector')) {
        return res.status(504).json({
          success: false,
          errorType: 'TIMEOUT',
          errorMessage: 'המערכת לא הצליחה לאתר אלמנט בדף הבנק בזמן שהוקצב. ייתכן שממשק הבנק השתנה או שיש להגדיר זמן המתנה ארוך יותר.'
        });
      }
      
      return res.status(500).json({
        success: false,
        errorType: 'GENERIC',
        errorMessage: scrapeError.message || 'שגיאה לא ידועה בסקרייפר'
      });
    }

    res.json(scrapeResult);
  } catch (error) {
    console.error('שגיאה בגישה לנתוני הבנק:', error);
    res.status(500).json({ 
      success: false, 
      error: 'שגיאה בגישה לנתוני הבנק' 
    });
  }
});

app.get('/api/supported-banks', authenticateApiKey, (req, res) => {
  res.json(Object.keys(CompanyTypes));
});

app.listen(PORT, () => {
  console.log(`השרת פועל בפורט ${PORT}`);
});