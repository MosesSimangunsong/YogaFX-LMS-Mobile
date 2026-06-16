class AssignmentDetail {
  const AssignmentDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    required this.statusLabel,
    required this.dueLabel,
    required this.canUpload,
    required this.latestSubmission,
    required this.feedback,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {
    return AssignmentDetail(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title:
          _asString(json['title']) ?? _asString(json['name']) ?? 'Assignment',
      description:
          _asString(json['description']) ??
          _asString(json['summary']) ??
          'Review the assignment brief, then upload your video submission.',
      instructions:
          _asString(json['instructions']) ??
          _asString(json['body']) ??
          _asString(json['content']) ??
          'Upload a video file from your device to complete this assignment.',
      statusLabel:
          _asString(json['submission_status']) ??
          _asString(json['status']) ??
          'Not submitted',
      dueLabel:
          _asString(json['due_label']) ??
          _asString(json['due_at_label']) ??
          _asString(json['deadline']) ??
          'No due date',
      canUpload:
          _asBool(json['can_upload']) ??
          _asBool(json['can_submit']) ??
          _asBool(json['allow_resubmission']) ??
          true,
      latestSubmission: AssignmentSubmission.fromJson(
        _findSubmissionPayload(json) ?? const {},
      ),
      feedback: AssignmentFeedback.fromJson(
        _findFeedbackPayload(json) ?? const {},
      ),
    );
  }

  final String id;
  final String title;
  final String description;
  final String instructions;
  final String statusLabel;
  final String dueLabel;
  final bool canUpload;
  final AssignmentSubmission latestSubmission;
  final AssignmentFeedback feedback;

  bool get hasFeedback =>
      feedback.title.isNotEmpty || feedback.message.isNotEmpty;
}

class AssignmentSubmission {
  const AssignmentSubmission({
    required this.statusLabel,
    required this.fileName,
    required this.fileUrl,
    required this.submittedAtLabel,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      statusLabel:
          _asString(json['status']) ??
          _asString(json['submission_status']) ??
          'No submission yet',
      fileName:
          _asString(json['file_name']) ??
          _asString(json['original_name']) ??
          _asString(json['video_name']) ??
          '',
      fileUrl:
          _asString(json['file_url']) ??
          _asString(json['url']) ??
          _asString(json['video_url']) ??
          '',
      submittedAtLabel:
          _asString(json['submitted_at_label']) ??
          _asString(json['submitted_at']) ??
          _asString(json['created_at']) ??
          'Waiting for upload',
    );
  }

  final String statusLabel;
  final String fileName;
  final String fileUrl;
  final String submittedAtLabel;

  bool get hasFile => fileName.isNotEmpty || fileUrl.isNotEmpty;
}

class AssignmentFeedback {
  const AssignmentFeedback({
    required this.title,
    required this.message,
    required this.statusLabel,
  });

  factory AssignmentFeedback.fromJson(Map<String, dynamic> json) {
    return AssignmentFeedback(
      title:
          _asString(json['title']) ??
          _asString(json['label']) ??
          _asString(json['status']) ??
          '',
      message:
          _asString(json['message']) ??
          _asString(json['feedback']) ??
          _asString(json['comment']) ??
          '',
      statusLabel: _asString(json['status']) ?? _asString(json['state']) ?? '',
    );
  }

  final String title;
  final String message;
  final String statusLabel;
}

Map<String, dynamic>? _findSubmissionPayload(Map<String, dynamic> json) {
  final direct =
      _asMap(json['latest_submission']) ?? _asMap(json['submission']);
  if (direct != null) {
    return direct;
  }

  final submissions = _asList(json['submissions']);
  if (submissions.isNotEmpty) {
    return _asMap(submissions.first);
  }

  return null;
}

Map<String, dynamic>? _findFeedbackPayload(Map<String, dynamic> json) {
  return _asMap(json['feedback']) ??
      _asMap(json['review']) ??
      _asMap(json['latest_feedback']);
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

List<dynamic> _asList(Object? value) {
  if (value is List) {
    return value;
  }
  return const [];
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool? _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return null;
}
