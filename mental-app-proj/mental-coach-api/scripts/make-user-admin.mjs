import { getAuth } from "firebase-admin/auth";
import { promptUserEmail } from "./utils.mjs";
import "colors";

main();

async function main() {
  try {
    await import("dotenv").then((dotenv) => dotenv.config());
    await import("./_firebase.mjs");

    const email = await promptUserEmail("User's email to make admin");
    await makeUserAdmin(email);
  } catch (err) {
    console.error(err);
  } finally {
    process.exit();
  }
}

async function makeUserAdmin(email) {
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, { role: 0 });
  console.log(`User is Admin!`.green);
}
