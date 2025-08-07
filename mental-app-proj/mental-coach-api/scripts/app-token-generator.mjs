import crypto from "crypto";

const generateAppToken = () => {
  return crypto.randomBytes(32).toString("hex");
};

const token = generateAppToken();
console.log("New App Token:", token);
