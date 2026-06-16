import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/dashboard_data.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<DashboardData> fetchDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/dashboard'),
      );

      final body = response.data ?? <String, dynamic>{};
      final payload = _extractPayload(body);
      return DashboardData.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return body;
  }
}
