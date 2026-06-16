import '../domain/assessment_result.dart';
import '../domain/assessment_session.dart';

abstract interface class AssessmentsRepository {
  Future<AssessmentSession> fetchAssessment(String assessmentId);

  Future<AssessmentResult> submitAssessment({
    required String assessmentId,
    required Map<String, dynamic> answers,
  });
}
