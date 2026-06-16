import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/assignment_detail.dart';

final assignmentDetailControllerProvider = FutureProvider.family
    .autoDispose<AssignmentDetail, String>((ref, assignmentId) {
      return ref
          .read(app_providers.assignmentsRepositoryProvider)
          .fetchAssignmentDetail(assignmentId);
    });
