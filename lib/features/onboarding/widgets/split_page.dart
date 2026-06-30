import 'package:flutter/material.dart';
import 'package:signova/features/onboarding/widgets/build_dots.dart';
import 'package:sizer/sizer.dart';

class SplitPage extends StatelessWidget {
  const SplitPage({
    super.key,
    required this.title,
    required this.description,
    required this.pageIndex,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  final String title;
  final String description;
  final int pageIndex;
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

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
              Center(
                child: Image.asset("assets/icons/black-logo.png", width: 50.w),
              ),
              SizedBox(height: 4.h),
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    "assets/images/onboarding${pageIndex + 1}.png",
                    fit: BoxFit.contain,
                    height: 50.h,
                  ),
                ),
              ),
              Text(
                title,
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
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: onSkip,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      3,
                      (index) =>
                          DotIndicator(index: index, currentIndex: currentPage),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
