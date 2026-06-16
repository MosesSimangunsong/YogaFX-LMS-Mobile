import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/assessment_result.dart';
import '../domain/assessment_session.dart';
import 'assessments_repository.dart';

class AssessmentsRepositoryImpl implements AssessmentsRepository {
  AssessmentsRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<AssessmentSession> fetchAssessment(String assessmentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/assessments/$assessmentId'),
      );
      final body = response.data ?? <String, dynamic>{};
      return AssessmentSession.fromJson(_extractPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AssessmentResult> submitAssessment({
    required String assessmentId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.resolvePath('/assessments/$assessmentId/submit'),
        data: {'answers': answers},
      );
      final body = response.data ?? <String, dynamic>{};
      return AssessmentResult.fromJson(_extractPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final assessment = data['assessment'];
      if (assessment is Map<String, dynamic>) {
        return assessment;
      }
      return data;
    }

    final assessment = body['assessment'];
    if (assessment is Map<String, dynamic>) {
      return assessment;
    }

    return body;
  }
}
