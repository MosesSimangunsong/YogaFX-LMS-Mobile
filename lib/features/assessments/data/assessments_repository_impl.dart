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
      return AssessmentSession.fromJson(_extractSessionPayload(body));
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
        data: {'answers': _normalizeAnswers(answers)},
      );
      final body = response.data ?? <String, dynamic>{};
      return AssessmentResult.fromJson(_extractResultPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractSessionPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final assessment = data['assessment'];
      if (assessment is Map<String, dynamic>) {
        return {...data, ...assessment}..remove('assessment');
      }

      final session = data['session'];
      if (session is Map<String, dynamic>) {
        return {...data, ...session}..remove('session');
      }
      return data;
    }

    final assessment = body['assessment'];
    if (assessment is Map<String, dynamic>) {
      return {...body, ...assessment}..remove('assessment');
    }

    final session = body['session'];
    if (session is Map<String, dynamic>) {
      return {...body, ...session}..remove('session');
    }

    return body;
  }

  Map<String, dynamic> _extractResultPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      for (final key in const ['result', 'assessment_result', 'submission']) {
        final nested = data[key];
        if (nested is Map<String, dynamic>) {
          return {...data, ...nested}..remove(key);
        }
      }
      return data;
    }

    for (final key in const ['result', 'assessment_result', 'submission']) {
      final nested = body[key];
      if (nested is Map<String, dynamic>) {
        return {...body, ...nested}..remove(key);
      }
    }

    return body;
  }

  Map<String, dynamic> _normalizeAnswers(Map<String, dynamic> answers) {
    return answers.map(
      (key, value) => MapEntry(key, switch (value) {
        Set<String> values => values.toList(),
        Set<dynamic> values => values.toList(),
        _ => value,
      }),
    );
  }
}
