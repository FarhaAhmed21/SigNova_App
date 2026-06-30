import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget buildDarkIconButton(IconData icon) {
  return Container(
    padding: EdgeInsets.all(3.w),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white, size: 18.sp),
  );
}
