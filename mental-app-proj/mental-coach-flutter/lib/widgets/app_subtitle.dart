import 'package:flutter/material.dart';

class AppSubtitle extends StatelessWidget {
  final String subTitle;
  final double verticalMargin;
  final Color color;
  final double? fontSize;
  final TextAlign textAlign;
  final bool isBold;
  final double? height;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? letterSpacing;

  const AppSubtitle({
    super.key,
    required this.subTitle,
    this.verticalMargin = 16.0,
    this.color = Colors.black,
    this.fontSize = 24,
    this.textAlign = TextAlign.center,
    this.isBold = true,
    this.height = 1,
    this.fontFamily,
    this.fontWeight,
    this.letterSpacing = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      child: Text(
        subTitle,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          letterSpacing: letterSpacing,
          fontWeight:
              fontWeight ?? (isBold ? FontWeight.w900 : FontWeight.normal),
          height: height,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
