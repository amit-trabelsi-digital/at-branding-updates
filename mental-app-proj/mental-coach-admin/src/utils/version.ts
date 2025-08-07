// גרסת הממשק - מתעדכן עם כל build חדש
export const ADMIN_VERSION = "1.1.0";

// סביבת הרצה
export const getEnvironment = () => {
  return import.meta.env.MODE || 'production';
};

// צבע לפי סביבה
export const getEnvironmentColor = () => {
  const env = getEnvironment();
  switch (env) {
    case 'development':
      return 'warning';
    case 'production':
      return 'success';
    case 'test':
      return 'info';
    default:
      return 'default';
  }
};

// פרטי Build
export const BUILD_INFO = {
  version: "1.1.0",
  build: "2025.08.06.139",
  buildDate: "2025-08-06T18:39:57.000Z"
};
