import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:sizer/sizer.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: AppColors.primaryText, size: 22.sp),
      onPressed: () => Navigator.pop(context),
    ),
    titleSpacing: 0,
    title: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: const NetworkImage(
            '',
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          "Sarah Miller",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: Colors.grey.shade100, height: 1),
    ),
  );
}
