import { Request, Response, NextFunction } from "express";
import UserMatchAction, { IUserMatchJoin } from "../models/user-match-join-model";
import AppError from "../utils/appError";
import catchAsync from "../utils/catchAsync";
import User from "../models/user-model";
import mongoose from "mongoose";

// Create new match join
export const createMatchJoin = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const user = await User.findOne({ uid: res.app.locals.uid }).select("_id").lean();

  if (!user) {
    return next(new AppError("User not found", 404));
  }

  const userMatchJoin = await UserMatchAction.create({
    user: user._id,
    match: req.body.match,
    personalityGroup: req.body.personalityGroup,
    actions: req.body.actions,
    goal: req.body.goal,
  });

  res.status(201).json({
    status: "success",
    // data: matchJoin,
    data: userMatchJoin,
  });
});

// Get all match joins
export const getAllMatchJoins = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const matchJoins = await UserMatchAction.find().populate("user").populate("match").populate("personalityGroup");

  res.status(200).json(matchJoins);
});

// Get match join by ID
export const getMatchJoin = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const matchJoin = await UserMatchAction.findById(req.params.id).populate("user").populate("match").populate("personalityGroup");

  if (!matchJoin) {
    return next(new AppError("No match join found with that ID", 404));
  }

  res.status(200).json(matchJoin);
});

// Update match join
export const updateMatchJoin = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const matchJoin = await UserMatchAction.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true,
  });

  if (!matchJoin) {
    return next(new AppError("No match join found with that ID", 404));
  }

  res.status(200).json(matchJoin);
});

// Delete match join
export const deleteMatchJoin = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const matchJoin = await UserMatchAction.findByIdAndDelete(req.params.id);

  if (!matchJoin) {
    return next(new AppError("No match join found with that ID", 404));
  }

  res.status(204).json({
    status: "success",
    data: null,
  });
});

// Get match joins by user ID
export const getAllMatchJoinsByUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log(res.app.locals.user._id);
    const matchJoins = await UserMatchAction.find({ user: res.app.locals.user._id })
      .populate("match")
      .populate({
        path: "match",
        populate: [{ path: "homeTeam" }, { path: "awayTeam" }],
      })
      .lean();

    res.status(200).json(matchJoins);
  } catch (error) {
    console.log(error);
  }
};

// Get match joins by match ID
export const getMatchJoinsByMatch = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const matchJoins = await UserMatchAction.find({ match: req.params.matchId }).populate("user").populate("personalityGroup");

  res.status(200).json({
    status: "success",
    results: matchJoins.length,
    data: matchJoins,
  });
});
