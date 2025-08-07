import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';

class AppReportCard extends StatelessWidget {
  final String gameTime;
  final String gameLocation;
  final String buttonText;
  final VoidCallback onPressed;
  final String awayTeam;
  final String homeTeam;

  const AppReportCard({
    super.key,
    required this.gameTime,
    required this.awayTeam,
    required this.homeTeam,
    required this.gameLocation,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 45,
                  width: 200,
                ),
                Positioned(
                  top: 19,
                  child: Text('$awayTeam - $homeTeam',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                Positioned(
                  child: AppLabel(
                    title: gameTime,
                    subTitle: gameLocation,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    action: '0017 , Click , Report Game',
                    label: buttonText,
                    fontSize: 16,
                    onPressed: onPressed,
                    pHeight: 5,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
