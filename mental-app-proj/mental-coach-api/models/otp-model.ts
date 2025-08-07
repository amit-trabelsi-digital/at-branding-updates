import mongoose, { Document, Schema } from "mongoose";

export interface IOtp extends Document {
  phoneNumber: string;
  email?: string;
  code: string;
  purpose: "login" | "verification" | "reset";
  attempts: number;
  isVerified: boolean;
  expiresAt: Date;
  verifiedAt?: Date;
  ipAddress?: string;
  userAgent?: string;
  createdAt: Date;
  updatedAt: Date;
  verifyCode(inputCode: string): boolean;
}

const OtpSchema: Schema = new Schema<IOtp>(
  {
    phoneNumber: {
      type: String,
      required: true,
      validate: {
        validator: function (v: string) {
          // E.164 format validation
          return /^\+[1-9]\d{1,14}$/.test(v);
        },
        message: (props: { value: string }) => `${props.value} is not a valid E.164 phone number format!`
      }
    },
    email: {
      type: String,
      lowercase: true,
      trim: true
    },
    code: {
      type: String,
      required: true,
      minlength: 6,
      maxlength: 6
    },
    purpose: {
      type: String,
      enum: ["login", "verification", "reset"],
      default: "login"
    },
    attempts: {
      type: Number,
      default: 0,
      max: 3
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    expiresAt: {
      type: Date,
      required: true,
      default: () => new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
      index: { expireAfterSeconds: 0 } // Automatic cleanup by MongoDB
    },
    verifiedAt: {
      type: Date
    },
    ipAddress: {
      type: String
    },
    userAgent: {
      type: String
    }
  },
  {
    timestamps: true
  }
);

// Indexes for better performance
OtpSchema.index({ phoneNumber: 1, code: 1 });
OtpSchema.index({ email: 1, code: 1 });
OtpSchema.index({ createdAt: 1 }, { expireAfterSeconds: 600 }); // Auto delete after 10 minutes

// Method to verify OTP
OtpSchema.methods.verifyCode = function(inputCode: string): boolean {
  if (this.isVerified) {
    return false; // Already verified
  }
  
  if (this.attempts >= 3) {
    return false; // Too many attempts
  }
  
  if (new Date() > this.expiresAt) {
    return false; // Expired
  }
  
  this.attempts += 1;
  
  if (this.code === inputCode) {
    this.isVerified = true;
    this.verifiedAt = new Date();
    return true;
  }
  
  return false;
};

const Otp = mongoose.model<IOtp>("Otp", OtpSchema);

export default Otp;