import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mental_coach_flutter_firebase/widgets/players/app_audio_player.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class AppNotifyDraw extends StatefulWidget {
  final Widget? child;
  final OverlayEntry overlayEntry;

  // Content customization
  final String title;
  final String message;

  // Audio (optional)
  final String? audioUrl;
  final String? audioImageUrl;

  // Primary button
  final String primaryButtonLabel;
  final String? primaryButtonAction;
  final VoidCallback? onPrimaryButtonPressed;

  // Secondary button (optional)
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonPressed;

  // Optional height
  final double heightRatio;

  const AppNotifyDraw({
    required this.child,
    required this.overlayEntry,
    required this.title,
    required this.message,
    required this.primaryButtonLabel,
    this.primaryButtonAction,
    this.onPrimaryButtonPressed,
    this.secondaryButtonLabel,
    this.onSecondaryButtonPressed,
    this.audioUrl,
    this.audioImageUrl,
    this.heightRatio = 0.65,
    super.key,
  });

  @override
  AppNotifyDrawState createState() => AppNotifyDrawState();
}

class AppNotifyDrawState extends State<AppNotifyDraw>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x742b2d35), Color(0xff2b2d36)],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * widget.heightRatio,
              color: Colors.white,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AppTitle(
                          title: widget.title,
                          verticalMargin: 2,
                        ),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            height: 1,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 30),

                        // Conditional audio widget
                        if (widget.audioUrl != null &&
                            widget.audioImageUrl != null)
                          AudioWidget(
                            audioUrl: widget.audioUrl!,
                            imageUrl: widget.audioImageUrl!,
                            action: 'Notify Audio Play',
                          ),

                        SizedBox(height: 30),

                        // Primary button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: AppButton(
                            action: widget.primaryButtonAction ?? '',
                            fontSize: 24,
                            label: widget.primaryButtonLabel,
                            onPressed: () {
                              if (widget.onPrimaryButtonPressed != null) {
                                widget.onPrimaryButtonPressed!();
                              }
                              if (widget.overlayEntry.mounted) {
                                widget.overlayEntry.remove();
                              }
                            },
                          ),
                        ),

                        // Conditional secondary button
                        if (widget.secondaryButtonLabel != null)
                          Column(
                            children: [
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  if (widget.onSecondaryButtonPressed != null) {
                                    widget.onSecondaryButtonPressed!();
                                  }
                                  if (widget.overlayEntry.mounted) {
                                    widget.overlayEntry.remove();
                                  }
                                },
                                child: Text(
                                  widget.secondaryButtonLabel!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Example with audio
// final overlayEntry = OverlayEntry(builder: (context) {
//   return AppNotifyDraw(
//     child: Container(),
//     overlayEntry: overlayEntry,
//     title: 'מסר של אלופים',
//     message: 'גם אם ראית את המסר הזה מליון פעם, ואתה זוכר אותו בעל-פה, אנחנו רוצים לשמר אותו.',
//     primaryButtonLabel: 'קיבלתי',
//     primaryButtonAction: '0020 , Click , I Got It In Notify',
//     audioUrl: 'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%94%D7%95%D7%93%D7%A2%D7%94%20%D7%90%D7%97%D7%A8%D7%99%20%D7%94%D7%9B%D7%A0%D7%94%20%D7%9C%D7%9E%D7%A9%D7%97%D7%A7.mp3?alt=media&token=93334f41-b284-4277-87a5-55a70cab98d8',
//     audioImageUrl: 'images/eitan.png',
//     secondaryButtonLabel: 'אני מוותר',
//   );
// });

// // Example without audio
// final overlayEntry = OverlayEntry(builder: (context) {
//   return AppNotifyDraw(
//     child: Container(),
//     overlayEntry: overlayEntry,
//     title: 'התראה חשובה',
//     message: 'שים לב! זה מסר חשוב מאוד.',
//     primaryButtonLabel: 'אישור',
//     secondaryButtonLabel: 'לא תודה',
//   );
// });
