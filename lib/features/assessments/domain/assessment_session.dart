class AssessmentSession {
  const AssessmentSession({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    final questions = _asList(json['questions'])
        .map((item) => AssessmentQuestion.fromJson(_asMap(item) ?? const {}))
        .toList();

    return AssessmentSession(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title:
          _asString(json['title']) ?? _asString(json['name']) ?? 'Assessment',
      description:
          _asString(json['description']) ??
          _asString(json['instructions']) ??
          'Complete this assessment to keep your lesson progress aligned.',
      questions: questions,
    );
  }

  final String id;
  final String title;
  final String description;
  final List<AssessmentQuestion> questions;
}

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    required this.required,
    required this.options,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      prompt:
          _asString(json['prompt']) ??
          _asString(json['question']) ??
          _asString(json['title']) ??
          'Question',
      type:
          _asString(json['type']) ??
          _asString(json['question_type']) ??
          'single_choice',
      required: _asBool(json['required']) ?? true,
      options: _asList(json['options'])
          .map((item) => AssessmentOption.fromJson(_asMap(item) ?? const {}))
          .toList(),
    );
  }

  final String id;
  final String prompt;
  final String type;
  final bool required;
  final List<AssessmentOption> options;

  bool get isMultipleChoice => type == 'multiple_choice' || type == 'checkbox';
  bool get isTextInput =>
      type == 'text' || type == 'textarea' || type == 'essay';
}

class AssessmentOption {
  const AssessmentOption({required this.id, required this.label});

  factory AssessmentOption.fromJson(Map<String, dynamic> json) {
    return AssessmentOption(
      id: _asString(json['id']) ?? _asString(json['value']) ?? '',
      label: _asString(json['label']) ?? _asString(json['text']) ?? 'Option',
    );
  }

  final String id;
  final String label;
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
