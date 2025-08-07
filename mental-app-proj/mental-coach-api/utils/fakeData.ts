const fakeUsers = [
  {
    username: "david123",
    email: "david@example.com",
    password: "securePass123",
    profile: {
      name: "דוד לוי",
      age: 24,
      position: "שוער",
      bio: "אוהב לשחק כדורגל מגיל קטן",
      strongLeg: "ימין",
      currentStatus: [
        { title: "שחקן פעיל", rating: 4 },
        { title: "מצב כושר", rating: 5 },
      ],
    },
    totalScore: 10,
    seasons: 2,
    encouragementSystemMessages: [
      {
        title: "משחק מצוין!",
        description: "הובלת את הקבוצה לניצחון חשוב!",
        date: new Date(),
        confirmed: true,
      },
    ],
    certificationsNumber: 1,
    totalWins: 5,
  },
  {
    username: "moshe_k",
    email: "moshe.k@example.com",
    password: "passMoshe123",
    profile: {
      name: "משה כהן",
      age: 28,
      position: "חלוץ",
      bio: "שחקן מהיר וחזק מאוד",
      strongLeg: "שמאל",
      currentStatus: [
        { title: "שחקן פעיל", rating: 3 },
        { title: "מצב כושר", rating: 4 },
      ],
    },
    totalScore: 20,
    seasons: 3,
    encouragementSystemMessages: [
      {
        title: "שחקן מצטיין",
        description: "כובש שערים באופן קבוע.",
        date: new Date(),
        confirmed: true,
      },
    ],
    certificationsNumber: 3,
    totalWins: 12,
  },
  {
    username: "yael_g",
    email: "yael.g@example.com",
    password: "yael12345",
    profile: {
      name: "יעל גרין",
      age: 22,
      position: "מגנה שמאלית",
      bio: "הגנה חזקה ויכולת מסירה מעולה",
      strongLeg: "שמאל",
      currentStatus: [
        { title: "שחקנית פעילה", rating: 5 },
        { title: "מצב כושר", rating: 4 },
      ],
    },
    totalScore: 8,
    seasons: 1,
    encouragementSystemMessages: [
      {
        title: "הופעה מעולה!",
        description: "שחקת מצוין מול קבוצה חזקה!",
        date: new Date(),
        confirmed: true,
      },
    ],
    certificationsNumber: 2,
    totalWins: 6,
  },
  {
    username: "avi_h",
    email: "avi.h@example.com",
    password: "avi_h456",
    profile: {
      name: "אבי הלוי",
      age: 30,
      position: "קשר מרכזי",
      bio: "מנהיג את הקבוצה במגרש",
      strongLeg: "ימין",
      currentStatus: [
        { title: "שחקן ותיק", rating: 4 },
        { title: "מצב כושר", rating: 3 },
      ],
    },
    totalScore: 15,
    seasons: 5,
    encouragementSystemMessages: [
      {
        title: "שחקן יציב",
        description: "מנהיגות ודבקות במטרה!",
        date: new Date(),
        confirmed: true,
      },
    ],
    certificationsNumber: 4,
    totalWins: 20,
  },
  // Add 6 more user objects following this format...
];

export default fakeUsers;
