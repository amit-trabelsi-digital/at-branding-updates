import { getAuth } from "firebase-admin/auth";

import { promptUserEmail, connectToDb } from "./utils.mjs";
import "colors";
import inquirer from "inquirer";

// IT IS CREATING A USER RECORD IN MONGO DB, BY FIREBASE USER EMAIL.

main();

async function main() {
  await import("dotenv").then((dotenv) => dotenv.config());
  await import("./_firebase.mjs");
  try {
    console.log("Creating a new ADMIN-user".bgYellow);
    const email = await promptUserEmail("User's email to create");
    const { password } = await inquirer.prompt({
      name: "password",
      type: "input",
      message: "type a password",
    });
    const { role } = await inquirer.prompt({
      name: "role",
      type: "input",
      message: "role",
      default: 0,
    });
    await createFirebaseUser(email, password, role);
  } catch (err) {
    console.error(err);
  } finally {
    process.exit();
  }
}

async function createFirebaseUser(email, password, role) {
  console.log(`creating firebase user`.yellow);
  const user = await getAuth().createUser({ email, password });
  console.log(`Uid = ${user.uid}`.green);
  await getAuth().setCustomUserClaims(user.uid, { role: role });
  console.log(`setCustomUserClaims = role: 0`.green);
  return user.uid;
}

async function createUserInDB({ email, uid, role }) {
  await connectToDb();
  console.log(`creating db user...`.yellow);
  await User.create({ email, uid, role });
  console.log(`User created!`.green);
}
