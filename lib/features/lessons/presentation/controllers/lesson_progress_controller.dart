import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../../home/presentation/controllers/dashboard_controller.dart';
import '../../../modules/presentation/controllers/module_detail_controller.dart';
import '../../../modules/presentation/controllers/modules_controller.dart';
import 'lesson_detail_controller.dart';

final lessonProgressControllerProvider = AsyncNotifierProvider.autoDispose
    .family<LessonProgressController, void, String>(
      LessonProgressController.new,
    );

class LessonProgressController
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> syncProgress({
    required String moduleId,
    int? progressPercent,
    bool? completed,
    String? source,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(app_providers.lessonsRepositoryProvider)
          .updateLessonProgress(
            lessonId: arg,
            progressPercent: progressPercent,
            completed: completed,
            source: source,
          );

      ref.invalidate(lessonDetailControllerProvider(arg));
      ref.invalidate(moduleDetailControllerProvider(moduleId));
      ref.invalidate(modulesControllerProvider);
      ref.invalidate(dashboardControllerProvider);
    });
  }
}
