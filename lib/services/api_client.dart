import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;

  SessionManager({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> clear() => _storage.delete(key: _tokenKey);
}

class AuthInterceptor extends Interceptor {
  final SessionManager sessionManager;

  AuthInterceptor(this.sessionManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired/invalid
      // Bisa trigger logout global atau refresh token jika ada endpoint
    }
    handler.next(err);
  }
}

class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient({SessionManager? sessionManager}) {
    final sm = sessionManager ?? SessionManager();
    final dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    dio.interceptors.add(AuthInterceptor(sm));
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return ApiClient._internal(dio);
  }
}
