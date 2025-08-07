import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final Uri videoUrl;
  final String? thumbnailUrl; // אפשרות להעברת תמונת קדימון
  final String? action; // פרמטר action לכפתור הניגון

  const VideoWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.action,
  });

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _hasError = false;
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  late AnimationController _progressAnimationController;
  bool _isVideoInitialized = false;
  bool _isThumbnailLoaded = false;
  ImageProvider? _thumbnailProvider;
  bool _isBuffering = false;
  bool _isVideoVisible = false;

  // משתנה לבקרת נראות
  final ValueNotifier<double> _videoOpacity = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    // טעינת תמונת הקדימון מראש
    _preloadThumbnail();

    // יצירת אנימציה חלקה לבר ההתקדמות
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _progressAnimationController.addListener(() {
      setState(() {}); // לעדכון חלק של UI
    });

    _initializeVideoPlayer();
  }

  void _preloadThumbnail() {
    if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      // טעינת התמונה מראש כדי שתהיה מוכנה להצגה
      _thumbnailProvider = NetworkImage(widget.thumbnailUrl!);
      final imageStream = _thumbnailProvider!.resolve(ImageConfiguration.empty);

      final imageListener = ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _isThumbnailLoaded = true;
          });
        }
      }, onError: (exception, stackTrace) {
        print('Error loading thumbnail: $exception');
        if (mounted) {
          setState(() {
            _isThumbnailLoaded = false;
          });
        }
      });

      imageStream.addListener(imageListener);
    }
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(widget.videoUrl);

    // טעינת הסרטון
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _totalDuration = _controller.value.duration;

          // להציב פריים ראשון
          _controller.seekTo(Duration.zero);
        });

        // הוספת מאזין להתקדמות הווידאו
        _controller.addListener(_updateProgress);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      print('Error initializing video player: $error');
    });
  }

  void _updateProgress() {
    if (!mounted) return;

    if (_controller.value.isInitialized && _totalDuration.inMilliseconds > 0) {
      // עדכון חלק של ההתקדמות באמצעות האנימציה
      final newProgress = _controller.value.position.inMilliseconds /
          _totalDuration.inMilliseconds;
      if ((newProgress - _progress).abs() > 0.01) {
        // עדכון רק אם השינוי משמעותי
        setState(() {
          _progress = newProgress;
          _progressAnimationController.animateTo(_progress);
        });
      }
    }
  }

  void _togglePlayback() async {
    // הדפסת action אם קיים
    if (widget.action != null) {
      print('Video Player Action: ${widget.action}');
    }

    if (_isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    _progressAnimationController.dispose();
    _videoOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'לא ניתן לטעון את הסרטון',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _initializeVideoPlayer();
                });
              },
              child: Text('נסה שנית'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: QuarterColoredBorderPainter(
                    _progressAnimationController.value),
                child: ClipOval(
                  child: _isVideoInitialized && _isPlaying
                      ? AspectRatio(
                          aspectRatio: 9.0 / 9.0,
                          child: Container(
                            color: Colors.black26,
                            child: VideoPlayer(_controller),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
          ),

          // כפתור ניגון/השהייה
          Positioned(
            top: 140,
            left: 220,
            child: GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 60,
                height: 60,
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

  Widget _buildPlaceholder() {
    // אם הטעינה המקדימה של התמונה הצליחה
    if (_isThumbnailLoaded && _thumbnailProvider != null) {
      return Image(
        image: _thumbnailProvider!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // אם קיימת תמונת קדימון, ננסה להציג אותה ישירות
    if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return _buildLoadingIndicator();
          }
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading thumbnail: $error');
          return _buildLoadingIndicator();
        },
      );
    }

    // אחרת נציג אינדיקטור טעינה
    return _buildLoadingIndicator();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
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
        6.28 * progress, // זווית התקדמות יחסית להתקדמות הניגון
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QuarterColoredBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
