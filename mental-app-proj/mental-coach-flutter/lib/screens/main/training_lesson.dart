import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/models/lesson.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mental_coach_flutter_firebase/widgets/players/web_video_player.dart';

class TrainingLessonScreen extends StatefulWidget {
  final String lessonId;
  const TrainingLessonScreen({super.key, required this.lessonId});

  @override
  State<TrainingLessonScreen> createState() => _TrainingLessonScreenState();
}

class _TrainingLessonScreenState extends State<TrainingLessonScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _isLoading = true;
  Lesson? _lesson;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    // TODO: טעינת נתוני השיעור מהשרת או מקור נתונים
    // לצורך הדוגמה, ניצור שיעור דמה
    setState(() {
      _lesson = Lesson(
        id: widget.lessonId,
        title: 'שיעור אימון ${widget.lessonId}',
        description: 'תיאור השיעור',
        media: LessonMedia(
          videoUrl:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        ),
        duration: 30,
        category: 'אימון מנטלי',
        level: 'מתחיל',
      );
      _isLoading = false;
    });

    if (!kIsWeb && _lesson?.media.videoUrl != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(_lesson!.media.videoUrl!))
            ..initialize().then((_) {
              setState(() {});
            });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _lesson == null) {
      return PageLayout(
        title: 'טוען...',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PageLayout(
      title: _lesson!.title,
      child: Center(
        child: kIsWeb
            ? WebVideoPlayer(videoUrl: _lesson!.media.videoUrl ?? '')
            : _controller.value.isInitialized
                ? Material(
                    color: Colors.transparent,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                          _buildControls(),
                        ],
                      ),
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white),
              onPressed: _togglePlayPause,
            ),
            IconButton(
              icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white),
              onPressed: _toggleFullScreen,
            ),
          ],
        ),
      ),
    );
  }
}
