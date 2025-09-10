import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class SettingsService {
  final ApiClient api;
  SettingsService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<SettingsApiModel> getSettings() async {
    final Response res = await api.dio.get('/settings');
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return SettingsApiModel.fromJson(j);
  }

  Future<SettingsApiModel> update({required String timezone, required String unit, required bool notifications}) async {
    final Response res = await api.dio.put('/settings', data: {
      'timezone': timezone,
      'unit': unit,
      'notifications': notifications,
    });
    final j = (res.data is Map<String, dynamic>) ? res.data['data'] ?? res.data : res.data;
    return SettingsApiModel.fromJson(j);
  }
}
