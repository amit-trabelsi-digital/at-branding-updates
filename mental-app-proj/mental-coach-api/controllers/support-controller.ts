import { Request, Response, NextFunction } from "express";
import AppError from "../utils/appError";
import Email from "../utils/react-email";
import catchAsync from "../utils/catchAsync";

interface SupportRequest {
  subject: string;
  description: string;
  userEmail: string;
  userName: string;
  currentPage: string;
  dateTime: string;
  attachments?: string[]; // URLs של קבצים שהועלו
  openDialog?: string; // שם הדיאלוג/פופאפ הפתוח
  environment?: string; // סביבת הרצה
  hostname?: string; // שם הדומיין
  userAgent?: string; // פרטי הדפדפן
  ipAddress?: string; // כתובת IP
}

export const sendSupportRequest = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const supportData: SupportRequest = req.body;
  
  // הוספת כתובת IP מה-request
  supportData.ipAddress = req.ip || req.connection.remoteAddress || 'Unknown';

  // בדיקת שדות חובה
  if (!supportData.subject || !supportData.description || !supportData.userEmail) {
    return next(new AppError("חסרים שדות חובה", 400));
  }

  try {
    // שליחת אימייל לתמיכה
    const emailContent = `
      <div dir="rtl" style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>פנייה חדשה למערכת תמיכה</h2>
        
        <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <h3>פרטי הפנייה:</h3>
          <p><strong>נושא:</strong> ${supportData.subject}</p>
          <p><strong>תיאור:</strong></p>
          <div style="background: white; padding: 10px; border-radius: 3px;">
            ${supportData.description.replace(/\n/g, '<br>')}
          </div>
        </div>

        <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <h3>פרטי המשתמש:</h3>
          <p><strong>שם:</strong> ${supportData.userName}</p>
          <p><strong>אימייל:</strong> ${supportData.userEmail}</p>
          <p><strong>תאריך ושעה:</strong> ${supportData.dateTime}</p>
        </div>

        <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <h3>מידע טכני:</h3>
          <p><strong>עמוד נוכחי:</strong> ${supportData.currentPage}</p>
          <p><strong>סביבת הרצה:</strong> ${supportData.environment || 'לא צוין'}</p>
          <p><strong>שם דומיין:</strong> ${supportData.hostname || 'לא צוין'}</p>
          <p><strong>כתובת IP:</strong> ${supportData.ipAddress || 'לא זוהה'}</p>
          <p><strong>דפדפן:</strong> ${supportData.userAgent || 'לא צוין'}</p>
          ${supportData.openDialog ? `<p><strong>דיאלוג פתוח:</strong> ${supportData.openDialog}</p>` : ''}
          ${supportData.attachments && supportData.attachments.length > 0 ? `
            <p><strong>קבצים מצורפים:</strong></p>
            <ul>
              ${supportData.attachments.map(url => `<li><a href="${url}" target="_blank">${url}</a></li>`).join('')}
            </ul>
          ` : ''}
        </div>
      </div>
    `;

    // שליחה באמצעות SendGrid
    const sgMail = require('@sendgrid/mail');
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);
    
    const msg = {
      to: 'amit@trabel.si',
      from: process.env.EMAIL_FROM || 'support@mental-coach.com',
      subject: `[תמיכה - המאמן המנטלי] ${supportData.subject}`,
      html: emailContent,
      replyTo: supportData.userEmail
    };

    await sgMail.send(msg);

    // שליחת אישור למשתמש
    const userConfirmationContent = `
      <div dir="rtl" style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>אישור קבלת פנייה</h2>
        <p>שלום ${supportData.userName},</p>
        <p>קיבלנו את פנייתך בנושא: <strong>${supportData.subject}</strong></p>
        <p>נענה לך בהקדם האפשרי.</p>
        <br>
        <p>בברכה,<br>צוות התמיכה של המאמן המנטלי</p>
      </div>
    `;

    const userMsg = {
      to: supportData.userEmail,
      from: process.env.EMAIL_FROM || 'support@mental-coach.com',
      subject: `אישור קבלת פנייה - ${supportData.subject}`,
      html: userConfirmationContent
    };

    await sgMail.send(userMsg);

    res.status(200).json({
      status: "success",
      message: "הפנייה נשלחה בהצלחה"
    });
  } catch (error) {
    console.error("Error sending support email:", error);
    return next(new AppError("שגיאה בשליחת הפנייה", 500));
  }
});