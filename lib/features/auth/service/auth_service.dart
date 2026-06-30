import 'package:dio/dio.dart';
import 'package:signova/core/helper/network_helper.dart';

class AuthService {
  final NetworkHelper _network = NetworkHelper();

  Future<Response> signUp({
    required String username,
    required String email,
    required String phone,
    required String password,
    required bool isDeaf,
  }) async {
    return await _network.post(
      '/auth/signup',
      body: {
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "isDeaf": isDeaf,
      },
    );
  }

  Future<Response> signIn({
    required String email,
    required String password,
  }) async {
    return await _network.post(
      '/auth/login',
      body: {"email": email, "password": password},
    );
  }
}
