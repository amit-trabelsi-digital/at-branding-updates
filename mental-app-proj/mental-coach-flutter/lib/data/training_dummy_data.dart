// נתוני דמה לקורסים ואימונים - מעודכן לפי מבנה השרת

import 'package:mental_coach_flutter_firebase/models/training_models.dart';

final Map<String, dynamic> trainingProgramData = {
  "_id": "6863d549020e131bf1185575",
  "title": "מנטליות של ווינר I - המעטפת המנטלית",
  "description":
      "תוכנית אימון מנטלי מקיפה לכדורגלנים צעירים ומקצועיים. התוכנית מלמדת כלים מנטליים מתקדמים להתמודדות עם לחץ, בניית ביטחון עצמי, ופיתוח מנטליות מנצחת. 24 שיעורים עם תרגילים אינטראקטיביים ומשימות אישיות המבוססים על שיטתו של איתן בן אליהו.",
  "instructor": "67dc0618e3fc076b756177f8",
  "category": "mental",
  "type": "course",
  "difficulty": "intermediate",
  "totalLessons": 24,
  "estimatedDuration": 720,
  "objectives": [
    "פיתוח חזון אישי וקביעת מטרות ברורות ככדורגלן",
    "בניית מנטליות מנצחת והתמודדות עם לחץ",
    "למידת טכניקות הכנה מנטלית למשחקים",
    "התמודדות עם פחדים ודאגות מדעת אחרים",
    "פיתוח כלים להתגברות על טעויות והפסדים"
  ],
  "prerequisites": [],
  "targetAudience": "כדורגלנים בגילאי 13-18, שחקנים חובבים ומקצועיים",
  "totalEnrolled": 0,
  "averageRating": 0,
  "accessRules": {
    "subscriptionTypes": ["advanced", "premium"],
    "requireSequential": true,
    "specificUsers": []
  },
  "isPublished": true,
  "publishedAt": "2025-01-15T10:00:00.000Z",
  "createdBy": "67dc0618e3fc076b756177f8",
  "lastModifiedBy": "67dc0618e3fc076b756177f8",
  "createdAt": "2025-01-15T10:00:00.000Z",
  "updatedAt": "2025-06-20T14:30:00.000Z"
};

