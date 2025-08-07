import mongoose, { Document, Schema } from 'mongoose';

interface IError extends Document {
  errorType: string;
  errorMsg: string;
}

const errorSchema = new Schema<IError>(
  {
    errorType: { type: String, required: true },
    errorMsg: { type: String, required: true },
  },
  { timestamps: true },
);

const ErrorModel = mongoose.model<IError>('Error', errorSchema);

export default ErrorModel;
