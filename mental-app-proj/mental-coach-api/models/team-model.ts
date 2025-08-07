import mongoose, { Model, Schema } from "mongoose";
import { ITeam } from "./types";

const TeamSchema: Schema = new Schema<ITeam>(
  {
    name: { type: String },
    city: { type: String },
    hex1: { type: String },
    hex2: { type: String },
    hex3: { type: String },
    league: { type: Schema.Types.ObjectId, ref: "League" },
    users: [{ type: Schema.Types.ObjectId, ref: "User" }],
  },
  { timestamps: true }
);

const Team: Model<ITeam> = mongoose.model<ITeam>("Team", TeamSchema);

export { Team, TeamSchema };
