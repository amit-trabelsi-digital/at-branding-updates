import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black, // Black loader
        ),
      ),
    );
  }
}
