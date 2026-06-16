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
    return CertificateDetail(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
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
          _asString(json['date']) ??
          'Ready to view',
      fileUrl:
          _asString(json['file_url']) ??
          _asString(json['url']) ??
          _asString(json['open_url']) ??
          '',
      downloadUrl:
          _asString(json['download_url']) ??
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

  bool get canOpen => fileUrl.isNotEmpty || downloadUrl.isNotEmpty;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
