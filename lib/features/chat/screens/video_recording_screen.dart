import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:signova/main.dart';
import 'package:sizer/sizer.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightPurpleBg = const Color(0xFFF2F0FF);

  CameraController? _controller;
  bool isRecording = false;
  bool isInitialized = false;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();

    if (!mounted) return;

    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 🎥 بدء / إيقاف التسجيل
  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (isRecording) {
      final file = await _controller!.stopVideoRecording();

      setState(() {
        isRecording = false;
      });

      /// 👈 رجّع مسار الفيديو
      Navigator.pop(context, file.path);
    } else {
      await _controller!.startVideoRecording();

      setState(() {
        isRecording = true;
      });
    }
  }

  /// 🔄 قلب الكاميرا
  Future<void> _switchCamera() async {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;

    await _controller?.dispose();
    await _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isInitialized
          ? Stack(
              children: [
                /// 📷 الكاميرا الحقيقية
                CameraPreview(_controller!),

                /// 🔘 الأزرار
                Positioned(
                  bottom: 4.h,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// 🔄 Flip Camera
                        FloatingActionButton(
                          heroTag: "flip",
                          onPressed: _switchCamera,
                          backgroundColor: primaryPurple,
                          child: const Icon(Icons.cameraswitch),
                        ),

                        /// 🎥 Record
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Container(
                            padding: EdgeInsets.all(isRecording ? 10 : 15),
                            decoration: BoxDecoration(
                              color: lightPurpleBg,
                              shape: BoxShape.circle,
                              border: isRecording
                                  ? Border.all(color: Colors.red, width: 4)
                                  : null,
                            ),
                            child: Icon(
                              isRecording ? Icons.stop : Icons.videocam,
                              color: primaryPurple,
                              size: 30.sp,
                            ),
                          ),
                        ),

                        /// 📤 Send (اختياري لو عايزة زر منفصل)
                        FloatingActionButton(
                          heroTag: "send",
                          onPressed: () async {
                            if (isRecording) {
                              final file = await _controller!
                                  .stopVideoRecording();

                              Navigator.pop(context, file.path);
                            }
                          },
                          backgroundColor: primaryPurple,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
