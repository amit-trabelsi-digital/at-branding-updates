import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_number_bubble.dart';

class ScoreNotificationWidget extends StatefulWidget {
  final int score;

  const ScoreNotificationWidget({super.key, required this.score});

  @override
  ScoreNotificationWidgetState createState() => ScoreNotificationWidgetState();
}

class ScoreNotificationWidgetState extends State<ScoreNotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation controller
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Slide animation duration
    );

    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000), // Fade animation duration
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.fastOutSlowIn),
    );

    // Start the slide animation, then start the fade animation after a delay
    _slideController.forward().whenComplete(() {
      // Delay the fade animation by 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // The background overlay with gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x742b2d35), Color(0xff2b2d36)],
                ),
              ),
            ),
          ),
          // The circular score notification
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  height:
                      100), // Adjust this value to move it further down or up
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  shadowColor: AppColors.darkergrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      " אלופים לא מוותרים .",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: NumberBubble(
                  number: widget.score,
                  sign: '-',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
