import { Request, Response, NextFunction } from "express";
import Subscription from "../models/subscripion-model";
import mongoose from "mongoose";
import User from "../models/user-model";
import AppError from "../utils/appError";

// Create a new subscription
export const createSubscription = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = res.app.locals.user._id;

    if (!userId) {
      return next(new AppError("User ID not found", 400));
    }

    // Create a new subscription with userId
    const newSubscription = new Subscription({ ...req.body, userId });
    const savedSubscription = await newSubscription.save();

    // Update the user document with the subscriptionId
    await User.findByIdAndUpdate(userId, { subscriptionId: savedSubscription._id });

    res.status(201).json(savedSubscription);
  } catch (error: any) {
    next(new AppError(error.message, 400));
  }
};

// Get a subscription by ID
export const getSubscriptionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return next(new AppError("Invalid subscription ID", 400));
    }
    const subscription = await Subscription.findById(req.params.id);
    if (!subscription) {
      return next(new AppError("Subscription not found", 404));
    }
    res.status(200).json(subscription);
  } catch (error: any) {
    next(new AppError(error.message, 500));
  }
};

// Get all subscriptions
export const getAllSubscriptions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const subscriptions = await Subscription.find();
    res.status(200).json(subscriptions);
  } catch (error: any) {
    next(new AppError(error.message, 500));
  }
};

// Update a subscription by ID
export const updateSubscriptionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return next(new AppError("Invalid subscription ID", 400));
    }
    const updatedSubscription = await Subscription.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedSubscription) {
      return next(new AppError("Subscription not found", 404));
    }
    res.status(200).json(updatedSubscription);
  } catch (error: any) {
    next(new AppError(error.message, 400));
  }
};

// Delete a subscription by ID
export const deleteSubscriptionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return next(new AppError("Invalid subscription ID", 400));
    }
    const deletedSubscription = await Subscription.findByIdAndDelete(req.params.id);
    if (!deletedSubscription) {
      return next(new AppError("Subscription not found", 404));
    }
    res.status(200).json({ message: "Subscription deleted successfully" });
  } catch (error: any) {
    next(new AppError(error.message, 500));
  }
};
