import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:sizer/sizer.dart';

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  final String title;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscure : false,
          keyboardType: widget.keyboardType,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14.sp),
            prefixIcon: Icon(
              widget.icon,
              color: AppColors.hintColor,
              size: 18.sp,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.hintColor,
                      size: 18.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.lightGreyBackground,
            contentPadding: EdgeInsets.symmetric(vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
