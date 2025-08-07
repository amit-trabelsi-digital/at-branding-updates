import PeopleAltIcon from "@mui/icons-material/PeopleAlt";
import SettingsIcon from "@mui/icons-material/Settings";
import Diversity3Icon from "@mui/icons-material/Diversity3";
import UpcomingIcon from "@mui/icons-material/Upcoming";
import ThreePIcon from "@mui/icons-material/ThreeP";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import SportsSoccerTwoToneIcon from "@mui/icons-material/SportsSoccerTwoTone";
import FollowTheSignsIcon from "@mui/icons-material/FollowTheSigns";
import ConnectWithoutContactIcon from "@mui/icons-material/ConnectWithoutContact";
import KeyboardDoubleArrowRightIcon from "@mui/icons-material/KeyboardDoubleArrowRight";
import StyleIcon from "@mui/icons-material/Style";
import ScoreboardIcon from "@mui/icons-material/Scoreboard";
import GroupIcon from "@mui/icons-material/Group";
import CameraIcon from "@mui/icons-material/Camera";
import FitnessCenterIcon from "@mui/icons-material/FitnessCenter";

export const drawerWidth = 240;

// --- Environment Configuration ---
const environments = {
  local: 'http://localhost:3000',
  dev: 'https://dev-srv.eitanazaria.co.il',
  prod: 'https://app-srv.eitanazaria.co.il',
};

type Environment = keyof typeof environments;

let currentEnv: Environment = "local"; // Default environment

// 1. Detect deployment environment via a generic variable
// In your hosting service (e.g., Railway), set VITE_ENVIRONMENT_NAME to 'production' for production builds,
// and another value for preview/staging builds. For Railway, you can set its value to ${RAILWAY_ENVIRONMENT_NAME}.
const deployEnv = import.meta.env.VITE_ENVIRONMENT_NAME;
if (deployEnv) {
  if (deployEnv === "production") {
    currentEnv = "prod";
  } else {
    // Any other environment (like previews) will be considered 'dev'
    currentEnv = "dev";
  }
}
// 2. Fallback to VITE_APP_ENV for other setups (like local vite config)
else if (import.meta.env.VITE_APP_ENV === "production") {
  currentEnv = "prod";
} else if (import.meta.env.VITE_APP_ENV === "development") {
  currentEnv = "dev";
}

// 3. Allow local override via localStorage for debugging purposes
const localOverride = localStorage.getItem("app_environment") as Environment | null;
if (localOverride && environments[localOverride]) {
  currentEnv = localOverride;
}

const apiBaseUrl = environments[currentEnv];

// פונקציות עזר לשינוי סביבה מהקונסול
window.setAppEnvironment = (env: Environment) => {
  if (environments[env]) {
    localStorage.setItem('app_environment', env);
    console.log(`✅ הסביבה שונתה ל: ${env}. רענן את הדף כדי להחיל שינויים.`);
    window.location.reload();
  } else {
    console.error(`❌ סביבה לא חוקית: ${env}. הסביבות הזמינות הן: local, dev, prod`);
  }
};

window.clearAppEnvironment = () => {
  localStorage.removeItem('app_environment');
  console.log('✅ הגדרות הסביבה נוקו. רענן את הדף כדי לחזור להגדרת ברירת המחדל.');
  window.location.reload();
};


export const appConfig = {
  apiBaseUrl: apiBaseUrl,
  environment: currentEnv,
  supportEmail: 'support@mental-coach.co.il',
  supportPhone: '03-1234567',
};
// --- End of Environment Configuration ---


export const adminRoutes = [
  {
    title: "משתמשים",
    Icon: PeopleAltIcon,
    href: "/dashboard/users",
  },
  {
    title: "מקרים ותגובות",
    Icon: ConnectWithoutContactIcon,
    href: "/dashboard/case-and-reactions",
  },
  {
    title: "מטרות",
    Icon: FollowTheSignsIcon,
    href: "/dashboard/goals",
  },
  {
    title: "פעולות",
    Icon: KeyboardDoubleArrowRightIcon,
    href: "/dashboard/actions",
  },
  {
    title: "הודעות מאיתן",
    Icon: ThreePIcon,
    href: "/dashboard/eitan-messages",
  },
  {
    title: "הודעות פוש",
    Icon: UpcomingIcon,
    href: "/dashboard/push-messages",
  },
  {
    title: "ליגות",
    Icon: EmojiEventsIcon,
    href: "/dashboard/leagues",
  },
  {
    title: "קבוצות",
    Icon: Diversity3Icon,
    href: "/dashboard/teams",
  },
  {
    title: "משחקים",
    Icon: SportsSoccerTwoToneIcon,
    href: "/dashboard/matches",
  },
  {
    title: "ניקוד על פעולות",
    Icon: ScoreboardIcon,
    href: "/dashboard/scores",
  },
  {
    title: "תגיות",
    Icon: StyleIcon,
    href: "/dashboard/tags",
  },
  {
    title: "משפחות אופי",
    Icon: GroupIcon,
    href: "/dashboard/personallity-group",
  },
  {
    title: "תוכניות אימון",
    Icon: FitnessCenterIcon,
    href: "/dashboard/training-programs",
  },
  {
    title: "הגדרות",
    Icon: SettingsIcon,
    href: "/dashboard/settings",
  },
  {
    title: "מדיה כללית",
    Icon: CameraIcon,
    href: "/dashboard/general-media",
  },
];

export const imagesConfig = {
  bigImageMaxSize: { width: 1000, height: 1000 },
  smallImageMaxSize: { width: 400, height: 600 },
};
