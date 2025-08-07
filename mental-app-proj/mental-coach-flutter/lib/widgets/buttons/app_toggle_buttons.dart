import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppToggleButtons extends StatelessWidget {
  final List<bool> isSelected;
  final ValueChanged<int> onPressed;
  final double screenWidth;
  final List<String> labels;
  final EdgeInsets buttonsPadding;
  final bool isRounded;
  final double fontSize;
  final double? maxHeight;
  final int? selectedIndex;
  final Color
      unselectedFillColor; // Add this parameter for unselected button color

  const AppToggleButtons({
    required this.isSelected,
    required this.onPressed,
    required this.screenWidth,
    required this.labels,
    this.isRounded = false,
    this.buttonsPadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    this.fontSize = 20,
    this.maxHeight,
    this.selectedIndex,
    this.unselectedFillColor =
        Colors.transparent, // Default value is transparent
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Create isSelected list based on selectedIndex if provided
    var effectiveIsSelected = selectedIndex != null
        ? List.generate(labels.length, (index) => index == selectedIndex)
        : isSelected;

    return ToggleButtons(
      borderRadius: BorderRadius.circular(isRounded ? 25 : 2),
      isSelected: effectiveIsSelected,
      onPressed: onPressed,
      color: Colors.black,
      splashColor: AppColors.primary,
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      renderBorder: true,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : const BoxConstraints(),
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;

        return Container(
          width: (screenWidth - 82) / labels.length,
          color: effectiveIsSelected[index]
              ? null
              : unselectedFillColor, // Apply unselected color
          child: Center(
            child: Padding(
              padding: buttonsPadding,
              child: Text(
                label,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
