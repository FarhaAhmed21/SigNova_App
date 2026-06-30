import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/core/helper/network_helper.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/features/profile/screens/edit_profile_screen.dart';
import 'package:signova/features/profile/service/profile_service.dart';
import 'package:signova/features/profile/widgets/profile_avatar.dart';
import 'package:sizer/sizer.dart';

const Color primaryPurple = Color(0xFF6B4CF4);
const Color lightGreyBg = Color(0xFFF7F8FA);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await ProfileService().loadUser();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4.h),
              const ProfileAvatar(),
              SizedBox(height: 2.h),
              Text(
                User().userName ?? "Unknown User",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 0.2.h),
              Text(
                User().email ?? "No email available",
                style: TextStyle(color: AppColors.hintColor, fontSize: 16.sp),
              ),

              SizedBox(height: 4.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Settings",
                      style: TextStyle(
                        color: AppColors.hintColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildMenuOption(
                      icon: Icons.person_outline,
                      title: "Personal Information",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 1.5.h),
                    _buildMenuOption(
                      icon: Icons.logout_outlined,
                      title: "Log Out",
                      isLogout: true,
                      onTap: () async {
                        await NetworkHelper().logout();
                        await User().clear();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', false);
                        context.pushNamedAndRemoveUntil(
                          Routes.signInScreen,
                          predicate: (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: lightGreyBg,
          borderRadius: BorderRadius.circular(25.sp),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryPurple, size: 20.sp),
            SizedBox(width: 4.w),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            isLogout
                ? SizedBox.shrink()
                : Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.hintColor,
                    size: 16.sp,
                  ),
          ],
        ),
      ),
    );
  }
}
