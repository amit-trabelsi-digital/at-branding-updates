import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';

final Map<String, String> icons = {
  'person': 'icons/player-icon.png',
  'learn': 'icons/learn-icon.png',
  'brain': 'icons/brain-icon.png',
};

enum IconType { person, learn, brain }

class AppMissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final String iconText;
  final IconType iconType;

  String getIconPath(IconType iconType) {
    switch (iconType) {
      case IconType.person:
        return icons['person']!;
      case IconType.learn:
        return icons['learn']!;
      case IconType.brain:
        return icons['brain']!;
    }
  }

  const AppMissionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    required this.iconText,
    required this.iconType,
    this.icon = Icons.person_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 91,
                      height: 112,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            getIconPath(iconType),
                            width: 40, // Set the size of the icon
                            height: 40,
                          ),
                          Text(
                            iconText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 40, // Minimum height
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkergrey,
                          ),
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            action: '0022 , Click , complete profile',
                            label: buttonText,
                            fontSize: 16,
                            onPressed: onPressed,
                            pHeight: 5,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
