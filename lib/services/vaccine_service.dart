import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class VaccineService {
  final ApiClient api;
  VaccineService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<VaccineScheduleApiModel>> list(String babyId) async {
    final Response res = await api.dio.get('/vaccines', queryParameters: {'baby_id': babyId});
    final data = (res.data is List) ? res.data as List : res.data['data'] as List;
    return data.map((e) => VaccineScheduleApiModel.fromJson(e)).toList();
  }

  Future<VaccineScheduleApiModel> create({required String babyId, required String vaccineName, required String scheduleDate, String? notes, String status = 'scheduled'}) async {
    final Response res = await api.dio.post('/vaccines', data: {
      'baby_id': babyId,
      'vaccine_name': vaccineName,
      'schedule_date': scheduleDate,
      'status': status,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return VaccineScheduleApiModel.fromJson(j);
  }

  Future<VaccineScheduleApiModel> update(String id, {String? vaccineName, String? scheduleDate, String? status, String? notes}) async {
    final Response res = await api.dio.put('/vaccines/$id', data: {
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (scheduleDate != null) 'schedule_date': scheduleDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return VaccineScheduleApiModel.fromJson(j);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/vaccines/$id');
  }
}
