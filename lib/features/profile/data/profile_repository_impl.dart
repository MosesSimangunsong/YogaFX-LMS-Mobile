import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/password_change_request.dart';
import '../domain/student_profile.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<void> changePassword(PasswordChangeRequest request) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        _config.resolvePath('/profile/change-password'),
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<StudentProfile> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/profile'),
      );
      final body = response.data ?? <String, dynamic>{};
      return StudentProfile.fromJson(_extractPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<StudentProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        _config.resolvePath('/profile'),
        data: {'name': name, 'email': email, 'phone': phone},
      );
      final body = response.data ?? <String, dynamic>{};
      return StudentProfile.fromJson(_extractPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final profile = data['profile'];
      if (profile is Map<String, dynamic>) {
        return profile;
      }
      return data;
    }

    final profile = body['profile'];
    if (profile is Map<String, dynamic>) {
      return profile;
    }

    return body;
  }
}
