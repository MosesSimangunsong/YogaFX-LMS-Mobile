class ModuleSummary {
  const ModuleSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.itemCountLabel,
    required this.badge,
    required this.accentIndex,
  });

  factory ModuleSummary.fromJson(Map<String, dynamic> json) {
    final lessonCount =
        _asInt(json['lesson_count']) ?? _asInt(json['lessons_count']);
    final assignmentCount =
        _asInt(json['assignment_count']) ?? _asInt(json['assignments_count']);
    final totalItems = (lessonCount ?? 0) + (assignmentCount ?? 0);

    return ModuleSummary(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title:
          _asString(json['title']) ??
          _asString(json['name']) ??
          'Untitled module',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          'YogaFX learning module',
      progressLabel:
          _asString(json['progress_label']) ??
          _asString(json['progress']) ??
          _asString(json['completion_percentage']) ??
          '--',
      itemCountLabel:
          _asString(json['item_count_label']) ??
          (totalItems > 0 ? '$totalItems items' : 'Items pending'),
      badge:
          _asString(json['badge']) ??
          _asString(json['status']) ??
          (_asBool(json['locked']) == true ? 'Locked' : null),
      accentIndex: _asInt(json['order']) ?? _asInt(json['position']) ?? 0,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String progressLabel;
  final String itemCountLabel;
  final String? badge;
  final int accentIndex;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
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
