import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hanindyamom/models/nutrition.dart';
import 'package:hanindyamom/services/api_client.dart';
import 'package:hanindyamom/services/profile_service.dart';

class NutritionService {
  final ApiClient api;
  NutritionService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) return (data['data'] ?? []) as List<dynamic>;
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) return (data['data'] ?? data) as Map<String, dynamic>;
    throw Exception('Invalid response');
  }

  Future<List<NutritionEntry>> list(String babyId) async {
    final Response res = await api.dio.get('/nutrition', queryParameters: {'baby_id': babyId});
    final list = _extractList(res.data).map((e) => NutritionEntry.fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  Future<NutritionEntry> create({
    required String babyId,
    required DateTime time,
    required String title,
    String? notes,
    String? photoUrl,
  }) async {
    final Response res = await api.dio.post('/nutrition', data: {
      'baby_id': babyId,
      'time': time.toIso8601String(),
      'title': title,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo': photoUrl,
    });
    final obj = _extractObject(res.data);
    return NutritionEntry.fromJson(obj);
  }

  Future<NutritionEntry> createWithFile({
    required String babyId,
    required DateTime time,
    required String title,
    String? notes,
    required File photoFile,
  }) async {
    final fileName = photoFile.path.split('/').last.split('\\').last;
    final form = FormData.fromMap({
      'baby_id': babyId,
      'time': time.toIso8601String(),
      'title': title,
      if (notes != null) 'notes': notes,
      'photo_file': await MultipartFile.fromFile(photoFile.path, filename: fileName),
    });
    final Response res = await api.dio.post('/nutrition', data: form, options: Options(contentType: 'multipart/form-data'));
    final obj = _extractObject(res.data);
    return NutritionEntry.fromJson(obj);
  }

  Future<NutritionEntry> show(String id) async {
    final Response res = await api.dio.get('/nutrition/$id');
    final obj = _extractObject(res.data);
    return NutritionEntry.fromJson(obj);
  }

  Future<NutritionEntry> update(
    String id, {
    DateTime? time,
    String? title,
    String? notes,
    String? photoUrl,
  }) async {
    final Response res = await api.dio.put('/nutrition/$id', data: {
      if (time != null) 'time': time.toIso8601String(),
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo': photoUrl,
    });
    final obj = _extractObject(res.data);
    return NutritionEntry.fromJson(obj);
  }

  Future<NutritionEntry> updateWithFile(
    String id, {
    DateTime? time,
    String? title,
    String? notes,
    required File photoFile,
  }) async {
    final fileName = photoFile.path.split('/').last.split('\\').last;
    final form = FormData.fromMap({
      if (time != null) 'time': time.toIso8601String(),
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      'photo_file': await MultipartFile.fromFile(photoFile.path, filename: fileName),
    });
    final Response res = await api.dio.put('/nutrition/$id', data: form, options: Options(contentType: 'multipart/form-data'));
    final obj = _extractObject(res.data);
    return NutritionEntry.fromJson(obj);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/nutrition/$id');
  }

  static String? buildPhotoUrl(String? path) => ProfileService.buildPhotoUrl(path);
}


