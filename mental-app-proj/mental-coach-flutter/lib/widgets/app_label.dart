import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String title;
  final String subTitle;
  final double fontSize;
  final FontWeight? fontWeight;
  final MainAxisAlignment mainAxisAlignment;
  final bool allowWrap; // פרמטר חדש לשבירת שורות

  const AppLabel({
    super.key,
    required this.title,
    required this.subTitle,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.allowWrap = false, // ברירת מחדל - ללא שבירת שורות
  });

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      // מצב שבירת שורות
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            SizedBox(height: 0),
            Container(
              width: double.infinity,
              child: Text(
                subTitle,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    } else {
      // מצב רגיל - Row כמו שהיה
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '|',
            style: TextStyle(
              fontSize: fontSize + 6,
              fontWeight: FontWeight.w200,
            ),
          ),
          SizedBox(width: 8),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ],
      );
    }
  }
}
