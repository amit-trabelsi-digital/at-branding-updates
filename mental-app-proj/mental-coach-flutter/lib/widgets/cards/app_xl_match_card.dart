import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';

class AppXlMatchCard extends StatelessWidget {
  final double fontSize;
  final FontWeight? fontWeight;
  final VoidCallback? onPressed;
  final String imageSrc;
  final Match? match;
  final bool showCloseButton;

  const AppXlMatchCard(
      {super.key,
      required this.imageSrc,
      required this.match,
      this.fontSize = 20,
      this.fontWeight = FontWeight.bold,
      this.onPressed,
      this.showCloseButton = false});

  @override
  Widget build(BuildContext context) {
    final awayTeam = match?.awayTeam.name ?? 'אין מידע';
    final homeTeam = match?.homeTeam.name ?? 'אין מידע';
    final isBeforePrepareMatch = hasEmptyGoalAndAction(match);
    "$isBeforePrepareMatch".cyan.log();

    return Column(
      children: [
        AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // מצב 1: אין הכנה למשחק - מציג תמונה + קבוצות + כפתור הכנה
                if (isBeforePrepareMatch) ...[
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
                  Column(
                    children: [
                      // שורה ראשונה - קבוצה ראשונה
                      Container(
                        width: double.infinity,
                        child: Text(
                          homeTeam,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // שורה שנייה - המילה "נגד"
                      Text(
                        'נגד',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkergrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      // שורה שלישית - קבוצה שנייה
                      Container(
                        width: double.infinity,
                        child: Text(
                          awayTeam,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppDivider(
                    height: 2,
                    xMargin: 10,
                  ),
                  SizedBox(
                    width: 212,
                    child: AppButton(
                      action: '0017 , Click , Prepare Match In xl match card',
                      label: 'הכנה למשחק',
                      onPressed: () =>
                          {context.push('/match-prepare/${match?.id}')},
                    ),
                  ),
                ],
                // מצב 2: יש הכנה למשחק - מציג פתק מטרות + כפתור סגירת משחק
                if (!isBeforePrepareMatch) ...[
                  // כותרת חדשה - המטרות שלי
                  SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'המטרות שלי',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Barlev',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push('/edit-match/${match?.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 16, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'עריכה',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  AppDivider(
                    xMargin: 0,
                    height: 2,
                    customColor: AppColors.grey,
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'מטרה למשחק',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(match?.goal?.goalName ?? 'אין מטרה'),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'פעולות',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (match?.actions != null &&
                      match?.actions?.isNotEmpty == true)
                    ...match!.actions!
                        .map<Widget>((action) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child:
                                    Text(action.actionName),
                              ),
                            ))
                        .toList()
                  else
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text('אין פעולות'),
                    ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'יעד אופי',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(match?.personalityGroup?.tag ??
                          'אין מידע על יעד אופי'),
                    ),
                  ),
                  // כפתור סגירת משחק
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      action: '0021 , Click , Close Match',
                      fontSize: 24,
                      label: 'סגירת משחק',
                      color: AppColors.primary,
                      onPressed: () {
                        context.push('/match-investigation/${match?.id}');
                      },
                    ),
                  ),
                ],
              ],
            )),
      ],
    );
  }
}
