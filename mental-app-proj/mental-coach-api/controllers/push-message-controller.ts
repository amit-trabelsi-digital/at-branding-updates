import { NextFunction, Response, Request } from "express";
import AppError from "../utils/appError";
import PushMessage from "../models/push-message-model";
import firebase from "firebase-admin";
import User from "../models/user-model";

export const createPushMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log(req.body);
    const pushMessage = new PushMessage(req.body);
    const result = await pushMessage.save();
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

export const getAllPushMessages = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pushMessages = await PushMessage.find();
    res.status(200).json(pushMessages);
  } catch (err) {
    next(err);
  }
};

export const getPushMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const pushMessage = await PushMessage.findById(id);
    if (!pushMessage) {
      return next(new AppError("PushMessage not found", 404));
    }
    res.status(200).json(pushMessage);
  } catch (err) {
    next(err);
  }
};

export const updatePushMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedPushMessage = await PushMessage.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedPushMessage) {
      return next(new AppError("PushMessage not found", 404));
    }

    res.status(200).json(updatedPushMessage);
  } catch (error) {
    next(error);
  }
};

export const deletePushMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletePushMessage = await PushMessage.findByIdAndDelete(id);

    if (!deletePushMessage) {
      return next(new AppError("PushMessage not found", 404));
    }

    res.status(200).json({ message: "PushMessage deleted successfully" });
  } catch (error) {
    next(error);
  }
};

// update fcm token endpoint
export const updateToken = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { fcmToken } = req.body;

    console.log(fcmToken);
    console.log(req.body);
    const updateToken = await User.findOneAndUpdate({ uid: res.app.locals.uid }, { fcmToken: fcmToken });
    console.log(res.app.locals.uid);
    // fcmToken
    if (!updateToken) {
      return next(new AppError("Token not found", 404));
    }

    res.status(200).json({ message: "Token updated successfully" });
  } catch (error) {
    next(error);
  }
};

export const pushMessageForOneUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { token, title, body } = req.body;

  if (!token || !title || !body) {
    return next(new AppError("Missing required fields: token, title, body", 400));
  }

  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: token, // ה-FCM Token של המשתמש
  };

  try {
    const response = await firebase.messaging().send(message);
    res.status(200).send({ success: true, messageId: response });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).send({ error: "Failed to send message" });
  }
};

// Endpoint לשליחת הודעה לכל המשתמשים דרך Topic
export const pushMessageForUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { title, body } = req.body;

  if (!title || !body) {
    return next(new AppError("Missing required fields: token, title, body", 400));
  }

  const message = {
    notification: {
      title: title,
      body: body,
    },
    topic: "all", // Topic שכל המשתמשים רשומים אליו
  };

  try {
    const response = await firebase.messaging().send(message);
    res.status(200).send({ success: true, messageId: response });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).send({ error: "Failed to send message" });
  }
};

export const pushMessageForMultipleUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { tokens, title, body } = req.body;

  if (!tokens || !Array.isArray(tokens) || !title || !body) {
    return next(new AppError("Missing or invalid fields: tokens (array), title, body", 400));
  }

  const message = {
    notification: {
      title: title,
      body: body,
    },
    tokens: tokens, // מערך של FCM Tokens
  };

  try {
    const response = await firebase.messaging().sendEachForMulticast(message);
    res.status(200).send({ success: true, response });
  } catch (error) {
    console.error("Error sending multicast message:", error);
    res.status(500).send({ error: "Failed to send message" });
  }
};
