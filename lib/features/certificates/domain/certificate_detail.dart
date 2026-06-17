class CertificateDetail {
  const CertificateDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.issuedLabel,
    required this.fileUrl,
    required this.downloadUrl,
    required this.eligibilityLabel,
    required this.recipientName,
  });

  factory CertificateDetail.fromJson(Map<String, dynamic> json) {
    final file =
        _asMap(json['file']) ?? _asMap(json['certificate_file']) ?? const {};

    return CertificateDetail(
      id:
          _asString(json['id']) ??
          _asString(json['certificate_id']) ??
          _asString(json['slug']) ??
          '',
      title:
          _asString(json['title']) ?? _asString(json['name']) ?? 'Certificate',
      description:
          _asString(json['description']) ??
          _asString(json['summary']) ??
          'Your YogaFX completion certificate is ready to be opened or downloaded.',
      statusLabel:
          _asString(json['status']) ??
          _asString(json['visibility']) ??
          'Available',
      issuedLabel:
          _asString(json['issued_at_label']) ??
          _asString(json['issued_at']) ??
          _asString(json['issued_on']) ??
          _asString(json['date']) ??
          'Ready to view',
      fileUrl:
          _asString(json['file_url']) ??
          _asString(json['url']) ??
          _asString(file['url']) ??
          _asString(file['file_url']) ??
          _asString(json['open_url']) ??
          _asString(json['preview_url']) ??
          '',
      downloadUrl:
          _asString(json['download_url']) ??
          _asString(file['download_url']) ??
          _asString(json['pdf_url']) ??
          _asString(json['file_url']) ??
          _asString(json['url']) ??
          '',
      eligibilityLabel:
          _asString(json['eligibility']) ??
          _asString(json['eligibility_label']) ??
          'Eligible',
      recipientName:
          _asString(json['recipient_name']) ??
          _asString(json['student_name']) ??
          _asString(json['name_on_certificate']) ??
          'YogaFX Student',
    );
  }

  final String id;
  final String title;
  final String description;
  final String statusLabel;
  final String issuedLabel;
  final String fileUrl;
  final String downloadUrl;
  final String eligibilityLabel;
  final String recipientName;

  bool get canOpen => openUri != null || downloadUri != null;
  Uri? get openUri => _asHttpUri(fileUrl);
  Uri? get downloadUri => _asHttpUri(downloadUrl);
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
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

Uri? _asHttpUri(Object? value) {
  final text = _asString(value);
  if (text == null) {
    return null;
  }

  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return null;
  }

  return switch (uri.scheme.toLowerCase()) {
    'http' || 'https' => uri,
    _ => null,
  };
}
