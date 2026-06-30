import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:sizer/sizer.dart';

Widget buildInputField({
  required TextEditingController controller,
  required VoidCallback onMicTap,
  required VoidCallback translateText,
}) {
  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightGreyBackground = const Color(0xFFF7F8FA);

  return Container(
    decoration: BoxDecoration(
      color: lightGreyBackground,
      borderRadius: BorderRadius.circular(30),
    ),
    padding: EdgeInsets.only(left: 4.w, right: 2.w, top: 0.5.h, bottom: 0.5.h),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: "Type what you want to translate...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14.sp),
            ),
          ),
        ),
        GestureDetector(
          onTap: onMicTap,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic, color: Colors.white, size: 18.sp),
          ),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: translateText,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.send, color: Colors.white, size: 18.sp),
          ),
        ),
      ],
    ),
  );
}
