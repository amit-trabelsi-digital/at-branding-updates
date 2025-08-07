import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/screens/general/case_and_react.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_accordion.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_case_and_reaction_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_lesson_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_no_preparation_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_xl_match_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_xl_training_card.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/tabs/dream_and_breakout_season_widget.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_upcoming_match_card.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? selectedOptionIndex;
  bool state = false;
  // Version variable for app version tracking

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final dataProvider = Provider.of<DataProvider>(context, listen: true);

    final dynamic currentEvent = userProvider.openEvent;

    final bool statusOpenMatch =
        currentEvent != null && currentEvent is Match && currentEvent.isOpen;
    final bool statusOpenTraining =
        currentEvent != null && currentEvent is Training && currentEvent.isOpen;

    // בדיקה אם יש הכנה למשחק
    bool hasMatchPreparation = false;
    if (currentEvent != null && currentEvent is Match) {
      hasMatchPreparation = !hasEmptyGoalAndAction(currentEvent);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          if (state) ...[
            Align(
              alignment: Alignment.centerRight,
              child: AppSubtitle(
                subTitle: 'תוכנית האימונים',
                verticalMargin: 7,
              ),
            ),
            AppLessonCard(
                lessonTitle: 'שיעור 3', lessonNumber: 3, lessonId: 'lessonId'),
            const AppDivider(),
          ],
          DreamAndBreakoutSeasonWidget(
            dreamTitle: 'החלום הגדול שלי',
            breakoutTitle: 'עונת הפריצה שלי',
            dreamDescription: userProvider.user?.theDream ?? '',
            breakoutDescription: userProvider.user?.breakOutSeason ?? '',
          ),
          const AppDivider(
            xMargin: 10,
          ),
          if (currentEvent != null && !currentEvent.isOpen)
            // AppToggleButtons(
            //     isSelected: const [false, false],
            //     onPressed: (index) {
            //       context.push('/add-match${index == 0 ? '/training' : ''}');
            //     },
            //     isRounded: true,
            //     screenWidth:
            //         screenWidth + 20, // inside the componant reducing 80
            //     labels: const ['הכנה לאימון', 'הכנה למשחק']),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: AppSubtitle(
          //     subTitle: 'המשחק הקרוב',
          //     verticalMargin: 5,
          //   ),
          // ),
          // תצוגת משחק קרוב
          if (currentEvent == null ||
              (currentEvent != null && !currentEvent.isOpen))
            const UpcomingMatchCard(),
          if (statusOpenMatch && !hasMatchPreparation)
            const AppNoPreparationCard(),
          if (statusOpenMatch && hasMatchPreparation)
            AppXlMatchCard(
              imageSrc: 'images/soccer-match-dark.png',
              match: currentEvent,
              showCloseButton: true, // תמיד להציג כפתור סגירה
            ),
          if (statusOpenTraining)
            AppXlTrainingCard(
              imageSrc: 'images/soccer-match-dark.png',
              training: currentEvent,
            ),
          if (!hasMatchPreparation && (statusOpenMatch || statusOpenTraining))
            Accordion(
                title: 'עוזרים לך להתכונן',
                softTitleStyle: true,
                isExpanded: false,
                child: Column(
                  children: [
                    ...dataProvider.caseAndResponse
                        .take(3)
                        .map((item) => AppCaseAndReactionsCard(
                              title: 'עדיין אין קטגוריה',
                              text: item.caseName,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CaseAndReactPage(
                                          title: item.caseName,
                                          caseAndResponseData: item,
                                          imageSrc: 'images/school.png',
                                        )),
                              ),
                            )),
                    GestureDetector(
                      child: const Text(
                        'לכל המקרים והתגובות >',
                        style:
                            TextStyle(fontSize: 14, color: Colors.blueAccent),
                      ),
                      onTap: () => context.push('/cases-and-reactions'),
                    ),
                  ],
                )),
          const SizedBox(height: 20),
          const SizedBox(height: 30),
        ],
      ),
    ));
  }
}
