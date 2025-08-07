import mongoose, { Schema, Document, Model } from "mongoose";
// Define TypeScript interfaces for League and related entities

export interface ILeague extends Document {
  name: string;
  country: string;
  season: string;
  numberOfTeams: number;
  teams: Schema.Types.ObjectId[];
  matches: Schema.Types.ObjectId[];
  createdAt: Date;
  updatedAt: Date;
}

// Define Schemas for embedded documents

// Define the main League schema
const LeagueSchema: Schema = new Schema<ILeague>(
  {
    name: { type: String, required: true },
    country: { type: String, required: true },
    season: { type: String },
    numberOfTeams: { type: Number },
    teams: [{ type: Schema.Types.ObjectId, ref: "Team" }],
    matches: [{ type: Schema.Types.ObjectId, ref: "Match" }],
  },
  {
    timestamps: true, // Automatically creates createdAt and updatedAt
  }
);

LeagueSchema.pre<ILeague>("save", function (next) {
  this.numberOfTeams = this.teams.length;
  next();
});

// Create and export the model
const League: Model<ILeague> = mongoose.model<ILeague>("League", LeagueSchema);

export default League;
