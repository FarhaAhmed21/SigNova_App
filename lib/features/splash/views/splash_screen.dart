import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (isFirstTime) {
      context.pushReplacementNamed(Routes.onboardingScreen);
    } else {
      context.pushReplacementNamed(Routes.mainScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff6540E5), Color.fromARGB(255, 169, 144, 242)],
          ),
        ),

        child: Center(
          child: Image.asset(
            'assets/icons/logo.png',
            width: 90.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
