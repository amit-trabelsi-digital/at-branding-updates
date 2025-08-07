import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "./user-model.mjs";

import { promptUserEmail } from "./utils.mjs";

// Reset profile completion flags for all users or a specific user
async function resetProfileStatus(email) {
  try {
    const filter = email ? { email: email } : {};

    const result = await User.updateMany(filter, {
      $set: {
        setProfileComplete: false,
        setGoalAndProfileComplete: false,
      },
    });

    console.log(`Updated ${result.modifiedCount} user(s)`);
    console.log(`Matched ${result.matchedCount} user(s)`);

    return result;
  } catch (error) {
    console.error("Error resetting profile status:", error);
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
    // Get user email from command line
    const email = await promptUserEmail("User's email ( emply will remove matan.d@amit.team)");

    if (email && email.trim() !== "") {
      console.log(`Resetting profile completion status for user with email: ${email}`);
      await resetProfileStatus(email);
    } else {
      await resetProfileStatus("matan.d@amit.team");

      console.log("reset for  matan.d@amit.team user");
    }
    console.log("Operation completed successfully");
  } catch (error) {
    console.error("Operation failed:", error);
  } finally {
    await mongoose.disconnect();
    console.log("Disconnected from MongoDB");
  }
}

// Run the script
main();
