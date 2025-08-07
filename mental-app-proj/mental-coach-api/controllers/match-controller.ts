import { Request, Response, NextFunction } from "express";
import Match from "../models/match-model"; // Adjust the path if necessary
import mongoose from "mongoose";
import User from "../models/user-model";
import { Team } from "../models/team-model";
import { getSeasonByDate } from "../utils/helpers";
const { ObjectId } = mongoose.Types;
// Create a match

const isValidObjectId = (id: any): boolean => {
  if (!id || typeof id !== "string") {
    return false;
  }

  // Check if it's a valid MongoDB ObjectId (24-character hex string)
  return /^[0-9a-fA-F]{24}$/.test(id);
};

export const createMatch = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { score, awayTeam, homeTeam, date, isUserPickedTime } = req.body;

    // Check if the user is an admin
    if (res.app.locals.role == 0) {
      console.log("Admin user creating match");
      const match = new Match({
        score,
        awayTeam: new ObjectId(awayTeam as string),
        homeTeam: new ObjectId(homeTeam as string),
        date,
      });

      const savedMatch = await match.save();
      res.status(201).json(savedMatch);
      return;
    }

    // ===================== If its not pure team creating (admin) =====================

    let homeTeamForDb;
    let awayTeamForDb;

    // אם היוזר משתמש בקבוצה קיימת ייבא מהמסד נתונים
    if (isValidObjectId(homeTeam)) {
      const _homeTeam = await Team.findById(homeTeam).select("_id name");
      homeTeamForDb = { _id: _homeTeam?._id, name: _homeTeam?.name };
    } else {
      homeTeamForDb = { name: homeTeam };
    }

    if (isValidObjectId(awayTeam)) {
      const _awayTeam = await Team.findById(awayTeam).select("_id name");
      awayTeamForDb = { _id: _awayTeam?._id, name: _awayTeam?.name };
    } else {
      awayTeamForDb = { name: awayTeam };
    }

    // order the teams in the same order as the request

    const hasOpenEvent = await User.exists({
      uid: res.app.locals.uid, // Match this specific user
      $or: [{ "matches.isOpen": true }, { "training.isOpen": true }],
    });

    console.log("HAS OPEN EVENT ", hasOpenEvent);
    console.log("HAS OPEN EVENT ", res.app.locals.uid);
    const hasOpen = hasOpenEvent !== null;

    const matchForUserAddept = {
      date,
      score,
      isOpen: !hasOpen,
      homeTeam: homeTeamForDb,
      awayTeam: awayTeamForDb,
      season: getSeasonByDate(),
      isUserPickedTime,
    };

    const updatedUser = await User.findOneAndUpdate({ uid: res.app.locals.uid }, { $push: { matches: matchForUserAddept } }, { new: true });

    // Get the newly added match (last one in the array)
    const newlyAddedMatch = updatedUser?.matches ? updatedUser.matches[updatedUser.matches.length - 1] : undefined;

    console.log("NWE MATCH ", newlyAddedMatch);
    res.status(201).json(newlyAddedMatch || matchForUserAddept);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const createTraining = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { date, isUserPickedTime } = req.body;

    const hasOpenEvent = await User.exists({
      uid: res.app.locals.uid, // Match this specific user
      $or: [{ "matches.isOpen": true }, { "training.isOpen": true }],
    });
    const hasOpen = hasOpenEvent !== null;

    const trainingForUserAddept = {
      date,
      season: getSeasonByDate(),
      isOpen: !hasOpen,
      isUserPickedTime,
    };

    const updatedUser = await User.findOneAndUpdate(
      { uid: res.app.locals.uid },
      { $push: { trainings: trainingForUserAddept } },
      { new: true },
    );

    const newlyAddedTraining = updatedUser?.trainings ? updatedUser.trainings[updatedUser.trainings.length - 1] : undefined;

    console.log("new training  ", newlyAddedTraining);
    res.status(201).json(newlyAddedTraining || trainingForUserAddept);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get all matches
export const getAllMatchs = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const matches = await Match.find({}).populate("homeTeam", "name").populate("awayTeam", "name");

    res.status(200).json(matches);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get a match by ID
export const getMatchById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const match = await Match.findById(id);

    if (!match) {
      res.status(404).json({ message: "Match not found" });
      return;
    }

    res.status(200).json(match);
  } catch (error) {
    next(error);
  }
};

// Update a match
export const updateMatch = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedMatch = await Match.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedMatch) {
      res.status(404).json({ message: "Match not found" });
      return;
    }

    res.status(200).json(updatedMatch);
  } catch (error) {
    next(error);
  }
};

// Delete a match
export const deleteMatch = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedMatch = await Match.findByIdAndDelete(id);

    if (!deletedMatch) {
      res.status(404).json({ message: "Match not found" });
      return;
    }

    res.status(200).json({ message: "Match deleted successfully" });
  } catch (error) {
    next(error);
  }
};
