class AssignmentSubmissionResult {
  const AssignmentSubmissionResult({
    required this.status,
    required this.summary,
    required this.feedbackLabel,
  });

  factory AssignmentSubmissionResult.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionResult(
      status:
          _asString(json['status']) ??
          _asString(json['submission_status']) ??
          'submitted',
      summary:
          _asString(json['message']) ??
          _asString(json['summary']) ??
          'Assignment submission uploaded successfully.',
      feedbackLabel:
          _asString(json['feedback_label']) ??
          _asString(json['review_status']) ??
          '',
    );
  }

  final String status;
  final String summary;
  final String feedbackLabel;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
