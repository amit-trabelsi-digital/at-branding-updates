import mongoose, { Schema, Document } from "mongoose";

// interface IStatus {
//   title: string; // Title of the status (e.g., "Planning", "Completed")
//   positions: { value: string; label: string }[];
//   measurable: boolean; // ניתן למדידה
//   description: string; // Details about the status
//   rating: number; // Rating from 1 to 5
// }

export interface IGoal extends Document {
  goalName: string; // Name of the goal
  positions: { value: string; label: string; _id: false }[];
  measurable: boolean;
  trainingCompatible: boolean;
}

const GoalSchema: Schema = new Schema(
  {
    goalName: { type: String, required: true },
    positions: [{ value: String, label: String, _id: false }],
    measurable: { type: Boolean, default: false },
    trainingCompatible: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const Goal = mongoose.model<IGoal>("Goal", GoalSchema);

export default Goal;
