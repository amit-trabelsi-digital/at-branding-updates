import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/helpers/notification_helper.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_dropdown_menu.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_percentage_bar.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:mental_coach_flutter_firebase/utils/dialog_handlers.dart';

class AppMatchCard extends StatelessWidget {
  final Match match;
  final String buttonText;
  final String? number;
  final VoidCallback? onDeleteSuccess;
  final VoidCallback? onInvestigationSuccess;

  const AppMatchCard({
    super.key,
    required this.match,
    required this.buttonText,
    this.number,
    this.onDeleteSuccess,
    this.onInvestigationSuccess,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final formattedTime = DateFormat('HH:mm').format(match.date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(match.date);
    final timeLeft = daysUntil(match.date);
    final isBeforePrepareMatch = hasEmptyGoalAndAction(match);

    final bool isAfterMatch =
        timeLeft.startsWith('אתמול') || timeLeft.startsWith('לפני');
    final bool isAfterPrepareMatch = !isBeforePrepareMatch && !isAfterMatch;

    // TODO: this condition is for production
    // final bool investigationAfterMatch = !isBeforePrepareMatch && match.investigation == false && isAfterMatch;

    // TODO: this condition is for TESTING
    final bool investigationAfterMatch =
        !isBeforePrepareMatch && match.investigation == false;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          AppCard(
            elevation: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 1.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTitle(
                    title: number ?? '1',
                    verticalMargin: 0,
                  ),
                  SizedBox(
                      width: 34,
                      height: 34,
                      child: Image.asset('images/shirt.png')),
                  const SizedBox(width: 14),
                  Stack(
                    children: [
                      SizedBox(
                        height: 45,
                        width: 210,
                      ),
                      Positioned(
                        top: 19,
                        child: Text(
                            '${match.awayTeam.name} - ${match.homeTeam.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      Positioned(
                        child: AppLabel(
                          title: formattedTime,
                          subTitle: formattedDate,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: match.investigation == false
                              ? AppDropdownActionButton<String>(
                                  icon: Icons.more_vert,
                                  items: [
                                    DropdownAction(
                                      label: 'מחיקה',
                                      value: 'delete',
                                      icon: Icons.delete,
                                    ),
                                    if (isAfterPrepareMatch)
                                      DropdownAction(
                                        label: 'תחקיר',
                                        value: 'investigation',
                                        icon: Icons.file_present,
                                      ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'delete':
                                        "Delete".red.log();
                                        handleMatchDelete(context, match,
                                            onSuccess: onDeleteSuccess);
                                        break;
                                      case 'investigation':
                                        "Investigation".green.log();
                                        navigateToInvestigation(context, match,
                                            onInvestigationSuccess:
                                                onInvestigationSuccess);
                                        break;
                                    }
                                  },
                                )
                              : GestureDetector(
                                  onTap: () {
                                    showAppMatchNotifyDraw(context,
                                        currentMatch: match);
                                  },
                                  child:
                                      Image.asset('icons/file-info-icon.png'),
                                ))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child:
                AppPercentageBar(percentage: calculateMatchPerformance(match)),
          )
        ],
      ),
    );
  }
}

// Use the generic handler specifically for matches
void handleMatchDelete(BuildContext context, Match match,
    {VoidCallback? onSuccess}) {
  handleEntityDelete(
    context: context,
    entityId: match.id,
    entityType: '/users/update-match',
    entityDisplayName: 'משחק',
    onSuccessCallback: onSuccess,
  );
}

void navigateToInvestigation(BuildContext context, Match match,
    {VoidCallback? onInvestigationSuccess}) {
  context.push('/match-investigation/${match.id}');
  onInvestigationSuccess?.call();
}
