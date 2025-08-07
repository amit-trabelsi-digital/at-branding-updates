import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_percentage_bar.dart';

class AppLessonCard extends StatelessWidget {
  final String lessonTitle;
  final int lessonNumber;
  final String lessonId;

  const AppLessonCard({
    super.key,
    required this.lessonTitle,
    required this.lessonNumber,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('תוכנית אימונים', style: TextStyle(fontSize: 13)),
                    SizedBox(height: 2),
                    Text('שיעור $lessonNumber',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 0.8)),
                    Text(lessonTitle, style: TextStyle(fontSize: 13)),
                  ],
                ),
                AppButton(
                    action: '0001 , Click , move to lesson',
                    label: 'לצפיה >',
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed('/lesson', arguments: lessonId);
                    }),
              ],
            ),
            SizedBox(height: 5),
            AppPercentageBar(
              percentage: 40,
              color: AppColors.primary,
              height: 10,
            )
          ],
        ));
  }
}
