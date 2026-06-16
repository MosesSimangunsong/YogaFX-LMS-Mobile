class AssessmentResult {
  const AssessmentResult({
    required this.status,
    required this.scoreLabel,
    required this.summary,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      status:
          _asString(json['status']) ?? _asString(json['result']) ?? 'submitted',
      scoreLabel:
          _asString(json['score_label']) ??
          _asString(json['score']) ??
          _asString(json['grade']) ??
          '--',
      summary:
          _asString(json['summary']) ??
          _asString(json['message']) ??
          'Assessment submitted successfully.',
    );
  }

  final String status;
  final String scoreLabel;
  final String summary;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
