import { Document, Schema, model } from "mongoose";

export interface IEitanMessage extends Document {
  title: string;
  message: string;
  recipient: string; // Could be a user ID or "all" for broadcasting
}

// Define the schema for the EitanMessage model
const EitanMessageSchema: Schema = new Schema<IEitanMessage>(
  {
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
    recipient: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { timestamps: true }
);

// Add indexes for querying efficiency (e.g., by recipient or sent status)
EitanMessageSchema.index({ recipient: 1 });
EitanMessageSchema.index({ sent: 1 });

// Create and export the EitanMessage model
const EitanMessage = model<IEitanMessage>("EitanMessage", EitanMessageSchema);
export default EitanMessage;
