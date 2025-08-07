import { NextFunction, Response, Request } from "express";
import { Team } from "../models/team-model";
import AppError from "./../utils/appError";

export const createTeam = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = req.body;

    const existTeam = await Team.findOne({ name: req.body.name });

    if (existTeam) {
      return next(new AppError("שם הקבוצה כבר קיים", 409));
    }

    const team = new Team(data);

    const result = await team.save();
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

export const getAllTeams = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const leagues = await Team.find();
    res.status(200).json(leagues);
  } catch (err) {
    next(err);
  }
};

export const getTeam = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const team = await Team.findById(id);
    if (!team) {
      return next(new AppError("Team not found", 404));
    }
    res.status(200).json(team);
  } catch (err) {
    next(err);
  }
};

export const updateTeam = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedTeam = await Team.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedTeam) {
      return next(new AppError("Team not found", 404));
    }

    res.status(200).json(updatedTeam);
  } catch (error) {
    next(error);
  }
};

export const deleteTeam = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedTeam = await Team.findByIdAndDelete(id);

    if (!deletedTeam) {
      return next(new AppError("Team not found", 404));
    }

    res.status(200).json({ message: "Team deleted successfully" });
  } catch (error) {
    next(error);
  }
};
