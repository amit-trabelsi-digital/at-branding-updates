import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';

class AppCaseAndReactionsCard extends StatelessWidget {
  final String title;
  final String text;
  final String? videoTime;
  final String? heroTag; // Make it optional
  final VoidCallback? onTap; // Added onTap callback

  const AppCaseAndReactionsCard({
    super.key,
    required this.title,
    required this.text,
    this.videoTime,
    this.heroTag,
    this.onTap, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AppCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTap, // Set the onTap function here
                child: Container(
                  width: 108,
                  height: 86,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          const Color.fromARGB(220, 77, 77, 77)
                        ],
                      )),
                ),
              ),
              if (videoTime != null)
                Positioned(
                  top: 63,
                  left: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black),
                    child: Text(
                      videoTime!,
                      style: const TextStyle(
                        fontSize: 8,
                        height: 1.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(),
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkergrey,
                        height: 1.05),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // If heroTag is provided, wrap with Hero
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
