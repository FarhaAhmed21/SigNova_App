import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/core/routing/navigation.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/core/shared_widget/custom_button.dart';
import 'package:signova/features/auth/service/auth_service.dart';
import 'package:signova/features/auth/widgets/custom_input_field.dart';
import 'package:sizer/sizer.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _signIn() async {
    setState(() => isLoading = true);

    try {
      final response = await AuthService().signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final user = data['user'];
        await User().update(
          id: user['user_id'],
          userName: user['username'],
          email: user['email'],
          phone: user['phone'],
          avatarUrl: user['avatar'],
          isDeaf: user['isDeaf'],
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        debugPrint("User info: $User");
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful"),
            backgroundColor: Colors.green,
          ),
        );
        context.pushNamed(Routes.mainScreen);
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      if (!mounted) return;
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.pop(context),
                  //   child: Icon(
                  //     Icons.arrow_back,
                  //     size: 22.sp,
                  //     color: AppColors.primaryText,
                  //   ),
                  // ),
                  // SizedBox(width: 4.w),
                  Center(
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5.h),

              Center(
                child: Image.asset(
                  'assets/icons/black-logo.png',
                  width: 70.w,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 4.h),
              CustomInputField(
                controller: emailController,
                title: "Email",
                hint: "name@example.com",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              CustomInputField(
                controller: passwordController,
                title: "Password",
                hint: "••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _signIn,
                  text: "Sign In",
                  isLoading: isLoading,
                ),
              ),
              SizedBox(height: 4.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.hintColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/signUpScreen");
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isFirstTime', false);
                      context.pushReplacementNamed(Routes.mainScreen);
                    },
                    child: Column(
                      children: [
                        Text(
                          "Continue as Guest",
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
