import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class DiaperService {
  final ApiClient api;
  DiaperService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<DiaperLogApiModel>> list(
    String babyId, {
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    final Response res = await api.dio.get(
      '/diapers',
      queryParameters: {
        'baby_id': babyId,
        'page': page,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => DiaperLogApiModel.fromJson(e)).toList();
  }

  Future<DiaperLogApiModel> create({required String babyId, required String type, required String time, String? color, String? texture, String? notes}) async {
    final Response res = await api.dio.post('/diapers', data: {
      'baby_id': babyId,
      'type': type,
      'time': time,
      if (color != null) 'color': color,
      if (texture != null) 'texture': texture,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return DiaperLogApiModel.fromJson(j);
  }

  Future<DiaperLogApiModel> getById(String id) async {
    final Response res = await api.dio.get('/diapers/$id');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return DiaperLogApiModel.fromJson(j);
  }

  Future<DiaperLogApiModel> update(String id, {String? type, String? time, String? color, String? texture, String? notes}) async {
    final Response res = await api.dio.put('/diapers/$id', data: {
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (color != null) 'color': color,
      if (texture != null) 'texture': texture,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return DiaperLogApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/diapers/$id');
  }
}
