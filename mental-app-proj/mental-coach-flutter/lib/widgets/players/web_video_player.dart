import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool showControls;

  const WebVideoPlayer({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;
  double _currentPosition = 0;
  double _duration = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();

      setState(() {
        _isInitialized = true;
        _duration = _controller.value.duration.inSeconds.toDouble();
      });

      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _controller.value.position.inSeconds.toDouble();
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });

      if (widget.autoPlay) {
        await _controller.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(double seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 300,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) {
        if (widget.showControls) {
          setState(() {
            _showControls = true;
          });
        }
      },
      onExit: (_) {
        setState(() {
          _showControls = false;
        });
      },
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 300,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (widget.showControls && (_showControls || !_isPlaying))
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Play/Pause button
                      if (!_isPlaying)
                        Center(
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 64,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Slider(
                                value: _currentPosition,
                                min: 0,
                                max: _duration,
                                onChanged: (value) {
                                  setState(() {
                                    _currentPosition = value;
                                    _controller
                                        .seekTo(Duration(seconds: value.toInt()));
                                  });
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withValues(alpha: 0.3),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_currentPosition),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
