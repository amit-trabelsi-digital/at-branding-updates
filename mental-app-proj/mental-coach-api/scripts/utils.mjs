import inquirer from "inquirer";
import mongoose from "mongoose";

// if (process.env.NODE_ENV === 'development') await import('dotenv').then((dotenv) => dotenv.config());

export const connectToDb = async () => {
  await import("dotenv").then((dotenv) => dotenv.config());

  await mongoose.connect(process.env.MONGO_URI_DEV, {
    dbName: process.env.DB_NAME,
  });
  console.log("Connected to mongoose".green);
};

export const promptUserEmail = async (message) => {
  let { email } = await inquirer.prompt({
    name: "email",
    type: "input",
    message,
  });
  return email;
};
