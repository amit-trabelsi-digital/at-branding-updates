import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/login_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start the fade-in animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedOpacity(
              duration:
                  const Duration(seconds: 1), // Shorter animation for splash
              curve: Curves.easeInOut,
              opacity: _opacity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or app icon could go here
                  // Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
