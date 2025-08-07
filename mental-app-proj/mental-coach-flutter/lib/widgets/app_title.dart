import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final String title;
  final double verticalMargin; // New parameter for vertical margin
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double? lineHeight; // Fixed parameter name

  const AppTitle({
    super.key,
    required this.title,
    this.verticalMargin = 15, // Default vertical margin
    this.fontSize = 50,
    this.lineHeight, // Optional parameter
    this.color = Colors.black,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      child: Text(
        title,
        style: TextStyle(
            color: color,
            fontSize: fontSize,
            letterSpacing: 0.3,
            fontFamily: 'Barlev',
            height: lineHeight, // Apply line height if provided
            fontWeight: fontWeight),
      ),
    );
  }
}
