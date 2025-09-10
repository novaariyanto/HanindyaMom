import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class FeedingService {
  final ApiClient api;
  FeedingService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<FeedingLogApiModel>> list(
    String babyId, {
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    final Response res = await api.dio.get(
      '/feeding',
      queryParameters: {
        'baby_id': babyId,
        'page': page,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => FeedingLogApiModel.fromJson(e)).toList();
  }

  Future<FeedingLogApiModel> create({required String babyId, required String type, required String startTime, required int durationMinutes, String? notes}) async {
    final Response res = await api.dio.post('/feeding', data: {
      'baby_id': babyId,
      'type': type,
      'start_time': startTime,
      'duration_minutes': durationMinutes,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return FeedingLogApiModel.fromJson(j);
  }

  Future<FeedingLogApiModel> getById(String id) async {
    final Response res = await api.dio.get('/feeding/$id');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return FeedingLogApiModel.fromJson(j);
  }

  Future<FeedingLogApiModel> update(String id, {String? type, String? startTime, int? durationMinutes, String? notes}) async {
    final Response res = await api.dio.put('/feeding/$id', data: {
      if (type != null) 'type': type,
      if (startTime != null) 'start_time': startTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return FeedingLogApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/feeding/$id');
  }
}
