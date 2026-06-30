import 'dart:io';
import 'package:dio/dio.dart';

class AudioToTextService {
  final Dio dio = Dio();

  Future<String> transcribeAudio(String audioUrl) async {
    final tempDir = Directory.systemTemp;
    final file = File("${tempDir.path}/audio.mp3");

    await dio.download(audioUrl, file.path);

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
      "model": "whisper-1",
    });

    final response = await dio.post(
      "https://api.openai.com/v1/audio/transcriptions",
      data: formData,
      options: Options(
        headers: {
          "Authorization":
              "Bearer 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",
        },
      ),
    );

    return response.data["text"];
  }
}
