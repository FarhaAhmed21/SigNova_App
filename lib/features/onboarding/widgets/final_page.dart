import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/core/shared_widget/custom_button.dart';
import 'package:signova/features/onboarding/widgets/build_dots.dart';
import 'package:sizer/sizer.dart';

class FinalPage extends StatelessWidget {
  const FinalPage({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Column(
            children: [
              SizedBox(height: 6.h),

              /// Logo
              Center(
                child: Image.asset("assets/icons/black-logo.png", width: 50.w),
              ),

              SizedBox(height: 4.h),

              /// Image
              Expanded(
                flex: 3,
                child: Image.asset(
                  "assets/images/onboarding3.png",
                  fit: BoxFit.contain,
                  height: 50.h,
                ),
              ),
              Text(
                "Bridge the Gap.\nCommunicate Freely",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff222222),
                  height: 1.25,
                ),
              ),

              SizedBox(height: 1.8.h),

              Text(
                "One conversation,Two Worlds.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Sign Up",
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isFirstTime', false);
                    context.pushReplacementNamed(Routes.signUpScreen);
                  },
                ),
              ),

              SizedBox(height: 0.3.h),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);

                  context.pushReplacementNamed(Routes.mainScreen);
                },
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
