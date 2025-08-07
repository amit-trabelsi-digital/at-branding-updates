import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_accordion.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';

class AppXlTrainingCard extends StatelessWidget {
  final double fontSize;
  final FontWeight? fontWeight;
  final VoidCallback? onPressed;
  final String imageSrc;
  final Training? training;

  const AppXlTrainingCard(
      {super.key,
      required this.imageSrc,
      required this.training,
      this.fontSize = 20,
      this.fontWeight = FontWeight.bold,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    final timeLeft = daysUntil(training?.date);
    final isBeforePrepareTraining = hasEmptyGoalAndAction(training);
    "$isBeforePrepareTraining".cyan.log();

    final dayBeforeTraining =
        !timeLeft.startsWith('עוד') && isBeforePrepareTraining;
    final isAfterPrepareTraining =
        !isBeforePrepareTraining && !timeLeft.startsWith('אתמול') ||
            !isBeforePrepareTraining && !timeLeft.startsWith('לפני');

    final investigationAfterTraining =
        training?.investigation == false && timeLeft.startsWith('אתמול') ||
            training?.investigation == false && timeLeft.startsWith('לפני');

    "${timeLeft.startsWith('לפני')}".yellow.log();
    "$investigationAfterTraining ddddddddddddddddddddd ????????????"
        .yellow
        .log();
    "${training?.investigation}".yellow.log();
    timeLeft.yellow.log();

    return Column(
      children: [
        AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 134,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(imageSrc),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(timeLeft,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('אימון',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                if (dayBeforeTraining) ...[
                  AppDivider(
                    height: 2,
                    xMargin: 10,
                  ),
                  SizedBox(
                    width: 212,
                    child: AppButton(
                      action:
                          '0026 , Click , Prepare Training In xl training card',
                      fontSize: 14,
                      label: 'הכנה לאימון',
                      onPressed: () =>
                          {context.push('/training-prepare/${training?.id}')},
                    ),
                  ),
                ],
                SizedBox(height: 10),
                if (isAfterPrepareTraining && !investigationAfterTraining) ...[
                  AppDivider(
                    xMargin: 5,
                  ),
                  Accordion(
                    isExpanded: false,
                    useCard: false,
                    minTileHeight: 5,
                    minVerticalPadding: 1,
                    customeHeader: Text('לוח מטרות'), // "Task Board" in Hebrew
                    titlePadding:
                        EdgeInsets.symmetric(horizontal: 115, vertical: 0),
                    iconSize: 15,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppSubtitle(
                            height: 0.8,
                            color: AppColors.darkergrey,
                            subTitle: 'היעד שלי',
                            fontSize: 20,
                            textAlign: TextAlign.start,
                            verticalMargin: 0,
                            isBold: true,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: AppCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 17),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      training?.goal?.goalName ?? 'אין מידע',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ))),
                          SizedBox(
                            height: 10,
                          ),
                          AppDivider(height: 2, xMargin: 5),
                          AppSubtitle(
                            color: AppColors.darkergrey,
                            subTitle: 'פעולות',
                            textAlign: TextAlign.start,
                            verticalMargin: 0,
                            fontSize: 20,
                            isBold: true,
                          ),
                          SizedBox(height: 10),
                          ...(training?.actions
                                  ?.map((action) => SizedBox(
                                      width: double.infinity,
                                      // height: 53,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: AppCard(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 17),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                action.actionName,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            )),
                                      )))
                                  .toList() ??
                              []),
                          SizedBox(
                            height: 10,
                          ),
                          AppDivider(height: 2, xMargin: 2),
                          AppSubtitle(
                            color: AppColors.darkergrey,
                            subTitle: 'יעד אופי',
                            textAlign: TextAlign.start,
                            verticalMargin: 3,
                            fontSize: 20,
                            isBold: true,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: AppCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 17),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      training?.personalityGroup?.tag ??
                                          'אין מידע',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ))),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (investigationAfterTraining)
                  SizedBox(
                    width: 212,
                    child: AppButton(
                      action:
                          '0018 , Click , Training Investigation In xl training card',
                      fontSize: 14,
                      label: 'תחקור אחרי האימון',
                      onPressed: () => {
                        context.push('/training-investigation/${training?.id}')
                      },
                    ),
                  ),
              ],
            )),
        if (investigationAfterTraining) ...[
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              action: '0019 , Click , Add Game In xl training card disabled',
              fontSize: 14,
              isLight: true,
              label: '+ הוספת משחק',
              disabled: true,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ניתן להוסיף משחק רק לאחר השלמת תחקור',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
            ),
          )
        ]
      ],
    );
  }
}
