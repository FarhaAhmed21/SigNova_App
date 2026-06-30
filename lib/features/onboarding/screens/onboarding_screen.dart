import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/features/onboarding/widgets/final_page.dart';
import 'package:signova/features/onboarding/widgets/split_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          children: [
            SplitPage(
              pageIndex: 0,
              currentPage: _currentPage,
              title: "Watch Your Text Become \n Sign Language ",
              description: "Connect Without Limits.\nUnderstand Without Words.",
              onNext: _nextPage,
              onSkip: _skip,
            ),

            SplitPage(
              pageIndex: 1,
              currentPage: _currentPage,
              title: "See Sign Language During Your Chat",
              description: "Real-Time Translation That\nKeeps You Connected.",
              onNext: _nextPage,
              onSkip: _skip,
            ),

            FinalPage(currentPage: _currentPage),
          ],
        ),
      ),
    );
  }
}
