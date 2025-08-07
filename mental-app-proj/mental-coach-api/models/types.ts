import { Schema } from "mongoose";

export interface ITeam {
  name: string;
  city: string;
  hex1: string;
  hex2: string;
  hex3: string;
  users: Schema.Types.ObjectId[]; // Array of player names or IDs
  league: Schema.Types.ObjectId;
}

export interface ILeague extends Document {
  _id: string;
  name: string;
  country: string;
  season: string;
  numberOfTeams: number;
  teams: ITeam[];
  matches: IMatch[];
  createdAt: Date;
  updatedAt: Date;
}

export interface IMatch {
  date: Date;
  homeTeam: Schema.Types.ObjectId;
  awayTeam: Schema.Types.ObjectId;
  score?: {
    home: number;
    away: number;
  };
  location: string;
  reported: boolean;
}

export interface IScore extends Document {
  scoreTrigger: string; // Name of the score
  points: number;
  notes: string;
  limit: number;
  branch: string;
}
