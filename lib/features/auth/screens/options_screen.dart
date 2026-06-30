import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/core/shared_widget/custom_button.dart';
import 'package:signova/features/auth/service/auth_service.dart';
import 'package:sizer/sizer.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String username;
  final String email;
  final String phone;
  final String password;

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

enum UserRole { deaf, nonDeaf, none }

class _OptionsScreenState extends State<OptionsScreen> {
  UserRole _selectedRole = UserRole.none;

  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightPurpleBg = const Color(0xFFF2F0FF);
  final Color borderPurple = const Color(0xFFDCD6FF);

  bool isDeafSelected = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24.sp,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5.h),

              Text(
                "How will you use\nSignova?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 5.h),
              _buildOptionCard(
                title: "Deaf",
                icon: Icons.hearing_disabled,
                role: UserRole.deaf,
              ),

              SizedBox(height: 3.h),

              _buildOptionCard(
                title: "Non Deaf",
                icon: Icons.record_voice_over_outlined,
                role: UserRole.nonDeaf,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: isLoading ? null : _submit,
                  text: isLoading ? "Creating account..." : "Get Started",
                  isLoading: isLoading,
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedRole == UserRole.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an option"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final isDeafSelected = _selectedRole == UserRole.deaf;

      final response = await AuthService().signUp(
        username: widget.username,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
        isDeaf: isDeafSelected,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        context.pushNamed(Routes.signInScreen);
      } else {
        throw Exception("Sign up failed");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required UserRole role,
  }) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          debugPrint("Received Data:");
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 25.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryPurple : borderPurple,
            width: isSelected ? 2.5 : 1.0,
          ),

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: lightPurpleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.sp, color: primaryPurple),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
