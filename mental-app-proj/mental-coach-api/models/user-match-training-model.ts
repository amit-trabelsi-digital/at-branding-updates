import { Schema } from "mongoose";

export interface IUserMatch {
  _id: Schema.Types.ObjectId;
  date: Date;
  homeTeam: { _id: Schema.Types.ObjectId; name: string };
  awayTeam: { _id: Schema.Types.ObjectId; name: string };
  score: {
    home: number;
    away: number;
  };
  actions: { actionName: string; performed: number }[];
  goal: { goalName: string; performed: number };
  matchResult: "win" | "lose" | "draw";
  personalityGroup: { title: string; tag: string; performed: number };
  matchId: Schema.Types.ObjectId;
  season: string;
  isOpen: boolean;
  investigation: boolean;
  isHomeMatch: boolean;
  note: string;
  isUserPickedTime: boolean;
  visible: boolean;
}
export interface IUserTraining {
  _id: Schema.Types.ObjectId;
  date: Date;
  isUserPickedTime: boolean;
  actions: { actionName: string; performed: number }[];
  goal: { goalName: string; performed: number };
  personalityGroup: { title: string; tag: string; performed: number };
  season: string;
  isOpen: boolean;
  investigation: boolean;
  note: string;
  visible: boolean;
}
