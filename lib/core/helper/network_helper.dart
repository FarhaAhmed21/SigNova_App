import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signova/core/data/user.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;

  late Dio _dio;
  NetworkHelper._internal() {
    _dio = Dio(
      BaseOptions(
        //baseUrl: 'http://192.168.1.5:3000',
        baseUrl: 'https://signova-backend-production.up.railway.app/',
        connectTimeout: const Duration(seconds: 500),
        receiveTimeout: const Duration(seconds: 500),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.endsWith('auth/signup') &&
              !options.path.endsWith('auth/login') &&
              !options.path.endsWith('/translation/standalone/text-to-sign') &&
              !options.path.endsWith('/auth/refresh') &&
              !options.path.endsWith('/translation/standalone/sign-to-text')) {
            try {
              if (!options.path.endsWith('/auth/refresh')) {
                await _refreshToken();
                debugPrint(
                  "Adding access token to request headers ${User().accessToken}",
                );
                final accessToken = User().accessToken;
                if (accessToken != null && accessToken.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $accessToken';
                }
              }
            } catch (e) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Failed to refresh token',
                ),
              );
            }
          }

          return handler.next(options);
        },

        onError: (DioException error, handler) {
          return handler.next(_handleError(error));
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    return _dio.post(path, data: body, queryParameters: query);
  }

  Future<Response> put(String path, {dynamic body}) async {
    return _dio.put(path, data: body);
  }

  Future<Response> delete(String path, {dynamic body}) async {
    return _dio.delete(path, data: body);
  }

  Future<Response> logout() async {
    final accessToken = User().accessToken ?? '';

    if (accessToken.isEmpty) {
      throw Exception("Access token is missing");
    }

    return _dio.post('/auth/logout');
  }

  Future<void> _refreshToken() async {
    try {
      final accessToken = User().accessToken ?? '';
      final refreshToken = User().refreshToken ?? '';
      final response = await _dio.post(
        '/auth/refresh',
        data: {"refreshToken": refreshToken},
      );
      final data = response.data['data'];
      User().accessToken = data['accessToken'];
      User().refreshToken = data['refreshToken'];
      debugPrint("Refresh token successful");
      debugPrint("User info: $User");
    } on DioException catch (e) {
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Response: ${e.response?.data}");
      debugPrint("Request: ${e.requestOptions.data}");
      rethrow;
    }
  }

  DioException _handleError(DioException error) {
    String message = 'Unexpected error occurred';
    int? statusCode = error.response?.statusCode;

    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        message = 'Request successful';
      } else if (statusCode == 400) {
        message = 'Bad request';
      } else if (statusCode == 401) {
        message = 'Unauthorized';
      } else if (statusCode == 403) {
        message = 'Forbidden';
      } else if (statusCode == 404) {
        message = 'Not found';
      } else if (statusCode >= 500 && statusCode < 600) {
        message = 'Server error';
      } else {
        message = 'Received invalid status code: $statusCode';
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Request timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Response timeout';
          break;
        case DioExceptionType.cancel:
          message = 'Request cancelled';
          break;
        default:
          message = 'No internet connection';
      }
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: message,
    );
  }
}
