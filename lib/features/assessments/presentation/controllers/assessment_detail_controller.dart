import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/assessment_session.dart';

final assessmentDetailControllerProvider = FutureProvider.family
    .autoDispose<AssessmentSession, String>((ref, assessmentId) {
      return ref
          .read(app_providers.assessmentsRepositoryProvider)
          .fetchAssessment(assessmentId);
    });
