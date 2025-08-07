import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppStaticChip extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final EdgeInsets? padding;
  final bool darkMode;

  const AppStaticChip(
      {super.key,
      required this.label,
      this.selectedValue,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: darkMode ? Colors.black : AppColors.grey),
          child: Center(
            heightFactor: 1.1,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
