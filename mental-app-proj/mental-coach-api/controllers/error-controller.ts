import AppError from "./../utils/appError"; // assuming you have a TypeScript export here
import ErrorModel from "./../models/error.model";
import { Request, Response, NextFunction } from "express";
import "colors";

// Function to handle CastError
const handleCastError = (err: any): AppError => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400);
};

// Function to handle duplicate fields error
const handleDuplicateFieldsDB = (err: any): AppError => {
  const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
  const message = `Duplicated field value: ${value}. Please use another value.`;
  return new AppError(message, 400);
};

// Function to handle validation errors
const handleValidationErrorDB = (err: any): AppError => {
  // eslint-disable-next-line node/no-unsupported-features/es-builtins
  const errors = Object.values(err.errors).map((el: any) => el.message);

  const message = `Invalid input data. ${errors.join(". ")}`;
  return new AppError(message, 400);
};

// Function for sending error in development environment
const sendErrorForDev = (err: AppError, res: Response): void => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,
    message: err.message,
    stack: err.stack,
  });
};

// Function for sending error in production environment
const sendErrorProd = async (err: AppError, res: Response): Promise<void> => {
  if (err.isOperational) {
    res.status(err.statusCode).json({
      status: err.status,
      message: err.message,
    });
  } else {
    console.log("GLOBAL ERROR");
    console.error("ERROR", err);
    await ErrorModel.create({
      errorType: "error",
      errorMsg: err.message,
    });
    res.status(500).json({
      status: "Error",
      message: "Something went wrong",
    });
  }
};

// Main error handler middleware
export default (err: any, req: Request, res: Response, next: NextFunction): void => {
  console.log(`\n[ERROR HANDLER] Error caught:`.red);
  console.log(`URL: ${req.method} ${req.originalUrl}`.red);
  console.log(`Error Name: ${err.name}`.red);
  console.log(`Error Message: ${err.message}`.red);
  console.log(`Error Stack:`.red, err.stack);
  
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "Error";

  if (process.env.NODE_ENV === "development") {
    sendErrorForDev(err, res);
  } else if (process.env.NODE_ENV === "production") {
    let error = { ...err };

    if (error.name === "CastError") error = handleCastError(error);
    if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    if (error.name === "ValidationError") error = handleValidationErrorDB(error);

    sendErrorProd(error, res);
  }
};
