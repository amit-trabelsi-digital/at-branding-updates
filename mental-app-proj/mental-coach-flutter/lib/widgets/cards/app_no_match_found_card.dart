import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';

class AppNoMatchCard extends StatelessWidget {
  const AppNoMatchCard({super.key});

  @override
  Widget build(context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        backgroundColor: AppColors.oldPink,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'לא מוגדר משחק קרוב',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Barlev',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 225,
              child: AppButton(
                action: '0019, Click, add match from no match card',
                fontSize: 14,
                label: 'מה המשחק הבא?',
                onPressed: () => {context.push('/add-match')},
                color: const Color(0xff22242f),
              ),
            )
          ],
        ),
      ),
    );
  }
}
