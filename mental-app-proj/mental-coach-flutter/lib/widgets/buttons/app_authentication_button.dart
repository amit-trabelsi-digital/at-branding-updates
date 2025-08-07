import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppAuthenticationButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String? imagePath;
  final IconData? icon;
  final double iconWidth;
  final double iconHeight;
  final bool isLoading;

  const AppAuthenticationButton({
    super.key,
    required this.text,
    this.onPressed,
    this.imagePath,
    this.icon,
    this.iconWidth = 24,
    this.iconHeight = 24,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [AppShadows.defaultShadow],
          ),
          child: Row(
            children: [
              if (isLoading)
                SizedBox(
                  width: iconWidth,
                  height: iconHeight,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: iconWidth,
                  color: Colors.grey.shade700,
                )
              else if (imagePath != null)
                Image.asset(imagePath!, width: iconWidth, height: iconHeight)
              else
                SizedBox(width: iconWidth),
              SizedBox(width: 80),
              Text(
                isLoading ? "מתחבר..." : text,
                style: TextStyle(
                  color: isLoading ? Colors.grey.shade600 : Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
