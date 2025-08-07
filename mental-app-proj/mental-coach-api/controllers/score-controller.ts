import { Request, Response, NextFunction } from "express";
import Score from "../models/score-model";

// Create a score
export const createScore = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const score = new Score(req.body);
    const savedScore = await score.save();
    res.status(201).json(savedScore);
  } catch (error) {
    next(error);
  }
};

// Get all scores
export const getAllScores = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const scores = await Score.find();
    res.status(200).json(scores);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get a score by ID
export const getScoreById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const score = await Score.findById(id);

    if (!score) {
      res.status(404).json({ message: "Score not found" });
      return;
    }

    res.status(200).json(score);
  } catch (error) {
    next(error);
  }
};

// Update a score
export const updateScore = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedScore = await Score.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedScore) {
      res.status(404).json({ message: "Score not found" });
      return;
    }

    res.status(200).json(updatedScore);
  } catch (error) {
    next(error);
  }
};

// Delete a score
export const deleteScore = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedScore = await Score.findByIdAndDelete(id);

    if (!deletedScore) {
      res.status(404).json({ message: "Score not found" });
      return;
    }

    res.status(200).json({ message: "Score deleted successfully" });
  } catch (error) {
    next(error);
  }
};
