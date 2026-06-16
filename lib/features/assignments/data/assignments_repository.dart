import '../domain/assignment_detail.dart';
import '../domain/assignment_submission_result.dart';

abstract class AssignmentsRepository {
  Future<AssignmentDetail> fetchAssignmentDetail(String assignmentId);

  Future<AssignmentSubmissionResult> submitAssignmentVideo({
    required String assignmentId,
    required String filePath,
    required String fileName,
  });
}
