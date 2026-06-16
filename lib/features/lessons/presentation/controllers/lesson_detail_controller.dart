import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/lesson_detail.dart';

final lessonDetailControllerProvider = FutureProvider.family
    .autoDispose<LessonDetail, String>((ref, lessonId) {
      return ref
          .read(app_providers.lessonsRepositoryProvider)
          .fetchLessonDetail(lessonId);
    });