final List<Lesson> dummyLessons = [
  // שיעור 0 - שריקת פתיחה
  Lesson(
    id: '6863d54a020e131bf1185577',
    trainingProgramId: '6863d549020e131bf1185575',
    lessonNumber: 0,
    title: 'שריקת פתיחה – איך להוציא את המקסימום מהתכנית ומהפוטנציאל שלך!',
    shortTitle: 'אימון 0',
    duration: 15,
    order: 1,
    content: LessonContent(
      primaryContent:
          'אלופים יקרים, את כל חוברת העבודה המנטלית הכנסנו לכם לאפליקציה כאן בתרגול דיגיטלי כדי שיהיה לכם יותר נוח, כל החומרים, התריגילים והמשימות המנטליות שיש בחוברת עליה איתן מדבר בכל אימון מחכים לכם מתחת לכל וידאו, וכל אימון ישמר לכם ולא יאבד כך שההצלחה שלכם תמיד אתכם',
      additionalContent:
          'אני רוצה לומר שזה יתרון שאין לכם חוברת פיסית, כי חוברת יכולה להעלם, להאבד, להיגמר, לעומת האפליקציה שהיא אתכם כל הזמן, מי שבכל זאת רוצה להזמין אליו את החוברת היתה יכול לעשות זאת בהזמנה מכאן',
      structure: 'מבוא טקסטואלי',
      notes: 'שיעור מבוא חשוב המסביר איך להשתמש בתוכנית בצורה אפקטיבית',
      highlights: [],
    ),
    media: LessonMedia(
      videoDuration: 0.0,
      audioFiles: [],
      documents: [
        Document(
          name: 'מדריך שימוש בתוכנית',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/usage_guide.pdf',
        ),
      ],
    ),
    accessRules: AccessRules(
      subscriptionTypes: ['basic', 'advanced', 'premium'],
      unlockConditions: UnlockConditions(
        minimumProgressPercentage: 0,
        requirePreviousCompletion: false,
      ),
    ),
    contentStatus: ContentStatus(
      isPublished: true,
      isVisible: true,
      isLocked: false,
    ),
    scoring: Scoring(
      passingScore: 80,
      maxScore: 100,
      minimumCompletionTime: 10,
    ),
    createdAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
  ),

  // שיעור 1 - הכדורגלן העתידי
  Lesson(
    id: '6863d54a020e131bf1185579',
    trainingProgramId: '6863d549020e131bf1185575',
    lessonNumber: 1,
    title: 'הכדורגלן העתידי שאני רוצה להיות',
    shortTitle: 'אימון 1',
    duration: 35,
    order: 2,
    content: LessonContent(
      primaryContent:
          'בשיעור הזה נקבע יחד את החזון האישי שלך ככדורגלן. נלמד איך להגדיר מטרות ברורות, לדמיין את העתיד הרצוי, וליצור תוכנית פעולה להגשמת החלומות. זהו הבסיס למסע המנטלי שלך.',
      additionalContent:
          'החזון האישי הוא המצפן שלך. הוא מכוון אותך בכל החלטה ונותן לך כוח בזמנים קשים.',
      structure: 'וידאו מרכזי',
      notes: 'שיעור מפתח לקביעת כיוון וחזון אישי',
      highlights: ['קביעת חזון', 'הגדרת מטרות'],
    ),
    media: LessonMedia(
      videoUrl: 'https://vimeo.com/936269657',
      videoType: 'mp4',
      videoDuration: 22.0,
      audioFiles: [
        AudioFile(
          name: 'מדיטציה מודרכת - חזון עתידי',
          url:
              'https://storage.googleapis.com/mental-training/audio/future_vision_meditation.mp3',
          duration: 600,
        )
      ],
      documents: [
        Document(
          name: 'תרגיל בניית חזון אישי',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/personal_vision_exercise.pdf',
        ),
      ],
    ),
    accessRules: AccessRules(
      subscriptionTypes: ['advanced', 'premium'],
      unlockConditions: UnlockConditions(
        minimumProgressPercentage: 80,
        requirePreviousCompletion: true,
      ),
    ),
    contentStatus: ContentStatus(
      isPublished: true,
      isVisible: true,
      isLocked: false,
    ),
    scoring: Scoring(
      passingScore: 80,
      maxScore: 100,
      minimumCompletionTime: 30,
    ),
    createdAt: DateTime.parse('2025-01-20T11:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-20T11:00:00.000Z'),
  ),

  // שיעור 2 - עונת הפריצה
  Lesson(
    id: '6863d54a020e131bf118557b',
    trainingProgramId: '6863d549020e131bf1185575',
    lessonNumber: 2,
    title: 'מתכננים את עונת הפריצה שלך',
    shortTitle: 'אימון 2',
    duration: 40,
    order: 3,
    content: LessonContent(
      primaryContent:
          'עונת הפריצה היא העונה שבה הכל משתנה לטובה. נלמד איך לתכנן אותה בצורה חכמה, איך לקבוע ציפיות ריאליסטיות, ואיך להכין את עצמנו מנטלית להצלחה.',
      additionalContent:
          'תכנון נכון הוא המפתח להצלחה. בלי תוכנית, אנחנו רק מקווים שדברים יקרו.',
      structure: 'וידאו מרכזי',
      notes: 'תכנון אסטרטגי לעונה מנצחת',
      highlights: [],
    ),
    media: LessonMedia(
      videoUrl: 'https://vimeo.com/936269142',
      videoType: 'mp4',
      videoDuration: 25.0,
      audioFiles: [],
      documents: [
        Document(
          name: 'תוכנית עונה אישית',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/season_plan_template.pdf',
        ),
      ],
    ),
    accessRules: AccessRules(
      subscriptionTypes: ['advanced', 'premium'],
      unlockConditions: UnlockConditions(
        minimumProgressPercentage: 80,
        requirePreviousCompletion: true,
      ),
    ),
    contentStatus: ContentStatus(
      isPublished: true,
      isVisible: true,
      isLocked: false,
    ),
    scoring: Scoring(
      passingScore: 80,
      maxScore: 100,
      minimumCompletionTime: 35,
    ),
    createdAt: DateTime.parse('2025-01-25T14:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-25T14:00:00.000Z'),
  ),

  // שיעור 3 - המשחק המושלם
  Lesson(
    id: '6863d54a020e131bf118557d',
    trainingProgramId: '6863d549020e131bf1185575',
    lessonNumber: 3,
    title: 'לתכנן את המשחק המושלם',
    shortTitle: 'אימון 3',
    duration: 30,
    order: 4,
    content: LessonContent(
      primaryContent:
          'המשחק המושלם לא קורה במקרה. הוא תוצאה של הכנה מנטלית מדוקדקת. נלמד איך לדמיין את המשחק מראש, איך להתכונן לכל תרחיש, ואיך להגיע למגרש במצב מנטלי אופטימלי.',
      additionalContent:
          'ההכנה המנטלית טובה מהכשירות הפיזית. היא מה שעושה את הההבדל ברגעי האמת.',
      structure: 'וידאו',
      notes: 'הכנה מנטלית למשחק מושלם',
      highlights: [],
    ),
    media: LessonMedia(
      videoUrl: 'https://vimeo.com/936268312',
      videoType: 'mp4',
      videoDuration: 20.0,
      audioFiles: [
        AudioFile(
          name: 'הדמיית משחק מושלם',
          url:
              'https://storage.googleapis.com/mental-training/audio/perfect_game_visualization.mp3',
          duration: 480,
        )
      ],
      documents: [
        Document(
          name: 'צ\'קליסט הכנה למשחק',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/game_preparation_checklist.pdf',
        ),
      ],
    ),
    accessRules: AccessRules(
      subscriptionTypes: ['advanced', 'premium'],
      unlockConditions: UnlockConditions(
        minimumProgressPercentage: 80,
        requirePreviousCompletion: true,
      ),
    ),
    contentStatus: ContentStatus(
      isPublished: true,
      isVisible: true,
      isLocked: false,
    ),
    scoring: Scoring(
      passingScore: 80,
      maxScore: 100,
      minimumCompletionTime: 25,
    ),
    createdAt: DateTime.parse('2025-02-01T16:00:00.000Z'),
    updatedAt: DateTime.parse('2025-02-01T16:00:00.000Z'),
  ),

  // שיעור 14 - פחד מדעות אחרים (השיעור היחיד עם תוכן מלא)
  Lesson(
    id: '6863d54a020e131bf118558a',
    trainingProgramId: '6863d549020e131bf1185575',
    lessonNumber: 14,
    title: 'איך להפסיק לדאוג לגבי מה אחרים יחשבו עליך',
    shortTitle: 'אימון 14',
    duration: 45,
    order: 15,
    content: LessonContent(
      primaryContent:
          'הפחד ממה שאחרים יחשבו הוא אחד המעכבים הגדולים ביותר של כדורגלנים. הוא מונע מאיתנו לקחת סיכונים, לנסות דברים חדשים, ולהוציא את המקסימום מעצמנו במגרש. בשיעור הזה נלמד איך לשחרר את הפחד הזה ולהפוך אותו לכוח מניע במקום מעכב.',
      additionalContent:
          'חשוב לזכור: הדעות של אחרים הן לרוב השלכה של הפחדים שלהם עצמם. כדורגלן שמשחק בחופשיות ולא מפחד מטעויות הוא מקור השראה לכולם.',
      structure: 'וידאו + תרגילים אינטראקטיביים',
      notes: 'שיעור מפתח לפיתוח ביטחון עצמי ועמידה בלחץ חברתי',
      highlights: ['שחרור פחדים', 'ביטחון עצמי'],
    ),
    media: LessonMedia(
      videoUrl:
          'https://vimeo.com/936269657', // סרטון ברירת מחדל עד לקבלת הסרטון האמיתי
      videoType: 'mp4',
      videoDuration: 18.5,
      audioFiles: [
        AudioFile(
          name: 'מדיטציה מודרכת - שחרור פחדים',
          url:
              'https://storage.googleapis.com/mental-training/audio/meditation_fear_release.mp3',
          duration: 600,
        )
      ],
      documents: [
        Document(
          name: 'מדריך זיהוי מחשבות שליליות',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/negative_thoughts_guide.pdf',
        ),
        Document(
          name: 'רשימת אימוני ביטחון עצמי',
          type: 'pdf',
          url:
              'https://storage.googleapis.com/mental-training/documents/confidence_drills.pdf',
        ),
      ],
    ),
    accessRules: AccessRules(
      subscriptionTypes: ['premium'],
      unlockConditions: UnlockConditions(
        minimumProgressPercentage: 85,
        requirePreviousCompletion: true,
      ),
    ),
    contentStatus: ContentStatus(
      isPublished: true,
      isVisible: true,
      isLocked: false,
    ),
    scoring: Scoring(
      passingScore: 80,
      maxScore: 100,
      minimumCompletionTime: 90,
    ),
    createdAt: DateTime.parse('2025-02-10T10:00:00.000Z'),
    updatedAt: DateTime.parse('2025-06-15T14:00:00.000Z'),
  ),

  // שיעורים 4-13, 15-24 (ללא תוכן מפורט - בפיתוח)
  ...List.generate(20, (index) {
    final lessonNumbers = [
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24
    ];
    final lessonNumber = lessonNumbers[index];
    final lessonTitles = {
      4: 'אופי של ווינר',
      5: 'תכנית משחק לפי עמדה',
      6: 'להשאיר את הלחץ מחוץ לסגל',
      7: 'טקס שינה של מקצוען',
      8: 'יום המשחק הגיע. איזה כיף!',
      9: 'טקס חדר הלבשה',
      10: 'להתחיל את המשחק חזק עם ביטחון משריקת הפתיחה',
      11: 'איך להתגבר על טעויות תוך כדי משחק',
      12: 'להפוך את הפחד לחבר הכי טוב שלך',
      13: 'הניסיון הוא הניצחון',
      15: 'המטרה: לא להיות מושלם. גישה חדשה למשחק - מהנה. קלה. ומביאה תוצאות',
      16: 'לככב ברגע האמת ולא רק ליד החבר\'ה בשכונה - לשחק בלי לחשוב סוד ההרדמה המנטלית',
      17: 'הסוד לפוקוס בכל רגע במשחק',
      18: 'ווינר בכל תוצאה',
      19: 'חוק 24 השעות',
      20: 'איך לנתח את המשחק שלך כמו הספורטאים הטובים בעולם',
      21: 'איך להתאמן כדי להוציא מעצמך יותר במשחק הבא',
      22: 'איך לשחזר את המשחק הכי טוב שלי (שוב ושוב)',
      23: 'מנטליות של ווינר על המגרש - סיכום השיטה',
      24: 'מנטליות של ווינר על המגרש - סיכום השיטה',
    };

    return Lesson(
      id: 'lesson_${lessonNumber}_id',
      trainingProgramId: '6863d549020e131bf1185575',
      lessonNumber: lessonNumber,
      title: lessonTitles[lessonNumber] ?? 'שיעור $lessonNumber',
      shortTitle: 'אימון $lessonNumber',
      duration: 0,
      order: lessonNumber + 1,
      content: LessonContent(
        primaryContent: '',
        additionalContent: '',
        structure: 'וידאו',
        notes: 'תוכן בפיתוח',
        highlights: [],
      ),
      media: LessonMedia(
        videoDuration: 0.0,
        audioFiles: [],
        documents: [],
      ),
      accessRules: AccessRules(
        subscriptionTypes:
            lessonNumber >= 15 ? ['premium'] : ['advanced', 'premium'],
        unlockConditions: UnlockConditions(
          minimumProgressPercentage: 80,
          requirePreviousCompletion: true,
        ),
      ),
      contentStatus: ContentStatus(
        isPublished: false,
        isVisible: true,
        isLocked: true,
      ),
      scoring: Scoring(
        passingScore: 80,
        maxScore: 100,
        minimumCompletionTime:
            lessonNumber == 23 ? 50 : (20 + (lessonNumber % 4) * 5),
      ),
      createdAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
    );
  }),
];

