import mongoose, { Schema, Document } from "mongoose";

export interface Subscription extends Document {
  userId: mongoose.Schema.Types.ObjectId;
  productId: string;
  transactionId: string;
  status: string;
  subscriptionType: string;
  currencyCode?: string;
  verificationData: string;
  source: string;
}

const SubscriptionSchema: Schema = new Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: "User" },
    productId: { type: String, required: true },
    transactionId: { type: String, required: true },
    status: { type: String, required: true },
    subscriptionType: { type: String, required: true },
    currencyCode: { type: String },
    verificationData: { type: String },
    source: { type: String, required: true },
  },
  { timestamps: true },
);

const Subscription = mongoose.model<Subscription>("Subscription", SubscriptionSchema);
export default Subscription;
