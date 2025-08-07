import twilio from "twilio";
import "colors";

class TwilioService {
  private client: twilio.Twilio | null = null;
  private fromNumber: string = "";
  private isInitialized: boolean = false;

  constructor() {
    this.initialize();
  }

  private initialize() {
    try {
      const accountSid = process.env.TWILIO_ACCOUNT_SID;
      const authToken = process.env.TWILIO_AUTH_TOKEN;
      this.fromNumber = process.env.TWILIO_PHONE_NUMBER || "";

      if (!accountSid || !authToken || !this.fromNumber) {
        console.log("[Twilio Service] Missing Twilio credentials - SMS disabled".yellow);
        return;
      }

      this.client = twilio(accountSid, authToken);
      this.isInitialized = true;
      console.log("[Twilio Service] Initialized successfully ✓".green);
    } catch (error) {
      console.error("[Twilio Service] Initialization error:".red, error);
    }
  }

  /**
   * Generate a random 6-digit OTP code
   */
  generateOTP(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Format phone number to E.164 format
   */
  formatPhoneNumber(phone: string): string {
    // Remove any non-digit characters
    let cleaned = phone.replace(/\D/g, "");
    
    // Handle Israeli numbers
    if (cleaned.startsWith("0")) {
      cleaned = "972" + cleaned.substring(1);
    } else if (!cleaned.startsWith("972") && !cleaned.startsWith("1")) {
      // Assume Israeli number if not starting with country code
      cleaned = "972" + cleaned;
    }
    
    // Add + prefix
    return "+" + cleaned;
  }

  /**
   * Send OTP via SMS
   */
  async sendOTP(phoneNumber: string, otp: string): Promise<boolean> {
    if (!this.isInitialized || !this.client) {
      console.log("[Twilio Service] Service not initialized - cannot send SMS".yellow);
      return false;
    }

    try {
      const formattedPhone = this.formatPhoneNumber(phoneNumber);
      
      const message = await this.client.messages.create({
        body: `קוד האימות שלך למאמן המנטלי: ${otp}\nהקוד תקף ל-5 דקות.`,
        from: this.fromNumber,
        to: formattedPhone
      });

      console.log(`[Twilio Service] SMS sent successfully to ${formattedPhone}`.green);
      console.log(`[Twilio Service] Message SID: ${message.sid}`.gray);
      
      return true;
    } catch (error: any) {
      console.error("[Twilio Service] Failed to send SMS:".red, error.message);
      
      // Log specific Twilio error codes
      if (error.code) {
        console.error(`[Twilio Service] Error code: ${error.code}`.red);
        console.error(`[Twilio Service] Error details: ${error.moreInfo}`.red);
      }
      
      return false;
    }
  }

  /**
   * Send custom SMS message
   */
  async sendCustomSMS(phoneNumber: string, message: string): Promise<boolean> {
    if (!this.isInitialized || !this.client) {
      console.log("[Twilio Service] Service not initialized - cannot send SMS".yellow);
      return false;
    }

    try {
      const formattedPhone = this.formatPhoneNumber(phoneNumber);
      
      const result = await this.client.messages.create({
        body: message,
        from: this.fromNumber,
        to: formattedPhone
      });

      console.log(`[Twilio Service] Custom SMS sent to ${formattedPhone}`.green);
      
      return true;
    } catch (error: any) {
      console.error("[Twilio Service] Failed to send custom SMS:".red, error.message);
      return false;
    }
  }

  /**
   * Verify phone number format
   */
  isValidPhoneNumber(phone: string): boolean {
    const formatted = this.formatPhoneNumber(phone);
    return /^\+[1-9]\d{1,14}$/.test(formatted);
  }

  /**
   * Get service status
   */
  getStatus(): { initialized: boolean; hasCredentials: boolean } {
    return {
      initialized: this.isInitialized,
      hasCredentials: !!(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_PHONE_NUMBER)
    };
  }
}

// Export singleton instance
export default new TwilioService();