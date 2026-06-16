class DashboardData {
  const DashboardData({
    required this.greetingTitle,
    required this.greetingSubtitle,
    required this.continueLearning,
    required this.metrics,
    required this.sections,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final continueLearning = DashboardContinueLearning.fromJson(
      _asMap(json['continue_learning']) ??
          _asMap(json['continueLearning']) ??
          _asMap(json['latest_lesson']) ??
          _asMap(json['latestLesson']) ??
          const <String, dynamic>{},
    );

    final metrics = _parseMetrics(json);
    final sections = _parseSections(json);

    return DashboardData(
      greetingTitle:
          _asString(json['greeting_title']) ??
          _asString(json['title']) ??
          'Continue your practice',
      greetingSubtitle:
          _asString(json['greeting_subtitle']) ??
          _asString(json['subtitle']) ??
          'Your latest YogaFX learning path is ready.',
      continueLearning: continueLearning,
      metrics: metrics,
      sections: sections,
    );
  }

  final String greetingTitle;
  final String greetingSubtitle;
  final DashboardContinueLearning continueLearning;
  final List<DashboardMetric> metrics;
  final List<DashboardSection> sections;
}

class DashboardContinueLearning {
  const DashboardContinueLearning({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
  });

  factory DashboardContinueLearning.fromJson(Map<String, dynamic> json) {
    return DashboardContinueLearning(
      eyebrow:
          _asString(json['eyebrow']) ??
          _asString(json['label']) ??
          'Continue learning',
      title:
          _asString(json['title']) ??
          _asString(json['lesson_title']) ??
          _asString(json['module_title']) ??
          'Your next YogaFX session is ready.',
      description:
          _asString(json['description']) ??
          _asString(json['summary']) ??
          _asString(json['excerpt']) ??
          'Pick up where you left off and keep your momentum moving.',
      primaryActionLabel:
          _asString(json['primary_action_label']) ??
          _asString(json['primary_cta']) ??
          'Resume',
      secondaryActionLabel:
          _asString(json['secondary_action_label']) ??
          _asString(json['secondary_cta']) ??
          'View details',
    );
  }

  final String eyebrow;
  final String title;
  final String description;
  final String primaryActionLabel;
  final String secondaryActionLabel;
}

class DashboardMetric {
  const DashboardMetric({required this.label, required this.value});

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      label: _asString(json['label']) ?? 'Metric',
      value:
          _asString(json['value']) ??
          _asString(json['count']) ??
          _asString(json['total']) ??
          '--',
    );
  }

  final String label;
  final String value;
}

class DashboardSection {
  const DashboardSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  factory DashboardSection.fromJson(Map<String, dynamic> json) {
    final items = _asList(json['items'])
        .map((item) => DashboardCardItem.fromJson(_asMap(item) ?? const {}))
        .where((item) => item.title.isNotEmpty)
        .toList();

    return DashboardSection(
      title:
          _asString(json['title']) ?? _asString(json['name']) ?? 'Highlights',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          'Recommended for your next session.',
      items: items,
    );
  }

  final String title;
  final String subtitle;
  final List<DashboardCardItem> items;
}

class DashboardCardItem {
  const DashboardCardItem({
    required this.title,
    required this.subtitle,
    required this.durationLabel,
    required this.badge,
  });

  factory DashboardCardItem.fromJson(Map<String, dynamic> json) {
    return DashboardCardItem(
      title:
          _asString(json['title']) ??
          _asString(json['name']) ??
          _asString(json['lesson_title']) ??
          '',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          _asString(json['module_name']) ??
          'YogaFX content',
      durationLabel:
          _asString(json['duration']) ??
          _asString(json['duration_label']) ??
          _asString(json['progress_label']) ??
          'Open',
      badge:
          _asString(json['badge']) ??
          _asString(json['tag']) ??
          _asString(json['status']),
    );
  }

  final String title;
  final String subtitle;
  final String durationLabel;
  final String? badge;
}

List<DashboardMetric> _parseMetrics(Map<String, dynamic> json) {
  final directMetrics = _asList(
    json['metrics'],
  ).map((item) => DashboardMetric.fromJson(_asMap(item) ?? const {})).toList();
  if (directMetrics.isNotEmpty) {
    return directMetrics;
  }

  final progressSummary =
      _asMap(json['progress_summary']) ?? _asMap(json['progressSummary']);
  if (progressSummary != null && progressSummary.isNotEmpty) {
    return progressSummary.entries
        .map(
          (entry) => DashboardMetric(
            label: _labelizeKey(entry.key),
            value: _asString(entry.value) ?? '--',
          ),
        )
        .toList();
  }

  return const [
    DashboardMetric(label: 'Progress', value: '--'),
    DashboardMetric(label: 'Modules', value: '--'),
    DashboardMetric(label: 'Assignments', value: '--'),
  ];
}

List<DashboardSection> _parseSections(Map<String, dynamic> json) {
  final rawSections = _asList(json['sections'])
      .map((item) => DashboardSection.fromJson(_asMap(item) ?? const {}))
      .where((section) => section.items.isNotEmpty)
      .toList();
  if (rawSections.isNotEmpty) {
    return rawSections;
  }

  final fallbackCollections = <DashboardSection>[];
  final candidates = <String, String>{
    'module_highlights': 'Module highlights',
    'moduleHighlights': 'Module highlights',
    'recommended_lessons': 'Recommended lessons',
    'recommendedLessons': 'Recommended lessons',
    'certificates': 'Certificates',
  };

  for (final entry in candidates.entries) {
    final items = _asList(json[entry.key])
        .map((item) => DashboardCardItem.fromJson(_asMap(item) ?? const {}))
        .where((item) => item.title.isNotEmpty)
        .toList();

    if (items.isNotEmpty) {
      fallbackCollections.add(
        DashboardSection(
          title: entry.value,
          subtitle: 'Pulled from the mobile dashboard payload.',
          items: items,
        ),
      );
    }
  }

  if (fallbackCollections.isNotEmpty) {
    return fallbackCollections;
  }

  return const [
    DashboardSection(
      title: 'Your dashboard is ready',
      subtitle: 'Connect your backend payload to replace this fallback rail.',
      items: [
        DashboardCardItem(
          title: 'Dashboard payload connected',
          subtitle: 'Module 5 fallback content',
          durationLabel: 'Live',
          badge: 'Ready',
        ),
      ],
    ),
  ];
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
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
  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? null : stringValue;
}

String _labelizeKey(String value) {
  final withSpaces = value.replaceAll(RegExp(r'[_-]+'), ' ');
  if (withSpaces.isEmpty) {
    return 'Metric';
  }

  return withSpaces
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}
