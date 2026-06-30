import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/features/profile/screens/profile_screen.dart';
import 'package:signova/features/profile/service/profile_service.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  Widget build(BuildContext context) {
    print("Avatar URL: ${User().avatarUrl}");
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryPurple.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: User().avatarUrl != null
                ? NetworkImage(User().avatarUrl!)
                : null,
            child: User().avatarUrl == null ? const Icon(Icons.person) : null,
          ),
        ),

        GestureDetector(
          onTap: () async {
            File? imageFile = await pickImage();
            if (imageFile != null) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await ProfileService().uploadAvatar(imageFile);
                await ProfileService().loadUser();
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Avatar updated successfully")),
                );
              } on DioException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ERROR: Failed to update avatar"),
                  ),
                );
                Navigator.of(context).pop();
                print('TYPE: ${e.type}');
                print('STATUS: ${e.response?.statusCode}');
                print('DATA: ${e.response?.data}');
                print('MESSAGE: ${e.message}');
                print('ERROR: ${e.error}');
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 5, right: 5),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
          ),
        ),
      ],
    );
  }
}

final ImagePicker picker = ImagePicker();

Future<File?> pickImage() async {
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image == null) return null;

  return File(image.path);
}
