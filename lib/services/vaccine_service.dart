import 'package:dio/dio.dart';
import 'package:hanindyamom/models/vaccine.dart';
import 'package:hanindyamom/services/api_client.dart';

class VaccineService {
  final ApiClient api;
  VaccineService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) return (data['data'] ?? []) as List<dynamic>;
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) return (data['data'] ?? data) as Map<String, dynamic>;
    throw Exception('Invalid response');
  }

  Future<List<VaccineEntry>> list(String babyId) async {
    final Response res = await api.dio.get('/vaccines', queryParameters: {'baby_id': babyId});
    final data = _extractList(res.data);
    return data.map((e) => VaccineEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VaccineEntry> create({required String babyId, required String vaccineName, required String scheduleDate, String? notes, String status = 'scheduled'}) async {
    final Response res = await api.dio.post('/vaccines', data: {
      'baby_id': babyId,
      'vaccine_name': vaccineName,
      'schedule_date': scheduleDate,
      'status': status,
      if (notes != null) 'notes': notes,
    });
    final j = _extractObject(res.data);
    return VaccineEntry.fromJson(j);
  }

  Future<VaccineEntry> show(String id) async {
    final Response res = await api.dio.get('/vaccines/$id');
    final j = _extractObject(res.data);
    return VaccineEntry.fromJson(j);
  }

  Future<VaccineEntry> update(String id, {String? vaccineName, String? scheduleDate, String? status, String? notes}) async {
    final Response res = await api.dio.put('/vaccines/$id', data: {
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (scheduleDate != null) 'schedule_date': scheduleDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    });
    final j = _extractObject(res.data);
    return VaccineEntry.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/vaccines/$id');
  }
}
