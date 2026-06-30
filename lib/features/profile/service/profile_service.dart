import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/core/helper/network_helper.dart';

class ProfileService {
  final NetworkHelper _network = NetworkHelper();

  Future<void> loadUser() async {
    final response = await ProfileService().getProfileData();
    final profile = response.data['data']['profile'];
    debugPrint("Profile data: $profile");
    await User().update(
      id: profile['user_id'],
      userName: profile['username'],
      email: profile['email'],
      phone: profile['phone'],
      isDeaf: profile['isDeaf'],
      avatarUrl: profile['avatar'],
      dob: profile['dob'],
      gender: profile['gender'],
    );

    debugPrint("Avatar URL: ${User().avatarUrl}");
    debugPrint("id: ${User().id}");
    debugPrint("email: ${User().email}");
  }

  Future<Response> getProfileData() async {
    return await _network.get('/user/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _network.put('/user/profile', body: data);
  }

  Future<Response> uploadAvatar(File imageFile) async {
    FormData formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _network.post('/user/upload-avatar', body: formData);

    return response;
  }
}
