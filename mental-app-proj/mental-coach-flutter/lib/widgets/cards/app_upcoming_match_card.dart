import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';

class UpcomingMatchCard extends StatelessWidget {
  const UpcomingMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'המשחק הקרוב',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                fontFamily: 'Barlev',
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const SizedBox(height: 52),
                Image.asset(
                  'assets/icons/target-icon@3x.png', // Assuming the icon is here
                  width: 75,
                  height: 75,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.track_changes,
                    size: 75,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'עדיין לא עשית הכנה\nלמשחק הקרוב...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'כדאי להתחיל 24 שעות לפני המשחק',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 50)
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'הכנה למשחק',
            onPressed: () {
              // Navigate to match preparation screen.
              // Assuming the route is '/add-match' for a new preparation
              context.push('/add-match');
            },
            action: 'go_to_match_prep',
            color: const Color(0xff22242f),
            pHeight: 15,
          ),
        ],
      ),
    );
  }
}
