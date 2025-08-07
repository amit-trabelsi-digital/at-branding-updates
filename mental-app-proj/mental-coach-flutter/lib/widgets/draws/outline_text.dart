import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color outlineColor;
  final double outlineWidth;
  final double letterSpacing;
  final bool isBold;

  const OutlinedText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.textColor = Colors.black,
    this.outlineColor = Colors.white,
    this.outlineWidth = 1.0,
    this.letterSpacing = 1.1,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outline versions - positioned slightly offset in 8 directions
        for (double dx in [-1, 0, 1])
          for (double dy in [-1, 0, 1])
            if (dx != 0 || dy != 0)
              Positioned(
                left: dx * outlineWidth,
                top: dy * outlineWidth,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: outlineColor,
                    letterSpacing: letterSpacing,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Barlev',
                  ),
                ),
              ),
        // Center text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            letterSpacing: letterSpacing,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Barlev',
          ),
        ),
      ],
    );
  }
}
