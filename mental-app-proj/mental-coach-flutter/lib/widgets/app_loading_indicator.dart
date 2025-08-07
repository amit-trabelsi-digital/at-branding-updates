import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;
  final String? message;
  final bool showMessage;

  const AppLoadingIndicator({
    super.key,
    this.size = 60.0,
    this.primaryColor = const Color(0xFF107FEB), // AppColors.primary
    this.backgroundColor =
        const Color(0xFFE6F2FF), // Very light blue background
    this.strokeWidth = 5.0,
    this.message,
    this.showMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: size,
          width: size,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            backgroundColor: backgroundColor,
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
