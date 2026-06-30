import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoginRequiredVideo extends StatefulWidget {
  const LoginRequiredVideo({super.key, required this.videoPath});
  final String videoPath;

  @override
  State<LoginRequiredVideo> createState() => _LoginRequiredVideoState();
}

class _LoginRequiredVideoState extends State<LoginRequiredVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller
          ..setLooping(false)
          ..play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
