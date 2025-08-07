import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

// Reusable ToggleButtonWidget
class ToggleButtonWidget extends StatefulWidget {
  final String option1Text; // Text for the first option
  final String option2Text; // Text for the second option
  final String description1Text; // Text below the buttons
  final String description2Text; // Text below the buttons
  final ValueChanged<bool>? onToggle; // Callback when toggled
  final Color activeColor; // Color for the active (second) button
  final Color
      inactiveColor; // Color for the inactive (first) button and background

  const ToggleButtonWidget({
    super.key,
    required this.option1Text,
    required this.option2Text,
    required this.description1Text,
    required this.description2Text,
    this.onToggle,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.white,
  });

  @override
  ToggleButtonWidgetState createState() => ToggleButtonWidgetState();
}

class ToggleButtonWidgetState extends State<ToggleButtonWidget> {
  bool isFirstOption = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.inactiveColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.grey, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                _buildButton(
                  text: widget.option2Text,
                  isActive: !isFirstOption,
                  onTap: () => _updateSelection(false),
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(16)),
                ),
                _buildButton(
                  text: widget.option1Text,
                  isActive: isFirstOption,
                  onTap: () => _updateSelection(true),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                ),
              ],
            ),
          ),
          _buildDescriptionSection(
              descriptionText: isFirstOption
                  ? widget.description1Text
                  : widget.description2Text,
              descriptionIcon: isFirstOption
                  ? Image.asset('icons/cup-icon.png', width: 27, height: 27)
                  : Image.asset('icons/leafs-icon.png', width: 27, height: 27)),
        ],
      ),
    );
  }

  void _updateSelection(bool isFirst) {
    setState(() => isFirstOption = isFirst);
    widget.onToggle?.call(isFirst);
  }

  Widget _buildButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isActive ? widget.activeColor : widget.inactiveColor,
          foregroundColor: isActive ? widget.inactiveColor : widget.activeColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isActive ? widget.inactiveColor : widget.activeColor,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection({
    required String descriptionText,
    required Image descriptionIcon,
  }) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              // padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: descriptionIcon,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                descriptionText,
                style:
                    TextStyle(fontSize: 20, color: Colors.black, height: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
