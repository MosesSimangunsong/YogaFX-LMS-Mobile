import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/lesson_detail.dart';
import 'lessons_repository.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  LessonsRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<LessonDetail> fetchLessonDetail(String lessonId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/lessons/$lessonId'),
      );

      final body = response.data ?? <String, dynamic>{};
      final payload = _extractPayload(body);
      return LessonDetail.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> updateLessonProgress({
    required String lessonId,
    int? progressPercent,
    bool? completed,
    String? source,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (progressPercent != null) {
        payload['progress'] = progressPercent;
        payload['progress_percent'] = progressPercent;
      }
      if (completed != null) {
        payload['completed'] = completed;
        payload['status'] = completed ? 'completed' : 'in_progress';
      }
      if (source != null && source.isNotEmpty) {
        payload['source'] = source;
      }

      await _dio.post<void>(
        _config.resolvePath('/lessons/$lessonId/progress'),
        data: payload,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final lesson = data['lesson'];
      if (lesson is Map<String, dynamic>) {
        return lesson;
      }
      return data;
    }

    final lesson = body['lesson'];
    if (lesson is Map<String, dynamic>) {
      return lesson;
    }

    return body;
  }
}
