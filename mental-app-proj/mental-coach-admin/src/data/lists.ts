type League = {
  label: string;
  value: string;
};

export const ISRAELY_LEAGUES: League[] = [
  { label: "ליגת העל", value: "ligat_ha_al" },
  { label: "ליגה לאומית", value: "liga_leumit" },
  { label: "ליגה א' צפון", value: "liga_a_north" },
  { label: "ליגה א' דרום", value: "liga_a_south" },
  { label: "ליגה ב' צפון א'", value: "liga_b_north_a" },
  { label: "ליגה ב' צפון ב'", value: "liga_b_north_b" },
  { label: "ליגה ב' דרום א'", value: "liga_b_south_a" },
  { label: "ליגה ב' דרום ב'", value: "liga_b_south_b" },
  { label: "ליגה ג'", value: "liga_gimel" },
];

export const EXERCISE_TYPES = [
  { value: 'questionnaire', label: 'שאלון' },
  { value: 'text_input', label: 'קלט טקסט' },
  { value: 'video_reflection', label: 'רפלקציה על וידאו' },
  { value: 'action_plan', label: 'תוכנית פעולה' },
  { value: 'mental_visualization', label: 'ויזואליזציה מנטלית' },
  { value: 'content_slider', label: 'סליידר תוכן' },
  { value: 'file_upload', label: 'העלאת קובץ' },
  { value: 'signature', label: 'חתימה דיגיטלית' },
];

export const COUNTRIES_LIST = [
  { label: "ישראל", value: "israel" },
  { label: "אנגליה", value: "england" },
  { label: "הולנד", value: "netherlands" },
];

export const SCORE_BRANCH_LIST = [
  { label: "נצחונות", value: "wins" },
  { label: "עונות", value: "seasons" },
  { label: "הסמכות", value: "certificates" },
];

export const SCORE_TRIGGER_LIST = [
  { label: "הרשמה", value: "registration" },
  { label: "הזנת משחק עתידי", value: "enterFutureGame" },
  { label: "הכנה למשחק", value: "gamePreparation" },
  { label: "הכנה לאימון", value: "trainingPreparation" },
  { label: "פעולה שבוצעה במשחק", value: "actionPerformedInGame" },
  { label: "פתיחת אפליקציה", value: "appLaunch" },
  { label: "השלמת פרופיל", value: "profileCompletion" },
  { label: "האזנה לשיעור", value: "lessonListening" },
  { label: "שיתוף חבר באאפליקציה", value: "shareWithFriendInApp" },
  { label: "משוב מנטלי אחרי משחק", value: "mentalFeedbackAfterGame" },
];

export const SUBSCRIPTION_TYPE_LIST = [
  {
    label: "בסיסי",
    value: "basic",
  },
  {
    label: "מתקדם",
    value: "advanced",
  },
  {
    label: "פרימיום",
    value: "premium",
  },
];

export const LEGS = [
  { label: "שמאל", value: "left" },
  { label: "ימין", value: "right" },
  // {label:'שניהם' , value:''},
];

export const POSITIONS = [
  { value: "GK", label: "שוער" }, // Goalkeeper
  { value: "CB", label: "בלם" }, // Center Back
  { value: "LB", label: "מגן שמאלי" }, // Left Back
  { value: "RB", label: "מגן ימני" }, // Right Back
  { value: "LWB", label: "מגן שמאלי תוקף" }, // Left Wing Back
  { value: "RWB", label: "מגן ימני תוקף" }, // Right Wing Back
  { value: "CDM", label: "קשר אחורי" }, // Central Defensive Midfielder
  { value: "CM", label: "קשר מרכזי" }, // Central Midfielder
  { value: "CAM", label: "קשר התקפי" }, // Central Attacking Midfielder
  { value: "LM", label: "קשר שמאלי" }, // Left Midfielder
  { value: "RM", label: "קשר ימני" }, // Right Midfielder
  { value: "LW", label: "קיצוני שמאלי" }, // Left Winger
  { value: "RW", label: "קיצוני ימני" }, // Right Winger
  { value: "CF", label: "חלוץ מרכזי" }, // Center Forward
  { value: "ST", label: "חלוץ" }, // Striker
];
