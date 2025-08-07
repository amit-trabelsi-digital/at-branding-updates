import { NextFunction, Response, Request } from "express";
import AppError from "../utils/appError";
import EitanMessage from "../models/eitan-message-model";

export const createEitanMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const eitanMessage = new EitanMessage(req.body);
    const result = await eitanMessage.save();
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

export const getAllEitanMessages = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pushMessages = await EitanMessage.find();
    res.status(200).json(pushMessages);
  } catch (err) {
    next(err);
  }
};

export const getEitanMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const eitanMessage = await EitanMessage.findById(id);
    if (!eitanMessage) {
      return next(new AppError("EitanMessage not found", 404));
    }
    res.status(200).json(eitanMessage);
  } catch (err) {
    next(err);
  }
};

export const updateEitanMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedEitanMessage = await EitanMessage.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedEitanMessage) {
      return next(new AppError("EitanMessage not found", 404));
    }

    res.status(200).json(updatedEitanMessage);
  } catch (error) {
    next(error);
  }
};

export const deleteEitanMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deleteEitanMessage = await EitanMessage.findByIdAndDelete(id);

    if (!deleteEitanMessage) {
      return next(new AppError("EitanMessage not found", 404));
    }

    res.status(200).json({ message: "EitanMessage deleted successfully" });
  } catch (error) {
    next(error);
  }
};
