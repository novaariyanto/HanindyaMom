import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class GrowthService {
  final ApiClient api;
  GrowthService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<GrowthLogApiModel>> list(
    String babyId, {
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    final Response res = await api.dio.get(
      '/growth',
      queryParameters: {
        'baby_id': babyId,
        'page': page,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => GrowthLogApiModel.fromJson(e)).toList();
  }

  Future<GrowthLogApiModel> create({required String babyId, required String date, required double weight, required double height, double? headCircumference}) async {
    final Response res = await api.dio.post('/growth', data: {
      'baby_id': babyId,
      'date': date,
      'weight': weight,
      'height': height,
      if (headCircumference != null) 'head_circumference': headCircumference,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return GrowthLogApiModel.fromJson(j);
  }

  Future<GrowthLogApiModel> getById(String id) async {
    final Response res = await api.dio.get('/growth/$id');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return GrowthLogApiModel.fromJson(j);
  }

  Future<GrowthLogApiModel> update(String id, {String? date, double? weight, double? height, double? headCircumference}) async {
    final Response res = await api.dio.put('/growth/$id', data: {
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (headCircumference != null) 'head_circumference': headCircumference,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return GrowthLogApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/growth/$id');
  }
}
