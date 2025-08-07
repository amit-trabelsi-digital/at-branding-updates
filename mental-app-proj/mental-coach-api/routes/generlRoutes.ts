import express from "express";
import {
  createPersonnalityGroup,
  createTag,
  deleteTag,
  getGeneralDataForUser,
  getTags,
  updateGeneralData,
} from "../controllers/general-controller";
import { adminGuard } from "../middlewares/appAuthMiddleware";
import Email from "../utils/react-email";
import User from "../models/user-model";

const router = express.Router();

router.get("/data", getGeneralDataForUser);
router.get("/email-test", async (req, res) => {
  try {
    await new Email({ email: "matan.d@amit.team", name: "hello" }).sendWelcome();

    res.status(200).send("Email sent successfully!");
  } catch (error) {
    res.status(500).send("Error sending email.");
    console.log(error);
  }
});
router.get("/email-test2", async (req, res) => {
  try {
    const user = await User.findOne({ email: "matan.d@amit.team" }).select("matches");
    const match = user && user.matches ? user.matches[0] : null;

    if (!match) {
      res.status(404).send("Match not found for the user.");
      return;
    }

    await new Email({ email: "matan.d@amit.team", name: user?.firstName, match: match }).sendOpenMatch();

    res.status(200).send("Email sent successfully!");
  } catch (error) {
    res.status(500).send("Error sending email.");
    console.log(error);
  }
});

router.use(adminGuard);
router.get("/", getTags);
router.post("/", createTag);
router.put("/", updateGeneralData);
router.post("/group", createPersonnalityGroup);
router.delete("/removetag", deleteTag);

export default router;
