import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:sizer/sizer.dart';

Widget buildDateHeader(String text) {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppColors.hintColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25.sp),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.hintColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
