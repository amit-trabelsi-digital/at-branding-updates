import mongoose, { Schema } from "mongoose";
import { IScore } from "./types";

const ActionSchema: Schema = new Schema(
  {
    scoreTrigger: { type: String, required: true },
    points: { type: Number, default: 0 },
    notes: { type: String },
    limit: { type: Number },
    branch: { type: String },
  },
  { timestamps: true }
);

const Score = mongoose.model<IScore>("Score", ActionSchema);

export default Score;
