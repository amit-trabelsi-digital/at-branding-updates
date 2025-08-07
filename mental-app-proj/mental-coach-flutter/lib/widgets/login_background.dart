import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(
            "images/screenPic.png",
            fit: BoxFit.cover,
          ),
        ),
        // Add the gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black, // Dark color at the bottom
                const Color.fromARGB(76, 0, 0, 0), // Transparent at the top
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
