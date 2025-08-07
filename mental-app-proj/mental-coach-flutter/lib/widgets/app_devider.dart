import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppDivider extends StatelessWidget {
  final double? xMargin;
  final bool dark;
  final Color? customColor;
  final double height;
  const AppDivider(
      {super.key,
      this.customColor,
      this.height = 2,
      this.dark = false,
      this.xMargin = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: xMargin),
        Container(
          width: double.infinity,
          height: height,
          color: customColor ?? (dark ? AppColors.darkergrey : AppColors.grey),
        ),
        SizedBox(height: xMargin),
      ],
    );
  }
}
