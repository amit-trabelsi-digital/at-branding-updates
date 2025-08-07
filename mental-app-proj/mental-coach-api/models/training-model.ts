import mongoose from 'mongoose';
const { Schema } = mongoose;

const TrainingProgramSchema = new Schema({
  title: { type: String, required: true },
  description: { type: String },
  exercises: [
    {
      name: String,
      duration: Number, // in minutes
      repetitions: Number,
    },
  ],
  assignedTo: [{ type: Schema.Types.ObjectId, ref: 'User' }],
});

module.exports = mongoose.model('TrainingProgram', TrainingProgramSchema);
