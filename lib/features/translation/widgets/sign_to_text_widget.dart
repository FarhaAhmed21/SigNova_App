import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:signova/core/shared_widget/login_required_video.dart';
import 'package:sizer/sizer.dart';

Widget buildSignToTextView({
  required String translatedText,
  required bool isLoading,
  required VoidCallback onRecordTap,
  required VoidCallback onUploadTap,
  required GlobalKey uploadKey,
  required GlobalKey cameraKey,
}) {
  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightGreyBackground = const Color(0xFFF7F8FA);

  return Column(
    key: const ValueKey("signToText"),
    children: [
      Expanded(
        flex: 8,
        child: Stack(
          children: [
            Container(width: double.infinity, color: Colors.black),

            /// Upload Button
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Showcase.withWidget(
                key: uploadKey,
                width: 280,
                height: 280,
                container: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, // الخلفية البيضاء
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tap here to upload a sign language video.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: LoginRequiredVideo(
                          videoPath: 'assets/images/uploadGuide.mp4',
                        ),
                      ),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onTap: onUploadTap,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: primaryPurple,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ),

            /// Camera Button
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Center(
                child: Showcase.withWidget(
                  key: cameraKey,
                  width: 280,
                  height: 280,
                  container: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Tap here to Record a sign language video.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: LoginRequiredVideo(
                            videoPath: 'assets/images/recordGuide.mp4',
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onTap: onRecordTap,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: lightGreyBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: primaryPurple,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 2.h),

      Expanded(
        flex: 3,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.more_horiz,
                          color: primaryPurple.withOpacity(0.7),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          translatedText.isEmpty
                              ? "Record A Sign Video"
                              : "Translation Result",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      translatedText.isEmpty
                          ? "Tap the camera to start..."
                          : translatedText,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: translatedText.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),

      SizedBox(height: 2.h),
    ],
  );
}
