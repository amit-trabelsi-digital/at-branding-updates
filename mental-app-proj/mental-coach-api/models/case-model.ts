import mongoose, { Model } from "mongoose";
const { Schema } = mongoose;

export interface ICasesAndResponses extends Document {
  case: string;
  response: string;
  responseState: "before" | "after" | "inTime";
  link: string;
  sent: boolean;
  createdAt: Date;
  sentAt?: Date;
  notes: string;
  positions: { value: string; label: string }[];
  tags: { value: string; label: string }[];
  data?: Record<string, any>; // Optional payload for additional information
}

const CaseSchema = new Schema<ICasesAndResponses>({
  case: { type: String },
  response: { type: String },
  responseState: {
    type: String,
    enum: [
      "before", // Striker
      "after", // Striker
      "inTime", // Striker
    ],
  },
  positions: [{ value: String, label: String, _id: false }],
  notes: { type: String },
  tags: [{ value: String, label: String, _id: false }],
  data: {
    type: Schema.Types.Mixed, // Allows any structure for the data field
    default: {},
  },
  link: String,
  sent: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },

  sentAt: {
    type: Date,
  },
});

const Case: Model<ICasesAndResponses> = mongoose.model<ICasesAndResponses>("Case", CaseSchema);

export default Case;
