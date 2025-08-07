import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/utils/dialog_handlers.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_dropdown_menu.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_percentage_bar.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class AppTrainingCard extends StatelessWidget {
  final Training training;
  final String buttonText;
  final String? number;

  const AppTrainingCard({
    super.key,
    required this.training,
    required this.buttonText,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final formattedTime = DateFormat('HH:mm').format(training.date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(training.date);

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
                      child: Image.asset(
                          'images/shirt.png')), // Different icon for training
                  const SizedBox(width: 14),
                  Stack(
                    children: [
                      SizedBox(
                        height: 45,
                        width: 160,
                      ),
                      Positioned(
                        top: 19,
                        child: Text('אימון', // Assuming Training has a title
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
                      child: AppDropdownActionButton<String>(
                        icon: Icons.more_vert,
                        items: [
                          DropdownAction(
                            label: 'מחיקה',
                            value: 'delete',
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'delete':
                              handleTrainingDelete(context, training);
                              break;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AppPercentageBar(
                percentage: calculateMatchPerformance(
                    training)), // Assuming Training has a performance field
          )
        ],
      ),
    );
  }
}

// Use the generic handler specifically for trainings
void handleTrainingDelete(BuildContext context, Training training) {
  handleEntityDelete(
    context: context,
    entityId: training.id,
    entityType: 'trainings',
    entityDisplayName: 'אימון',
  );
}
