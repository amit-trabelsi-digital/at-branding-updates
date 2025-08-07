import mongoose from "mongoose";
import { promptUserEmail, connectToDb } from "./utils.mjs";
import User from "./user-model.mjs";

await import("dotenv").then((dotenv) => dotenv.config());

// Clear matches and trainings for all users or specific users
async function clearUserData(email) {
  try {
    const filter = email ? { email: email } : {};

    const result = await User.updateMany(filter, { $set: { matches: [], trainings: [] } });

    console.log(`Updated ${result.modifiedCount} user(s)`);
    console.log(`Matched ${result.matchedCount} user(s)`);

    return result;
  } catch (error) {
    console.error("Error clearing user data:", error);
    throw error;
  }
}

// Main function
async function main() {
  await import("dotenv").then((dotenv) => dotenv.config());

  await mongoose.connect(process.env.MONGO_URI_DEV, {
    dbName: process.env.DB_NAME,
  });
  console.log("Connected to mongoose".green);
  try {
    // Get userId from command line arguments if provided
    const email = await promptUserEmail("User's email to update");

    if (email && email.trim() !== "") {
      console.log(`Clearing data for user with email: ${email}`);
      await clearUserData(email);
    } else {
      await clearUserData("matan.d@amit.team");
      console.log("Deleting all user data");
    }

    console.log("Operation completed successfully".green);
  } catch (error) {
    console.error("Operation failed:", error);
  } finally {
    await mongoose.disconnect();
    console.log("Disconnected from MongoDB");
  }
}

// Run the script
main();
