import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class SleepService {
  final ApiClient api;
  SleepService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<SleepLogApiModel>> list(
    String babyId, {
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    final Response res = await api.dio.get(
      '/sleep',
      queryParameters: {
        'baby_id': babyId,
        'page': page,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => SleepLogApiModel.fromJson(e)).toList();
  }

  Future<SleepLogApiModel> create({required String babyId, required String startTime, required String endTime, String? notes}) async {
    final Response res = await api.dio.post('/sleep', data: {
      'baby_id': babyId,
      'start_time': startTime,
      'end_time': endTime,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return SleepLogApiModel.fromJson(j);
  }

  Future<SleepLogApiModel> getById(String id) async {
    final Response res = await api.dio.get('/sleep/$id');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return SleepLogApiModel.fromJson(j);
  }

  Future<SleepLogApiModel> update(String id, {String? startTime, String? endTime, String? notes}) async {
    final Response res = await api.dio.put('/sleep/$id', data: {
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return SleepLogApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/sleep/$id');
  }
}
