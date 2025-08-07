import { Document, Schema, model } from "mongoose";

// Define the interface for GeneralData
export interface IGeneralData extends Document {
  [key: string]: any;
  tags: { label: string; value: string }[];
  personallityTags: { label: string; value: string }[];
  personallityGroups: { title: string; tags: { label: string; value: string }[] }[];
  profileMedia: {};
}

// Define the schema for the GeneralData model
const generalDataSchema: Schema = new Schema<IGeneralData>(
  {
    tags: [
      {
        label: { type: String, required: true },
        value: { type: String, required: true },
        _id: false, // Disable the automatic _id field for subdocuments
      },
    ],
    personallityTags: [
      {
        label: { type: String, required: true },
        value: { type: String, required: true },
        _id: false, // Disable the automatic _id field for subdocuments
      },
    ],
    profileAudioFile: { fileType: String, fileData: { name: String, path: String } },
    goalsAudioFile: { fileType: String, fileData: { name: String, path: String } },
  },
  { timestamps: true }
);

// Create and export the GeneralData model
const GeneralData = model<IGeneralData>("GeneralData", generalDataSchema);
export default GeneralData;
