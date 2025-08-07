import { Document, Schema, model } from "mongoose";

export interface IPushMessage extends Document {
  title: string;
  message: string;
  recipient: string; // Could be a user ID or "all" for broadcasting
  data?: Record<string, any>; // Optional payload for additional information
  dataLink: string;
  readMoreLink: string;
  notes: string;
  appearedIn: string;
  sent: boolean;
  createdAt: Date;
  sentAt?: Date;
}

// Define the schema for the PushMessage model
const PushMessageSchema: Schema = new Schema<IPushMessage>({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  message: {
    type: String,
    required: true,
    trim: true,
  },
  data: {
    type: Schema.Types.Mixed, // Allows any structure for the data field
    default: {},
  },
  dataLink: {
    type: String,
    required: true,
  },
  readMoreLink: {
    type: String,
  },
  appearedIn: {
    type: String,
    trim: true,
  },
  recipient: {
    type: String,
    trim: true,
  },
  sent: {
    type: Boolean,
    default: false,
  },
  notes: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  sentAt: {
    type: Date,
  },
});

// Add indexes for querying efficiency (e.g., by recipient or sent status)
PushMessageSchema.index({ recipient: 1 });
PushMessageSchema.index({ sent: 1 });

// Create and export the PushMessage model
const PushMessage = model<IPushMessage>("PushMessage", PushMessageSchema);
export default PushMessage;
