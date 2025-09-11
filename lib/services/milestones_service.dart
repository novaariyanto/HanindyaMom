import 'package:dio/dio.dart';
import 'package:hanindyamom/models/milestone.dart';
import 'package:hanindyamom/services/api_client.dart';

class MilestonesService {
  final ApiClient api;
  MilestonesService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) return (data['data'] ?? []) as List<dynamic>;
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) return (data['data'] ?? data) as Map<String, dynamic>;
    throw Exception('Invalid response');
  }

  Future<List<Milestone>> list(String babyId) async {
    final Response res = await api.dio.get('/milestones', queryParameters: {'baby_id': babyId});
    final list = _extractList(res.data).map((e) => Milestone.fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  Future<Milestone> create({
    required String babyId,
    required int month,
    required String title,
    required String description,
    bool? achieved,
    DateTime? achievedAt,
  }) async {
    final Response res = await api.dio.post('/milestones', data: {
      'baby_id': babyId,
      'month': month,
      'title': title,
      'description': description,
      if (achieved != null) 'achieved': achieved,
      if (achievedAt != null) 'achieved_at': achievedAt.toIso8601String(),
    });
    final obj = _extractObject(res.data);
    return Milestone.fromJson(obj);
  }

  Future<Milestone> show(String id) async {
    final Response res = await api.dio.get('/milestones/$id');
    final obj = _extractObject(res.data);
    return Milestone.fromJson(obj);
  }

  Future<Milestone> update(
    String id, {
    int? month,
    String? title,
    String? description,
    bool? achieved,
    DateTime? achievedAt,
  }) async {
    final Response res = await api.dio.put('/milestones/$id', data: {
      if (month != null) 'month': month,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (achieved != null) 'achieved': achieved,
      if (achievedAt != null) 'achieved_at': achievedAt.toIso8601String(),
    });
    final obj = _extractObject(res.data);
    return Milestone.fromJson(obj);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/milestones/$id');
  }
}


