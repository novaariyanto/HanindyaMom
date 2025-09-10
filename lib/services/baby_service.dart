import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class BabyService {
  final ApiClient api;
  BabyService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<BabyApiModel>> list() async {
    final Response res = await api.dio.get('/babies');
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => BabyApiModel.fromJson(e)).toList();
  }

  Future<BabyApiModel> create({required String name, required String birthDate, String? photo, double? birthWeight, double? birthHeight}) async {
    final Response res = await api.dio.post('/babies', data: {
      'name': name,
      'birth_date': birthDate,
      if (photo != null) 'photo': photo,
      if (birthWeight != null) 'birth_weight': birthWeight,
      if (birthHeight != null) 'birth_height': birthHeight,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return BabyApiModel.fromJson(j);
  }

  Future<BabyApiModel> getById(String id) async {
    final Response res = await api.dio.get('/babies/$id');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return BabyApiModel.fromJson(j);
  }

  Future<BabyApiModel> update(String id, {String? name, String? birthDate, String? photo, double? birthWeight, double? birthHeight}) async {
    final Response res = await api.dio.put('/babies/$id', data: {
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (photo != null) 'photo': photo,
      if (birthWeight != null) 'birth_weight': birthWeight,
      if (birthHeight != null) 'birth_height': birthHeight,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return BabyApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/babies/$id');
  }
}
