import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/assignment_detail.dart';
import '../domain/assignment_submission_result.dart';
import 'assignments_repository.dart';

class AssignmentsRepositoryImpl implements AssignmentsRepository {
  AssignmentsRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<AssignmentDetail> fetchAssignmentDetail(String assignmentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/assignments/$assignmentId'),
      );
      final body = response.data ?? <String, dynamic>{};
      return AssignmentDetail.fromJson(_extractDetailPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AssignmentSubmissionResult> submitAssignmentVideo({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        _config.resolvePath('/assignments/$assignmentId/submit'),
        data: formData,
      );
      final body = response.data ?? <String, dynamic>{};
      return AssignmentSubmissionResult.fromJson(_extractActionPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractDetailPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final assignment = data['assignment'];
      if (assignment is Map<String, dynamic>) {
        return {...data, ...assignment}..remove('assignment');
      }
      return data;
    }

    final assignment = body['assignment'];
    if (assignment is Map<String, dynamic>) {
      return {...body, ...assignment}..remove('assignment');
    }

    return body;
  }

  Map<String, dynamic> _extractActionPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      for (final key in const ['submission', 'result']) {
        final nested = data[key];
        if (nested is Map<String, dynamic>) {
          return {...data, ...nested}..remove(key);
        }
      }
      return data;
    }

    for (final key in const ['submission', 'result']) {
      final nested = body[key];
      if (nested is Map<String, dynamic>) {
        return {...body, ...nested}..remove(key);
      }
    }

    return body;
  }
}
