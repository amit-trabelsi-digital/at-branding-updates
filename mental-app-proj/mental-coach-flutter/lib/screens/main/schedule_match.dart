import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_match_banner.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_match_card.dart';

import 'package:mental_coach_flutter_firebase/widgets/cards/app_training_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout_with_nav.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:provider/provider.dart';

class ScheduleMatchPage extends StatefulWidget {
  const ScheduleMatchPage({super.key});

  @override
  State<ScheduleMatchPage> createState() => _ScheduleMatchPageState();
}

class _ScheduleMatchPageState extends State<ScheduleMatchPage> {
  String selectedYear = '2024-2025';

  List<ActivityBase> items = [];

  List<Match>? upcomingMatches = [];
  List<Match>? pastMatches = [];
  List<Training>? trainings = [];
  Match? soonestMatch;

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  void initializeUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    "Initializing user data ${userProvider.openEvent}".green.log();
    if (userProvider.user != null) {
      upcomingMatches = userProvider.upommingMatches;
      pastMatches = userProvider.pastMatches;
      soonestMatch = userProvider.soonestMatch;
      items = upcomingMatches!;
      trainings = userProvider.user?.trainings;
    }
  }

  void refreshData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    "Refreshing data to rebuild widget".green.log();

    if (userProvider.user != null) {
      // Store current tab selection before refresh
      bool wasShowingUpcoming = items == upcomingMatches;
      bool wasShowingPast = items == pastMatches;
      bool wasShowingTrainings = items == trainings;

      setState(() {
        // Update data references
        upcomingMatches = userProvider.upommingMatches;
        pastMatches = userProvider.pastMatches;
        soonestMatch = userProvider.soonestMatch;
        trainings = userProvider.user?.trainings;

        // Maintain the same tab selection after refresh
        if (wasShowingUpcoming && upcomingMatches != null) {
          items = upcomingMatches!;
        } else if (wasShowingPast && pastMatches != null) {
          items = pastMatches!;
        } else if (wasShowingTrainings && trainings != null) {
          items = trainings!;
        } else if (upcomingMatches != null) {
          // Default to upcoming matches if previous selection is unclear
          items = upcomingMatches!;
        }
      });

      "Widget rebuild triggered with updated data".green.log();
    }
  }

  void updateItems(List<ActivityBase> newItems) {
    setState(() {
      items = newItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String tab1Title = 'הבאים (${upcomingMatches?.length})';
    final String tab2Title = 'הקודמים (${pastMatches?.length})';
    final String tab3Title = 'אימונים (${trainings?.length})';

    return AppPageLayout(
      title: 'יומן משחקים',
      child: Center(
        child: Column(
          children: [
            // הצגת העונה הנוכחית כטקסט סטטי
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'עונת $selectedYear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                action: '0015 , Click , Add Match In Schedule',
                pHeight: 15,
                onPressed: () {
                  context.push('/add-match');
                },
                label: 'הוספת משחק',
              ),
            ),
            if (soonestMatch != null) ...[
              AppDivider(),
              AppMatchBanner(
                timeLeft: daysUntil(soonestMatch?.date),
                gameDate: formatDateToHebrew(soonestMatch?.date),
                awayTeam: soonestMatch?.awayTeam.name ?? '',
                homeTeam: soonestMatch?.homeTeam.name ?? '',
                imageAsset: 'images/match_banner2.png',
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  action: '0016 , Click , Go To Prepare For Match',
                  isLight: true,
                  pHeight: 15,
                  onPressed: () {
                    context.push('/match-prepare/${soonestMatch?.id}');
                  },
                  label: 'הכנה למשחק',
                ),
              ),
            ],
            AppDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 20,
              children: [
                TabButton(
                  onTap: () => {updateItems(upcomingMatches!)},
                  text: tab1Title,
                  isSelected: items == upcomingMatches,
                ),
                TabButton(
                  onTap: () => {updateItems(pastMatches!)},
                  text: tab2Title,
                  isSelected: items == pastMatches,
                ),
                TabButton(
                  onTap: () => {updateItems(trainings!)},
                  text: tab3Title,
                  isSelected: items == trainings,
                ),
              ],
            ),
            Stack(
              children: [
                AppDivider(),
                if (items == upcomingMatches ||
                    items == pastMatches ||
                    items == trainings)
                  Positioned(
                    width: items == upcomingMatches
                        ? tab1Title.length.toDouble() * 9
                        : items == pastMatches
                            ? tab2Title.length.toDouble() * 9
                            : tab3Title.length.toDouble() * 9,
                    top: 20, // Adjust as needed
                    right: items == upcomingMatches
                        ? 0.0
                        : items == pastMatches
                            ? tab1Title.length.toDouble() * 11
                            : tab1Title.length.toDouble() * 11 +
                                tab2Title.length.toDouble() * 11,
                    child: Container(
                      height: 2,
                      width: 10,
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                      ),
                    ),
                  ),
              ],
            ),
            Column(children: [
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                final Match match;
                final Training training;

                if (items == upcomingMatches || items == pastMatches) {
                  match = items[index] as Match;
                  return AppMatchCard(
                    match: match,
                    buttonText: 'פרטים',
                    number:
                        (index + 1).toString(), // Use the index as the number
                    onDeleteSuccess: () {
                      "${match.id} MATCH DELETED - REFRESHING UI".red.log();
                      refreshData(); // Use the new refresh function
                    },
                  );
                } else {
                  training = items[index] as Training;
                  return AppTrainingCard(
                    training: training,
                    buttonText: 'פרטים',
                    number:
                        (index + 1).toString(), // Use the index as the number
                  );
                }
              }),
            ]),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool isSelected;

  const TabButton({
    required this.onTap,
    required this.text,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              color: isSelected ? AppColors.pink : Colors.blue,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
