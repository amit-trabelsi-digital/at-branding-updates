import { Button, Typography, TextField, Stack, Paper, Box, Tab, Tabs } from "@mui/material";
import { signInWithPopup, GoogleAuthProvider, signInWithEmailAndPassword, RecaptchaVerifier, signInWithPhoneNumber } from "firebase/auth";
import { useSnackbar } from "notistack";
import { fireAuth } from "../utils/firebase";
import { useState } from "react";
import { LoadingButton } from "@mui/lab";
import GoogleIcon from '@mui/icons-material/Google';
import EmailIcon from '@mui/icons-material/Email';
import PhoneIcon from '@mui/icons-material/Phone';
import { appFetch } from "../services/fetch";

const provider = new GoogleAuthProvider();

declare global {
  interface Window {
    recaptchaVerifier: any;
  }
}

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`auth-tabpanel-${index}`}
      aria-labelledby={`auth-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}

export const LoginPage = () => {
  const { enqueueSnackbar } = useSnackbar();
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(false);
  
  // Email & Password states
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  
  // Phone states
  const [phone, setPhone] = useState("");
  const [verificationCode, setVerificationCode] = useState("");
  const [confirmationResult, setConfirmationResult] = useState<any>(null);
  const [showVerificationInput, setShowVerificationInput] = useState(false);

  const checkIfAdmin = async (user: any) => {
    try {
      const tokenResult = await user.getIdTokenResult();
      
      // Check if user has admin role
      if (tokenResult.claims.role !== 0) {
        await fireAuth.signOut();
        throw new Error("משתמש זה אינו מנהל במערכת");
      }
      
      return true;
    } catch (error: any) {
      throw error;
    }
  };

  const signInWithGoogle = async () => {
    setLoading(true);
    try {
      const result = await signInWithPopup(fireAuth, provider);
      await checkIfAdmin(result.user);
      enqueueSnackbar("התחברת בהצלחה", { variant: "success" });
    } catch (error: any) {
      enqueueSnackbar(error.message || "שגיאה בהתחברות", { variant: "error" });
    } finally {
      setLoading(false);
    }
  };

  const signInWithEmail = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const result = await signInWithEmailAndPassword(fireAuth, email, password);
      await checkIfAdmin(result.user);
      enqueueSnackbar("התחברת בהצלחה", { variant: "success" });
    } catch (error: any) {
      enqueueSnackbar(error.message || "שגיאה בהתחברות", { variant: "error" });
    } finally {
      setLoading(false);
    }
  };

  const sendVerificationCode = async () => {
    setLoading(true);
    try {
      // First check if phone number is allowed to login with SMS
      const checkRes = await appFetch("/api/auth/check-auth-method", {
        method: "POST",
        body: JSON.stringify({ 
          email: phone + "@phone.local", // Temporary email format for phone users
          authMethod: "sms" 
        }),
      });
      
      if (!checkRes.ok) {
        const error = await checkRes.json();
        throw new Error(error.message || "משתמש זה אינו רשאי להתחבר עם SMS");
      }
      
      const phoneData = await checkRes.json();
      
      if (!phoneData.isAdmin) {
        throw new Error("משתמש זה אינו מנהל במערכת");
      }
      
      const internationalPhone = phoneData.firebasePhoneNumber;
      
      if (!internationalPhone) {
        throw new Error("לא נמצא מספר טלפון בפיירבייס עבור משתמש זה");
      }
      
      // Set up recaptcha
      if (!window.recaptchaVerifier) {
        window.recaptchaVerifier = new RecaptchaVerifier(fireAuth, 'recaptcha-container', {
          size: 'invisible',
          callback: () => {
            // reCAPTCHA solved
          }
        });
      }
      
      const confirmation = await signInWithPhoneNumber(fireAuth, internationalPhone, window.recaptchaVerifier);
      setConfirmationResult(confirmation);
      setShowVerificationInput(true);
      enqueueSnackbar("קוד אימות נשלח למספר הטלפון", { variant: "success" });
    } catch (error: any) {
      enqueueSnackbar(error.message || "שגיאה בשליחת קוד אימות", { variant: "error" });
    } finally {
      setLoading(false);
    }
  };

  const verifyCode = async () => {
    setLoading(true);
    try {
      const result = await confirmationResult.confirm(verificationCode);
      await checkIfAdmin(result.user);
      enqueueSnackbar("התחברת בהצלחה", { variant: "success" });
    } catch (error: any) {
      enqueueSnackbar(error.message || "קוד אימות שגוי", { variant: "error" });
    } finally {
      setLoading(false);
    }
  };
  return (
    <div
      style={{
        position: "fixed",
        top: "50%",
        left: "50%",
        transform: "translate(-50%,-50%)",
      }}
    >
      <Paper elevation={3} sx={{ p: 4, width: "400px", maxWidth: "90vw" }}>
        <Typography
          variant="h1"
          fontSize={50}
          fontWeight={800}
          color="secondary"
          sx={{ textAlign: "center", color: "black", mb: 4 }}
        >
          ניהול - המאמן המנטלי
        </Typography>
        
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabValue} onChange={(_, newValue) => setTabValue(newValue)} centered>
            <Tab label="Google" icon={<GoogleIcon />} />
            <Tab label="אימייל" icon={<EmailIcon />} />
            <Tab label="SMS" icon={<PhoneIcon />} />
          </Tabs>
        </Box>

        <TabPanel value={tabValue} index={0}>
          <LoadingButton
            fullWidth
            variant="outlined"
            onClick={signInWithGoogle}
            loading={loading}
            startIcon={<GoogleIcon />}
            size="large"
          >
            התחברות עם Google
          </LoadingButton>
        </TabPanel>

        <TabPanel value={tabValue} index={1}>
          <form onSubmit={signInWithEmail}>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="אימייל"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                dir="ltr"
              />
              <TextField
                fullWidth
                label="סיסמה"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                dir="ltr"
              />
              <LoadingButton
                fullWidth
                type="submit"
                variant="contained"
                loading={loading}
                size="large"
              >
                התחברות
              </LoadingButton>
            </Stack>
          </form>
        </TabPanel>

        <TabPanel value={tabValue} index={2}>
          <Stack spacing={2}>
            {!showVerificationInput ? (
              <>
                <TextField
                  fullWidth
                  label="מספר טלפון"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="050-1234567"
                  required
                  dir="ltr"
                  helperText="הזן מספר טלפון ישראלי"
                />
                <LoadingButton
                  fullWidth
                  variant="contained"
                  onClick={sendVerificationCode}
                  loading={loading}
                  size="large"
                >
                  שלח קוד אימות
                </LoadingButton>
              </>
            ) : (
              <>
                <TextField
                  fullWidth
                  label="קוד אימות"
                  value={verificationCode}
                  onChange={(e) => setVerificationCode(e.target.value)}
                  placeholder="123456"
                  required
                  dir="ltr"
                  helperText="הזן את הקוד שקיבלת ב-SMS"
                />
                <LoadingButton
                  fullWidth
                  variant="contained"
                  onClick={verifyCode}
                  loading={loading}
                  size="large"
                >
                  אמת קוד
                </LoadingButton>
                <Button
                  fullWidth
                  variant="text"
                  onClick={() => {
                    setShowVerificationInput(false);
                    setVerificationCode("");
                  }}
                >
                  שלח קוד חדש
                </Button>
              </>
            )}
          </Stack>
        </TabPanel>

        <Typography variant="caption" sx={{ mt: 3, display: "block", textAlign: "center", color: "text.secondary" }}>
          * רק משתמשים עם הרשאות ניהול יכולים להתחבר
        </Typography>
      </Paper>
      <div id="recaptcha-container"></div>
    </div>
  );
};

export default LoginPage;
