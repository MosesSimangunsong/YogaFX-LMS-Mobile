import '../domain/lesson_detail.dart';

abstract interface class LessonsRepository {
  Future<LessonDetail> fetchLessonDetail(String lessonId);

  Future<void> updateLessonProgress({
    required String lessonId,
    int? progressPercent,
    bool? completed,
    String? source,
  });
}
