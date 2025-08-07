import mongoose, { Schema } from "mongoose";
// Define the schema
const UserSchema = new Schema({
  firstName: { type: String },
  lastName: { type: String },
  email: { type: String, required: true },
  phone: { type: String },
  password: { type: String, select: false },
  uid: { type: String },
  nickName: { type: String },
  age: { type: Number },
  position: { type: String },
  bio: { type: String },
  strongLeg: { type: String },
  currentStatus: [{ title: String, rating: { type: Number, min: 1, max: 5 } }],
  league: { type: Schema.Types.ObjectId, ref: "League" },
  team: { type: Schema.Types.ObjectId, ref: "Team" },
  playerNumber: { type: String },
  selectedTeamColor: { hex1: String, hex2: String, hex3: String },
  matches: [
    {
      date: { type: Date, required: true },
      homeTeam: { _id: Schema.Types.ObjectId, name: String },
      awayTeam: { _id: Schema.Types.ObjectId, name: String },
      score: {
        home: { type: Number, default: 0 },
        away: { type: Number, default: 0 },
      },
      actions: [{ actionName: String, performed: { type: Number, default: 0.0 } }],
      goal: { goalName: String, performed: { type: Number, default: 0.0 } },
      matchResult: { type: String, enum: ["win", "lose", "draw"] },
      personalityGroup: { title: String, tag: String, performed: { type: Number, default: 0.0 } },
      // Enforces "YYYY-YYYY" format
      season: {
        type: String,
        validate: {
          validator: function (v) {
            return /\d{4}-\d{4}/.test(v);
          },
          message: (props) => `${props.value} is not a valid season. Use "YYYY-YYYY"`,
        },
      },
      note: { type: String },
      isOpen: { type: Boolean, default: false },
      investigation: { type: Boolean, default: false },
      matchId: { type: Schema.Types.ObjectId, ref: "Match" },
      isHomeMatch: { type: Boolean, default: true },
    },
  ],
  trainings: [
    {
      date: { type: Date, required: true },
      actions: [{ actionName: String, performed: { type: Number, default: 0.0 } }],
      goal: { goalName: String, performed: { type: Number, default: 0.0 } },
      personalityGroup: { title: String, tag: String, performed: { type: Number, default: 0.0 } },
      season: {
        type: String,
        validate: {
          validator: function (v) {
            return /\d{4}-\d{4}/.test(v);
          },
          message: (props) => `${props.value} is not a valid season. Use "YYYY-YYYY"`,
        },
      },
      note: { type: String },
      isOpen: { type: Boolean, default: false },
      investigation: { type: Boolean, default: false },
    },
  ],
  subscriptionType: {
    type: String,
    enum: ["basic", "advanced", "premium"],
    default: "basic",
  },
  totalScore: { type: Number, default: 0 },
  seasons: { type: Number },
  encouragementSystemMessages: [
    {
      title: { type: String, required: true },
      description: { type: String, required: true },
      image: { type: String },
      date: { type: Date, required: true },
      confirmed: { type: Boolean, required: true },
    },
  ],
  certificationsNumber: { type: Number },
  totalWins: { type: Number, default: 0 },
  trainingProgram: { type: Schema.Types.ObjectId, ref: "TrainingProgram" },
  createdAt: { type: Date, default: Date.now },
  setProfileComplete: { type: Boolean, default: false },
  setGoalAndProfileComplete: { type: Boolean, default: false },
  theDream: { type: String },
  breakOutSeason: { type: String },
  role: { type: Number, select: false },
  fcmToken: { type: String },
});
// Export the model
const User = mongoose.model("User", UserSchema);
export default User;
