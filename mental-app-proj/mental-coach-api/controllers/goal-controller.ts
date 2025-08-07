import { Request, Response, NextFunction } from "express";
import Goal from "../models/goal-model";

// Create a goal
export const createGoal = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const goal = new Goal(req.body);
    const savedGoal = await goal.save();
    res.status(201).json(savedGoal);
  } catch (error) {
    next(error);
  }
};

// Get all goals
export const getAllGoals = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { position } = req.query;
    let goals;

    if (position) {
      goals = await Goal.find({
        positions: {
          $elemMatch: {
            value: new RegExp(position as string, "i"),
          },
        },
      }).select("-positions -measurable -__v -createdAt -updatedAt");

      console.log(goals);
    } else {
      goals = await Goal.find();
    }

    res.status(200).json(goals);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get a goal by ID
export const getGoalById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const goal = await Goal.findById(id);

    if (!goal) {
      res.status(404).json({ message: "Goal not found" });
      return;
    }

    res.status(200).json(goal);
  } catch (error) {
    next(error);
  }
};

// Update a goal
export const updateGoal = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedGoal = await Goal.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedGoal) {
      res.status(404).json({ message: "Goal not found" });
      return;
    }

    res.status(200).json(updatedGoal);
  } catch (error) {
    next(error);
  }
};

// Delete a goal
export const deleteGoal = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedGoal = await Goal.findByIdAndDelete(id);

    if (!deletedGoal) {
      res.status(404).json({ message: "Goal not found" });
      return;
    }

    res.status(200).json({ message: "Goal deleted successfully" });
  } catch (error) {
    next(error);
  }
};
