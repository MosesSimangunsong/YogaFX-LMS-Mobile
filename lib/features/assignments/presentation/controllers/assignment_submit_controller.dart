import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../../home/presentation/controllers/dashboard_controller.dart';
import '../../../modules/presentation/controllers/module_detail_controller.dart';
import '../../../modules/presentation/controllers/modules_controller.dart';
import '../../domain/assignment_submission_result.dart';
import 'assignment_detail_controller.dart';

final assignmentSubmitControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AssignmentSubmitController, AssignmentSubmissionResult?, String>(
      AssignmentSubmitController.new,
    );

class AssignmentSubmitController
    extends
        AutoDisposeFamilyAsyncNotifier<AssignmentSubmissionResult?, String> {
  @override
  Future<AssignmentSubmissionResult?> build(String arg) async => null;

  Future<void> submit({
    required String moduleId,
    required String filePath,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(app_providers.assignmentsRepositoryProvider)
          .submitAssignmentVideo(
            assignmentId: arg,
            filePath: filePath,
            fileName: fileName,
          );

      ref.invalidate(assignmentDetailControllerProvider(arg));
      ref.invalidate(moduleDetailControllerProvider(moduleId));
      ref.invalidate(modulesControllerProvider);
      ref.invalidate(dashboardControllerProvider);

      return result;
    });
  }
}
