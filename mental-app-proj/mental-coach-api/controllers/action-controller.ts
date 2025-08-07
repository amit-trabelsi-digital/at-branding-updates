import { Request, Response, NextFunction } from "express";
import Action from "../models/action-model";

// Create a action
export const createAction = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const action = new Action(req.body);
    const savedAction = await action.save();
    res.status(201).json(savedAction);
  } catch (error) {
    next(error);
  }
};

// Get all actions
export const getAllActions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { position } = req.query;
    let actions;

    if (position) {
      actions = await Action.find({
        positions: {
          $elemMatch: {
            value: new RegExp(position as string, "i"),
          },
        },
      }).select("-positions -measurable -__v -createdAt -updatedAt");
    } else {
      actions = await Action.find();
    }

    res.status(200).json(actions);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get a action by ID
export const getActionById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const action = await Action.findById(id);

    if (!action) {
      res.status(404).json({ message: "Action not found" });
      return;
    }

    res.status(200).json(action);
  } catch (error) {
    next(error);
  }
};

// Update a action
export const updateAction = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedAction = await Action.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedAction) {
      res.status(404).json({ message: "Action not found" });
      return;
    }

    res.status(200).json(updatedAction);
  } catch (error) {
    next(error);
  }
};

// Delete a action
export const deleteAction = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedAction = await Action.findByIdAndDelete(id);

    if (!deletedAction) {
      res.status(404).json({ message: "Action not found" });
      return;
    }

    res.status(200).json({ message: "Action deleted successfully" });
  } catch (error) {
    next(error);
  }
};
