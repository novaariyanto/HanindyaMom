import 'package:dio/dio.dart';
import 'package:hanindyamom/services/api_client.dart';

class TimelineService {
  final ApiClient api;
  TimelineService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<dynamic>> list(String babyId) async {
    final Response res = await api.dio.get('/timeline', queryParameters: {'baby_id': babyId});
    // Kembalikan raw list; mapping ke UI dilakukan di layer presentasi
    return (res.data is List) ? res.data as List : (res.data['data'] as List);
  }
}

class DashboardService {
  final ApiClient api;
  DashboardService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> summary(String babyId, {String range = 'daily'}) async {
    final Response res = await api.dio.get('/dashboard', queryParameters: {'baby_id': babyId, 'range': range});
    return (res.data is Map<String, dynamic>) ? (res.data['data'] ?? res.data) as Map<String, dynamic> : {};
  }
}
