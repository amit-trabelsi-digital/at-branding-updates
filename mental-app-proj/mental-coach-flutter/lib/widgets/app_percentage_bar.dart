import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppPercentageBar extends StatelessWidget {
  final double percentage; // 0 to 100
  final Color? color;
  final double? height;

  const AppPercentageBar(
      {super.key,
      required this.percentage,
      this.color = AppColors.darkergrey,
      this.height = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[200],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: (constraints.maxWidth * (percentage / 100))
                  .clamp(0, constraints.maxWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }
}
