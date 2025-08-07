import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';

class AppNoPreparationCard extends StatelessWidget {
  const AppNoPreparationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const Text(
            "המשחק הקרוב",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontFamily: 'Barlev',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 22, 15, 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              children: [
                SvgPicture.asset(
                  'icons/target icon.svg',
                  width: 75,
                  height: 78,
                  colorFilter: ColorFilter.mode(
                    Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "עדיין לא עשית הכנה\nלמשחק הקרוב...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Barlev',
                      height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text(
                  "כדאי להתחיל 24 שעות לפני המשחק",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Barlev',
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 27),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    action:
                        '0020 , Click , prepare match from no preparation card',
                    label: 'הכנה למשחק',
                    fontSize: 20,
                    onPressed: () => context.push('/add-match'),
                    color: const Color(0xff22242f),
                    pHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
