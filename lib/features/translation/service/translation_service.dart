import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:signova/core/helper/network_helper.dart';

class TranslationService {
  final NetworkHelper _network = NetworkHelper();

  Future<Response> standaloneTextToSign(String text) async {
    return await _network.post(
      '/translation/standalone/text-to-sign',
      body: {'text': text},
    );
  }

  Future<Response> standaloneSignToText(File video) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(video.path),
    });
    debugPrint("Sending video file: ${video.path}");
    return await _network.post(
      '/translation/standalone/sign-to-text',
      body: formData,
    );
  }
}
