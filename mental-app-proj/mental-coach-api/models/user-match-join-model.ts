// NOT IN USE FOR WHILE ... 2021-09-01

import mongoose, { Schema, Document, Model } from "mongoose";

export interface IUserMatchJoin extends Document {
  user: mongoose.Types.ObjectId; // Reference to the User
  match: mongoose.Types.ObjectId; // Reference to the Match
  actions: [{ actionName: String; performed: Boolean }];
  goal: { goalName: String; performed: Boolean };
  personalityGroup: { title: String; tag: String };
}

const UserMatchActionSchema: Schema = new Schema<IUserMatchJoin>(
  {
    user: { type: Schema.Types.ObjectId, ref: "User", required: true },
    match: { type: Schema.Types.ObjectId, ref: "Match", required: true },
    actions: [{ actionName: String, performed: { type: Boolean, default: false, _id: false } }],
    goal: { goalName: String, performed: { type: Boolean, default: false, _id: false } },
    personalityGroup: { title: String, tag: String },
  },
  { timestamps: true }
);

const UserMatchAction: Model<IUserMatchJoin> = mongoose.model<IUserMatchJoin>("UserMatchAction", UserMatchActionSchema);
export default UserMatchAction;
