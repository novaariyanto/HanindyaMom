import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/api_client.dart';

class ProfileService {
  final ApiClient api;
  ProfileService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<UserProfileApiModel> getProfile() async {
    final Response res = await api.dio.get('/me');
    final j = (res.data is Map<String, dynamic>) ? (res.data['data'] ?? res.data) : res.data;
    return UserProfileApiModel.fromJson(j as Map<String, dynamic>);
  }

  Future<UserProfileApiModel> updateProfile({String? name, String? email, String? photo, File? photoFile}) async {
    Response res;
    if (photoFile != null) {
      // multipart upload if there is a file
      final fileName = photoFile.path.split('/').last.split('\\').last;
      final form = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        // backend will ignore 'photo' if 'photo_file' is present
        'photo_file': await MultipartFile.fromFile(photoFile.path, filename: fileName),
      });
      res = await api.dio.put('/me', data: form, options: Options(contentType: 'multipart/form-data'));
    } else {
      // JSON body (name/email/photo)
      res = await api.dio.put('/me', data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (photo != null) 'photo': photo,
      });
    }
    final j = (res.data is Map<String, dynamic>) ? (res.data['data'] ?? res.data) : res.data;
    return UserProfileApiModel.fromJson(j as Map<String, dynamic>);
  }

  // Build absolute photo URL if backend returns a relative path
  static String? buildPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) return photoPath;
    final base = ApiClient().dio.options.baseUrl;
    // strip trailing /api/v1 from base
    final stripped = base.replaceFirst(RegExp(r'/api/v1/?$'), '/');
    final baseUri = Uri.parse(stripped);
    String host = baseUri.host;
    int? port = baseUri.hasPort ? baseUri.port : null;
    String scheme = baseUri.scheme.isEmpty ? 'http' : baseUri.scheme;
    // Map emulator host for Android
    if ((host == '127.0.0.1' || host == 'localhost') ) {
      host = '10.0.2.2';
    }
    final normalizedPath = photoPath.startsWith('/') ? photoPath : '/$photoPath';
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port == 0 ? null : port,
      path: normalizedPath,
    );
    return uri.toString();
  }
}


