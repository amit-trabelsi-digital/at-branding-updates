import { NextFunction, Response, Request } from "express";
import League from "../models/league-model";
import AppError from "./../utils/appError";
import { Team } from "../models/team-model";
import { ILeague } from "../models/types";

export const createLeague = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log(req.body);

    const { teams, season, country, name } = req.body;

    const existLeague = await League.findOne({ name: name });

    if (existLeague) {
      return next(new AppError("שם הליגה כבר קיים", 409));
    }

    const setTeamData = teams.map((item: { value: string }) => item.value);
    const league = await League.create({ name, country, season, teams: setTeamData });

    await Promise.all(
      setTeamData.map(async (teamId: string) => {
        const updatedTeam = await Team.findByIdAndUpdate(teamId, { league: league._id }, { new: true, runValidators: true });

        if (!updatedTeam) {
          console.warn(`Team with ID ${teamId} not found`);
        }
      })
    );

    res.status(201).json(league);
  } catch (err) {
    console.log(err);
    next(err);
  }
};

export const getAllLeagues = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const leagues = await League.find().populate("teams");
    res.status(200).json(leagues);
  } catch (err) {
    next(err);
  }
};

export const getLeague = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const league = await League.findById(id);
    if (!league) {
      return next(new AppError("League not found", 404));
    }
    res.status(200).json(league);
  } catch (err) {
    next(err);
  }
};

export const updateLeague = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const { teams, season, country, name } = req.body;

    const existLeague: ILeague | null = await League.findOne({ name: name });

    if (existLeague && existLeague._id.toString() !== id) {
      return next(new AppError("שם הליגה כבר קיים", 409));
    }

    const setTeamData = teams.map((item: { value: string }) => item.value);

    const updatedLeague = await League.findByIdAndUpdate(
      id,
      { name, country, season, teams: setTeamData },
      { new: true, runValidators: true }
    );

    if (!updatedLeague) {
      return next(new AppError("League not found", 404));
    }

    // Update each team with the league ID
    await Promise.all(
      setTeamData.map(async (teamId: string) => {
        const updatedTeam = await Team.findByIdAndUpdate(teamId, { league: updatedLeague._id }, { new: true, runValidators: true });

        if (!updatedTeam) {
          console.warn(`Team with ID ${teamId} not found`);
        }
      })
    );

    res.status(200).json(updatedLeague);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const deleteLeague = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedGame = await League.findByIdAndDelete(id);

    if (!deletedGame) {
      return next(new AppError("League not found", 404));
    }

    res.status(200).json({ message: "League deleted successfully" });
  } catch (error) {
    next(error);
  }
};
