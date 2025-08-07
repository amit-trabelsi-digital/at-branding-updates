import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppChoiceChip extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final Function(String)? onSelected;
  final Color? selectedColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final bool isStaticSelected; // New parameter for static selected styling

  const AppChoiceChip({
    super.key,
    required this.label,
    this.selectedValue,
    this.onSelected,
    this.selectedColor = Colors.black,
    this.backgroundColor,
    this.padding,
    this.borderRadius = 20.0,
    this.fontSize = 18.0,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.isStaticSelected = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = isStaticSelected || selectedValue == label;

    return ChoiceChip(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: isSelected ? selectedTextColor : unselectedTextColor,
        ),
      ),
      selected: isSelected,
      selectedColor: selectedColor,
      backgroundColor: backgroundColor ?? AppColors.lightGrey,
      // disabledColor: isStaticSelected ? selectedColor : null, // Add this line
      onSelected: isStaticSelected
          ? null // Disable selection if it's static
          : (bool selected) {
              if (selected && onSelected != null) {
                onSelected!(label);
              }
            },
    );
  }
}