final List<Map<String, dynamic>> exercisesData = [
  {
    "_id": "60f1234567890abcdef12501",
    "lessonId": "6863d54a020e131bf1185579",
    "exerciseId": "exercise_1",
    "type": "questionnaire",
    "title": "הגדרת החזון האישי",
    "description": "ענה על השאלות הבאות כדי להגדיר את החזון האישי שלך ככדורגלן",
    "settings": {"timeLimit": 900, "required": true, "points": 20, "order": 1},
    "content": {
      "questions": [
        {
          "id": "q1",
          "type": "text_area",
          "question": "איפה אתה רואה את עצמך ככדורגלן בעוד 3 שנים?",
          "placeholder":
              "תאר בפירות את המצב הרצוי - איזה קבוצה, איזה תפקיד, איזה רמה...",
          "minLength": 100,
          "required": true
        },
        {
          "id": "q2",
          "type": "multiple_choice",
          "question": "מה הכי חשוב לך בכדורגל?",
          "options": [
            "להיות הכדורגלן הטוב ביותר שאני יכול להיות",
            "לזכות באליפויות ותארים",
            "ליהנות מהמשחק ולהרגיש חופשי",
            "להשפיע חיובית על הקבוצה",
            "להגשים חלום ילדות"
          ],
          "required": true
        },
        {
          "id": "q3",
          "type": "scale",
          "question": "כמה אתה מוכן להשקיע כדי להגשים את החזון שלך?",
          "scale": {
            "min": 1,
            "max": 10,
            "labels": {
              "1": "רק בזמן הפנוי",
              "10": "אעשה הכל, זה בראש הסדר עדיפויות"
            }
          },
          "required": true
        }
      ]
    },
    "accessibility": {
      "hasAudioInstructions": true,
      "supportsDyslexia": true,
      "hasAlternativeFormat": false
    },
    "createdBy": "67dc0618e3fc076b756177f8",
    "lastModifiedBy": "67dc0618e3fc076b756177f8",
    "createdAt": "2025-01-20T11:30:00.000Z",
    "updatedAt": "2025-01-20T11:30:00.000Z"
  },
  {
    "_id": "60f1234567890abcdef12502",
    "lessonId": "6863d54a020e131bf1185579",
    "exerciseId": "exercise_2",
    "type": "action_plan",
    "title": "תוכנית פעולה לחזון",
    "description": "צור תוכנית פעולה מעשית להגשמת החזון שלך",
    "settings": {"timeLimit": 1200, "required": true, "points": 25, "order": 2},
    "content": {
      "fields": [
        {
          "name": "main_goal",
          "type": "text_input",
          "label": "המטרה הראשית שלי השנה:",
          "placeholder": "לדוגמה: להיכנס לקבוצה הראשית של המועדון",
          "required": true
        },
        {
          "name": "monthly_goals",
          "type": "text_area",
          "label": "3 מטרות לחודש הקרוב:",
          "placeholder":
              "1. לשפר את הריכוז באימונים\n2. לעבוד על כוח הבטן\n3. לבקש פידבק מהמאמן",
          "required": true
        },
        {
          "name": "daily_habits",
          "type": "text_area",
          "label": "הרגלים יומיים שאני מתחייב עליהם:",
          "placeholder":
              "לדוגמה: 20 דקות ג'אגלינג כל בוקר, מדיטציה 5 דקות לפני השינה...",
          "required": true
        },
        {
          "name": "obstacles",
          "type": "text_area",
          "label": "מכשולים שאני צופה ואיך אתמודד איתם:",
          "placeholder":
              "מכשול: עייפות מבית הספר. פתרון: להקדים את האימון ל-16:00",
          "required": false
        }
      ]
    },
    "accessibility": {
      "hasAudioInstructions": false,
      "supportsDyslexia": true,
      "hasAlternativeFormat": false
    },
    "createdBy": "67dc0618e3fc076b756177f8",
    "lastModifiedBy": "67dc0618e3fc076b756177f8",
    "createdAt": "2025-01-20T12:00:00.000Z",
    "updatedAt": "2025-01-20T12:00:00.000Z"
  }
];
