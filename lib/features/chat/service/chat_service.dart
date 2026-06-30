import 'package:dio/dio.dart';
import 'package:signova/core/helper/network_helper.dart';
import 'dart:io';

class ChatService {
  final NetworkHelper _network = NetworkHelper();

  Future<Response> searchUsers(String username) async {
    return await _network.get('/users/search', query: {'query': username});
  }

  Future<Response> startChat(String receiverUsername) async {
    return await _network.post(
      '/chat/start',
      body: {'receiver_username': receiverUsername},
    );
  }

  Future<Response> sendTextMessage({
    required String sessionId,
    required String content,
  }) async {
    return await _network.post(
      '/chat/message',
      body: {'session_id': sessionId, 'type': 'text', 'content': content},
    );
  }

  Future<Response> getChatHistory(String sessionId) async {
    return await _network.get('/chat/history/$sessionId');
  }

  Future<Response> getSessions() async {
    return await _network.get('/chat/sessions');
  }

  Future<Response> uploadChatImage({
    required String sessionId,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      'file': await MultipartFile.fromFile(file.path),
    });

    return await _network.post('/chat/upload-image', body: formData);
  }

  Future<Response> uploadChatAudio({
    required String sessionId,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      'file': await MultipartFile.fromFile(file.path),
    });

    return await _network.post('/chat/upload-audio', body: formData);
  }

  Future<Response> uploadChatVideo({
    required String sessionId,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      'file': await MultipartFile.fromFile(file.path),
    });

    return await _network.post('/chat/upload-video', body: formData);
  }

  Future<Response> signToTextChat({
    required String sessionId,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      'video': await MultipartFile.fromFile(file.path),
    });

    return await _network.post('/translation/sign-to-text', body: formData);
  }
}
