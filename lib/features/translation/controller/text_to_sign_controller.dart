import 'package:dio/dio.dart';

class TextToSignController {
  final Dio _dio = Dio();

  Future<String?> translateText(String text) async {
    try {
      final response = await _dio.post(
        "http://192.168.1.14:3000/translation/standalone/text-to-sign",
        data: {
          "text": text,
        },
      );

      return response.data["data"]["video_url"];
    } catch (e) {
      print("Translation Error: $e");
      return null;
    }
  }
}