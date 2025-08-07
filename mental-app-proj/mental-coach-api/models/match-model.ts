import mongoose, { Model, Schema } from "mongoose";
import { IMatch } from "./types";

const MatchSchema: Schema = new Schema<IMatch>(
  {
    date: { type: Date, required: true },
    homeTeam: { type: Schema.Types.ObjectId, ref: "Team" },
    awayTeam: { type: Schema.Types.ObjectId, ref: "Team" },
    score: {
      home: { type: Number, default: 0 },
      away: { type: Number, default: 0 },
    },
    location: { type: String },
    reported: { type: Boolean, default: false },
  },
  {
    timestamps: true, // Adds createdAt and updatedAt fields
  }
);

// export only schema without model
const Match: Model<IMatch> = mongoose.model<IMatch>("Match", MatchSchema);

export default Match;
