import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppTogglePerformingActions extends StatelessWidget {
  final List<bool> isSelected;
  final ValueChanged<int> onPressed;
  final double? screenWidth;
  final String title;
  const AppTogglePerformingActions({
    required this.isSelected,
    required this.onPressed,
    this.screenWidth,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['בוצע', 'לא'];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey), // Set border color
        borderRadius: BorderRadius.circular(4), // Optional: Set border radius
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          ToggleButtons(
            isSelected: isSelected,
            onPressed: onPressed,
            color: Colors.black,
            selectedColor: Colors.white,
            fillColor: Colors.black,
            children: labels.map((label) {
              return SizedBox(
                width: 50,
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
                    child: Column(
                      children: [
                        Icon(
                          label == 'לא' ? Icons.close : Icons.check,
                          size: 20,
                          weight: 0.2,
                        ),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
