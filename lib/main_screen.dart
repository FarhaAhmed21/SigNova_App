import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/core/shared_widget/login_required_video.dart';
import 'package:signova/features/profile/screens/profile_screen.dart';
import 'package:signova/features/translation/screens/translation_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:signova/features/chat/screens/chat_home_screen.dart.';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;

  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightPurpleBg = const Color(0xFFF2F0FF);
  final Color unselectedGrey = const Color(0xFF9E9E9E);

  final List<Widget> _pages = [
    TranslationScreen(),
    ChatHomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Login Required",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.lightPurple,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You need to log in first to access Chat and Profile.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              LoginRequiredVideo(videoPath: 'assets/images/loginGuide.mp4'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPurple,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.pushReplacementNamed(Routes.signInScreen);
              },
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 3.h, top: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            index: 0,
            title: "Translate",
            icon: Icons.people_outline,
          ),
          _buildNavItem(
            index: 1,
            title: "Chat",
            icon: Icons.chat_bubble_outline,
          ),
          _buildNavItem(index: 2, title: "Profile", icon: Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isLoggedIn && (index == 1 || index == 2)) {
          _showLoginRequiredDialog();
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeInOut,
        width: 24.w,
        height: 7.h,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? lightPurpleBg : Colors.transparent,
          borderRadius: BorderRadius.circular(25.sp),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryPurple : unselectedGrey,
              size: 20.sp,
            ),
            SizedBox(height: 0.1.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryPurple : unselectedGrey,
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
