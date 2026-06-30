import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'text_to_sign_player.dart';

Widget buildTextToSignView(String? videoUrl, {bool isLoading = false}) {
  return Container(
    color: Colors.black,
    child: Center(
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : videoUrl == null
          ? Text(
        "Type something to generate sign video",
        style: TextStyle(color: Colors.white70),
      )
          : SizedBox(
        width: double.infinity,
        height: 60.h,
        child: TextToSignPlayer(videoUrl: videoUrl),
      ),
    ),
  );
}