import mongoose, { Schema, Document } from "mongoose";

export interface IAction extends Document {
  actionName: string; // Name of the action
  positions: { value: string; label: string; _id: false }[];
  measurable: boolean;
  trainingCompatible: boolean;
}

const ActionSchema: Schema = new Schema(
  {
    actionName: { type: String, required: true },
    positions: [{ value: String, label: String, _id: false }],
    measurable: { type: Boolean, default: false },
    trainingCompatible: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const Action = mongoose.model<IAction>("Action", ActionSchema);

export default Action;
