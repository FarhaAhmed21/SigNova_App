import 'package:flutter/material.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/core/shared_widget/custom_button.dart';
import 'package:signova/features/profile/screens/profile_screen.dart';
import 'package:signova/features/profile/service/profile_service.dart';
import 'package:signova/features/profile/widgets/profile_avatar.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = User();

    phoneController.text = user.phone ?? "";
    genderController.text = user.gender ?? "";
    if (user.dob != null && user.dob!.isNotEmpty) {
      final date = DateTime.parse(user.dob!);
      dobController.text = "${date.day}/${date.month}/${date.year}";
    } else {
      dobController.text = "";
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    final data = {
      "phone": phoneController.text.trim(),
      "gender": genderController.text.trim(),
      "dob": dobController.text.trim(),
    };

    try {
      final response = await ProfileService().updateProfile(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        await ProfileService().loadUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pop(context);
      } else {
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryText,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Personal Info",
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    const ProfileAvatar(),
                    SizedBox(height: 4.h),

                    _buildInputField(
                      label: "Phone Number",
                      hint: "Phone Number",
                      controller: phoneController,
                    ),
                    SizedBox(height: 2.5.h),

                    _buildInputField(
                      label: "Date of Birth",
                      hint: "dd/mm/yyyy",
                      controller: dobController,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    SizedBox(height: 2.5.h),

                    _buildInputField(
                      label: "Gender",
                      hint: "Gender",
                      controller: genderController,
                    ),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(6.w),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _saveProfile,
                  text: "Save & Continue",
                ),
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    IconData? leadingIcon,
    IconData? trailingIcon,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14.sp),
            prefixIcon: leadingIcon != null
                ? Icon(leadingIcon, color: AppColors.hintColor, size: 18.sp)
                : null,
            suffixIcon: trailingIcon != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Icon(
                      trailingIcon,
                      color: AppColors.hintColor,
                      size: 18.sp,
                    ),
                  )
                : null,
            filled: true,
            fillColor: lightGreyBg,
            contentPadding: EdgeInsets.symmetric(
              vertical: 2.h,
              horizontal: leadingIcon != null ? 0 : 4.w,
            ),
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
