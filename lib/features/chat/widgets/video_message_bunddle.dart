import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class VideoMessageBubble extends StatefulWidget {
  final bool isMe;
  final String time;
  final String avatarUrl;
  final Color primaryColor;
  final String videoUrl;

  const VideoMessageBubble({
    super.key,
    required this.isMe,
    required this.time,
    required this.avatarUrl,
    required this.primaryColor,
    required this.videoUrl,
  });

  @override
  State<VideoMessageBubble> createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.startsWith("http")) {
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }
    _controller.initialize().then((_) {
      debugPrint("hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
      } else {
        _controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) _buildAvatar(),
          if (!widget.isMe) SizedBox(width: 2.w),

          Column(
            crossAxisAlignment: widget.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 65.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25.sp),
                    border: widget.isMe
                        ? Border.all(color: widget.primaryColor, width: 3)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.sp),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_controller.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        else
                          const Center(child: CircularProgressIndicator()),
                        if (!isPlaying)
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 0.8.h),
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
              ),
            ],
          ),

          if (widget.isMe) SizedBox(width: 2.w),
          if (widget.isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 14,
      backgroundImage:
      widget.avatarUrl.isNotEmpty ? NetworkImage(widget.avatarUrl) : null,
      child: widget.avatarUrl.isEmpty
          ? const Icon(Icons.person, size: 16)
          : null,
    );
  }
}
