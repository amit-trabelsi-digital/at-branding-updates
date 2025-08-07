import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class AppWideVideoPlayer extends StatefulWidget {
  final Uri videoUrl;
  const AppWideVideoPlayer({super.key, required this.videoUrl});

  @override
  AppWideVideoPlayerState createState() => AppWideVideoPlayerState();
}

class AppWideVideoPlayerState extends State<AppWideVideoPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {}); // Refresh to show the video once it's initialized
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _startHideControlsTimer();
      }
      _showControls = true;
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.dispose();
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
              'לא ניתן להעלות את הסירטון',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            AppButton(
              action: '0021 , Click , Retry Video',
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _initializeVideoPlayer();
                });
              },
              label: 'נסה שוב',
            ),
          ],
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = true;
          });
        },
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 214,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          const Color.fromARGB(220, 77, 77, 77)
                        ],
                      )),
                  child: _controller.value.isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        )
                      : Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white),
                          ),
                        ),
                ),
              ),
            ),

            // Positioned Play/Pause Button
            if (_showControls)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
