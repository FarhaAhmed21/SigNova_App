import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TextToSignPlayer extends StatefulWidget {
  final String videoUrl;

  const TextToSignPlayer({super.key, required this.videoUrl});

  @override
  State<TextToSignPlayer> createState() => _TextToSignPlayerState();
}

class _TextToSignPlayerState extends State<TextToSignPlayer> {
  VideoPlayerController? controller;

  Future<void> _loadVideo() async {
    if (widget.videoUrl.isEmpty) return;

    await controller?.dispose();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    await controller!.initialize();

    controller!
      ..setLooping(false)
      ..play();

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant TextToSignPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _loadVideo();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(
        child: Container(
          width: 280,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Preparing sign animation..."),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: Container(
        color: Colors.black,
        child: controller == null || !controller!.value.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller!.value.size.height,
                  child: VideoPlayer(controller!),
                ),
              ),
      ),
    );
  }
}
