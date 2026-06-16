import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../../home/presentation/controllers/dashboard_controller.dart';
import '../../../lessons/presentation/controllers/lesson_detail_controller.dart';
import '../../../modules/presentation/controllers/module_detail_controller.dart';
import '../../../modules/presentation/controllers/modules_controller.dart';
import '../../domain/assessment_result.dart';
import 'assessment_detail_controller.dart';

final assessmentSubmitControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AssessmentSubmitController, AssessmentResult?, String>(
      AssessmentSubmitController.new,
    );

class AssessmentSubmitController
    extends AutoDisposeFamilyAsyncNotifier<AssessmentResult?, String> {
  @override
  Future<AssessmentResult?> build(String arg) async => null;

  Future<void> submit({
    required String moduleId,
    required String lessonId,
    required Map<String, dynamic> answers,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(app_providers.assessmentsRepositoryProvider)
          .submitAssessment(assessmentId: arg, answers: answers);

      ref.invalidate(assessmentDetailControllerProvider(arg));
      ref.invalidate(lessonDetailControllerProvider(lessonId));
      ref.invalidate(moduleDetailControllerProvider(moduleId));
      ref.invalidate(modulesControllerProvider);
      ref.invalidate(dashboardControllerProvider);

      return result;
    });
  }
}
