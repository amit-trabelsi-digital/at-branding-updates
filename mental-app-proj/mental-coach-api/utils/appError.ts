class AppError extends Error {
  public status: string;
  public statusCode: number;
  public isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);

    // Set the statusCode and status based on the code
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;

    // Preserve the stack trace
    Error.captureStackTrace(this, this.constructor);
  }
}

export default AppError;
