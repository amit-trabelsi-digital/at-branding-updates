import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AudioWidget extends StatefulWidget {
  final String audioUrl;
  final String imageUrl;
  final String? action;

  const AudioWidget({
    super.key,
    required this.audioUrl,
    required this.imageUrl,
    this.action,
  });

  @override
  AudioWidgetState createState() => AudioWidgetState();
}

class AudioWidgetState extends State<AudioWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _hasPlayed = false; // מעקב אם הניגון התחיל פעם ראשונה
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() async {
    try {
      // טעינת ה-Source לנגן
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));

      _audioPlayer.onPositionChanged.listen((Duration position) {
        _updateProgress(position);
      });

      _audioPlayer.onDurationChanged.listen((Duration duration) {
        if (mounted) {
          setState(() {
            _totalDuration = duration;
          });
        }
      });

      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  void _updateProgress(Duration position) {
    if (!mounted) return;

    if (_totalDuration.inMilliseconds > 0) {
      setState(() {
        _progress = position.inMilliseconds / _totalDuration.inMilliseconds;
      });
    }
  }

  void _togglePlayback() async {
    if (widget.action != null) {
      print('Audio Player Action: ${widget.action}');
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (!_hasPlayed) {
          // פעם ראשונה - נגן מההתחלה
          await _audioPlayer.play(UrlSource(widget.audioUrl));
          _hasPlayed = true;
        } else {
          // כבר ניגנו - המשך מאיפה שעצרנו
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error toggling playback: $e');
      print('Error details: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: QuarterColoredBorderPainter(_progress),
                child: ClipOval(
                  child: Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 155,
            left: 235,
            child: GestureDetector(
              onTap: () {
                print('Play button tapped!');
                _togglePlayback();
              },
              behavior: HitTestBehavior
                  .opaque, // מבטיח שכל השטח של הכפתור רגיש ללחיצה
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuarterColoredBorderPainter extends CustomPainter {
  final double progress; // ערך התקדמות בין 0.0 ל-1.0

  QuarterColoredBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final double radius = size.width / 2;

    // ציור המסגרת המלאה
    paint.color = AppColors.darkgrey;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);

    // ציור קשת ההתקדמות
    if (progress > 0) {
      paint.color = Colors.black;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        4.71, // זווית התחלה (רדיאנים) - מעלה מרכז (π/2 או 1.57*3)
        6.28 *
            progress, // זווית התקדמות יחסית להתקדמות הניגון (היקף מעגל שלם הוא 2π = 6.28)
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QuarterColoredBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
