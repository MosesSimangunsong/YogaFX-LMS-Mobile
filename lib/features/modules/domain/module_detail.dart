class ModuleDetail {
  const ModuleDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.completionLabel,
    required this.lessons,
    required this.assignments,
  });

  factory ModuleDetail.fromJson(Map<String, dynamic> json) {
    final content = _asMap(json['content']) ?? const <String, dynamic>{};
    final items = _asMap(json['items']) ?? const <String, dynamic>{};

    final lessons = _readEntryList(json, content, items, 'lessons')
        .map((item) => ModuleEntry.fromJson(_asMap(item) ?? const {}))
        .where((item) => item.title.isNotEmpty)
        .toList();
    final assignments = _readEntryList(json, content, items, 'assignments')
        .map((item) => ModuleEntry.fromJson(_asMap(item) ?? const {}))
        .where((item) => item.title.isNotEmpty)
        .toList();

    return ModuleDetail(
      id:
          _asString(json['id']) ??
          _asString(json['module_id']) ??
          _asString(json['slug']) ??
          '',
      title:
          _asString(json['title']) ??
          _asString(json['name']) ??
          'Module detail',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          'This module is ready for deeper student flow integration.',
      progressLabel:
          _asString(json['progress_label']) ??
          _asString(json['progress']) ??
          _asString(json['progress_percent']) ??
          '--',
      completionLabel:
          _asString(json['completion_label']) ??
          _asString(json['completion_state']) ??
          _asString(json['access_state']) ??
          _asString(json['status']) ??
          'In progress',
      lessons: lessons,
      assignments: assignments,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String progressLabel;
  final String completionLabel;
  final List<ModuleEntry> lessons;
  final List<ModuleEntry> assignments;

  ModuleDetail copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? progressLabel,
    String? completionLabel,
    List<ModuleEntry>? lessons,
    List<ModuleEntry>? assignments,
  }) {
    return ModuleDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progressLabel: progressLabel ?? this.progressLabel,
      completionLabel: completionLabel ?? this.completionLabel,
      lessons: lessons ?? this.lessons,
      assignments: assignments ?? this.assignments,
    );
  }
}

class ModuleEntry {
  const ModuleEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.badge,
  });

  factory ModuleEntry.fromJson(Map<String, dynamic> json) {
    final lesson = _asMap(json['lesson']) ?? const <String, dynamic>{};
    final assignment = _asMap(json['assignment']) ?? const <String, dynamic>{};
    final source = lesson.isNotEmpty ? lesson : assignment;

    return ModuleEntry(
      id:
          _asString(json['id']) ??
          _asString(json['lesson_id']) ??
          _asString(json['assignment_id']) ??
          _asString(json['slug']) ??
          _asString(source['id']) ??
          _asString(source['slug']) ??
          '',
      title:
          _asString(json['title']) ??
          _asString(json['name']) ??
          _asString(source['title']) ??
          _asString(source['name']) ??
          '',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          _asString(source['description']) ??
          _asString(json['type']) ??
          'YogaFX content',
      trailingLabel:
          _asString(json['duration']) ??
          _asString(json['duration_label']) ??
          _asString(json['progress_label']) ??
          _asString(json['status']) ??
          'Open',
      badge:
          _asString(json['badge']) ??
          _asString(json['state']) ??
          _asString(json['access_state']) ??
          (_asBool(json['locked']) == true ? 'Locked' : null),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String trailingLabel;
  final String? badge;
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

List<dynamic> _readEntryList(
  Map<String, dynamic> json,
  Map<String, dynamic> content,
  Map<String, dynamic> items,
  String key,
) {
  final direct = _asList(json[key]);
  if (direct.isNotEmpty) {
    return direct;
  }

  final contentList = _asList(content[key]);
  if (contentList.isNotEmpty) {
    return contentList;
  }

  final itemList = _asList(items[key]);
  if (itemList.isNotEmpty) {
    return itemList;
  }

  return const [];
}
