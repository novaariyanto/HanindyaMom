import 'package:dio/dio.dart';
import 'package:hanindyamom/services/api_client.dart';
import 'package:hanindyamom/services/session_prefs.dart';

class AuthService {
  final ApiClient api;
  final SessionManager session;

  AuthService({ApiClient? apiClient, SessionManager? sessionManager})
      : api = apiClient ?? ApiClient(),
        session = sessionManager ?? SessionManager();

  Future<void> register({required String name, required String username, required String password, String? email}) async {
    await api.dio.post('/auth/register', data: {
      'name': name,
      'username': username,
      'password': password,
      if (email != null) 'email': email,
    });
  }

  Future<void> login({required String username, required String password}) async {
    final Response res = await api.dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    // Asumsikan API mengembalikan token di data.token atau header Authorization
    final data = res.data as Map<String, dynamic>;
    final token = data['data']?['token'] ?? data['token'] ?? data['access_token'];
    if (token is String && token.isNotEmpty) {
      await session.saveToken(token);
      await SessionPrefs.saveToken(token);
    } else {
      throw Exception('Token tidak ditemukan pada response login');
    }
  }

  Future<void> logout() async {
    try {
      await api.dio.post('/auth/logout');
    } catch (_) {}
    await session.clear();
    await SessionPrefs.clearToken();
  }
}
