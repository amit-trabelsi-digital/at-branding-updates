import express from "express";
import { userGuardWithDB, userGuardForLogin } from "./../middlewares/appAuthMiddleware";
import { signUp, generalLogin, login, checkAuthMethod } from "./../controllers/auth-controller";
const router = express.Router();

router.post("/signup", signUp);
router.post("/general-login", generalLogin);
router.get("/login", userGuardForLogin, login);
router.post("/check-auth-method", checkAuthMethod);

export default router;
