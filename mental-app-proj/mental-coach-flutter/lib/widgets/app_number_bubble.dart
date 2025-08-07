import 'package:flutter/material.dart';

class NumberBubble extends StatelessWidget {
  final int number;
  final String sign; // Either "+" or "-"

  const NumberBubble({super.key, required this.number, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 128,
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
              bottomRight: Radius.circular(100),
              bottomLeft: Radius.circular(0)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              '$number$sign',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Barlev',
                fontSize: 65,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }
}
