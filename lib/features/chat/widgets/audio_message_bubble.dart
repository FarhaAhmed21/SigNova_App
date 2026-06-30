import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AudioMessageBubble extends StatefulWidget {
  final bool isMe;
  final String audioUrl;
  final Color primaryColor;

  const AudioMessageBubble({
    super.key,
    required this.isMe,
    required this.audioUrl,
    required this.primaryColor,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  Future<void> togglePlay() async {
    if (isPlaying) {
      await audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await audioPlayer.play(UrlSource(widget.audioUrl));
      setState(() => isPlaying = true);
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F0FF),
            borderRadius: BorderRadius.circular(25.sp),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: togglePlay,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.primaryColor,
                ),
              ),
              const Text("Audio"),
            ],
          ),
        ),
      ),
    );
  }
}