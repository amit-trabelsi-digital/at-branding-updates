import mongoose, { Schema, Document } from "mongoose";

export interface IPersonallityGroup extends Document {
  title: string;
  tags: { label: string; value: string }[];
}

const PersonallityGroupSchema: Schema = new Schema(
  {
    title: String,
    tags: [{ label: String, value: String }],
  },
  { timestamps: true }
);

const PersonalityGroup = mongoose.model<IPersonallityGroup>("PersonalityGroup", PersonallityGroupSchema);

export default PersonalityGroup;
