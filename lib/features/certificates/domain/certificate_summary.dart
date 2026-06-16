class CertificateSummary {
  const CertificateSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.issuedLabel,
    required this.badge,
  });

  factory CertificateSummary.fromJson(Map<String, dynamic> json) {
    return CertificateSummary(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title:
          _asString(json['title']) ?? _asString(json['name']) ?? 'Certificate',
      subtitle:
          _asString(json['subtitle']) ??
          _asString(json['description']) ??
          _asString(json['module_title']) ??
          'YogaFX completion certificate',
      statusLabel:
          _asString(json['status']) ??
          _asString(json['visibility']) ??
          'Available',
      issuedLabel:
          _asString(json['issued_at_label']) ??
          _asString(json['issued_at']) ??
          _asString(json['date']) ??
          'Ready to view',
      badge:
          _asString(json['badge']) ??
          _asString(json['eligibility']) ??
          _asString(json['state']),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String statusLabel;
  final String issuedLabel;
  final String? badge;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
