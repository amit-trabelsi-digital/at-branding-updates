import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AppMiniAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String? action;
  final double size;
  final Color playButtonColor;
  final Color pauseButtonColor;
  final Color progressColor;
  final Color backgroundColor;

  const AppMiniAudioPlayer({
    super.key,
    required this.audioUrl,
    this.action,
    this.size = 50.0,
    this.playButtonColor = Colors.white,
    this.pauseButtonColor = Colors.black,
    this.progressColor = Colors.black,
    this.backgroundColor = Colors.black,
  });

  @override
  AppMiniAudioPlayerState createState() => AppMiniAudioPlayerState();
}

class AppMiniAudioPlayerState extends State<AppMiniAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer; // הוספת הגדרת המשתנה החסר
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _progress = 0.0;
  late AnimationController _progressAnimationController;

  @override
  void initState() {
    super.initState();

    // בדיקת תקינות URL
    if (widget.audioUrl.isEmpty) {
      print('Warning: Empty audio URL provided');
    } else if (!widget.audioUrl.startsWith('http://') &&
        !widget.audioUrl.startsWith('https://')) {
      print('Warning: Audio URL might not be valid: ${widget.audioUrl}');
    }

    _audioPlayer = AudioPlayer();

    // יצירת אנימציה חלקה לבר ההתקדמות
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // מאזין לשינויי מצב הניגון
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading =
              state == PlayerState.playing && _totalDuration == Duration.zero;
        });
      }
    });

    // מאזין לשינויי עמדה
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (_totalDuration.inMilliseconds > 0) {
            _progress =
                _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
            // עדכון ישיר של הפרוגרס ללא אנימציה כדי שיהיה חלק יותר
            _progressAnimationController.value = _progress;
          }
        });
      }
    });

    // מאזין לשינויי משך הקובץ
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
          _isLoading = false;
        });
      }
    });

    // מאזין לסיום הניגון
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
          _progress = 0.0;
          _progressAnimationController.value = 0.0;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    // הדפסת action אם קיים
    if (widget.action != null) {
      print('Mini Audio Player Action: ${widget.action}');
    }

    print('Audio URL: ${widget.audioUrl}');
    print('Is Playing: $_isPlaying');
    print('Current Position: $_currentPosition');

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          // ניגון חדש
          print('Starting new playback from URL: ${widget.audioUrl}');
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } else {
          // המשך ניגון
          print('Resuming playback');
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      print('Error stack trace: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // פרוגרסבר מסביב לכפתור
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CircularProgressPainter(
              progress: _progress, // שימוש ישיר ב-progress במקום באנימציה
              progressColor: widget.progressColor,
              backgroundColor: Colors.grey.withValues(alpha: 0.4),
              strokeWidth: 4.0, // עובי יותר כדי שיהיה יותר בולט
            ),
          ),

          // הכפתור עצמו
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              width: widget.size - 8,
              height: widget.size - 8,
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.white : widget.backgroundColor,
                shape: BoxShape.circle,
                border: _isPlaying
                    ? Border.all(color: widget.progressColor, width: 2)
                    : null,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isPlaying
                              ? widget.pauseButtonColor
                              : widget.playButtonColor,
                        ),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: _isPlaying
                          ? widget.pauseButtonColor
                          : widget.playButtonColor,
                      size: widget.size * 0.5,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // ציור הרקע
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // ציור ההתקדמות
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708, // התחלה מהחלק העליון (-90 מעלות)
        2 * 3.14159 * progress, // זווית ההתקדמות
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
