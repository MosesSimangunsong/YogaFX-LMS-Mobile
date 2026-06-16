import '../../auth/domain/app_user.dart';

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.memberSinceLabel,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: _asString(json['id']) ?? _asString(json['student_id']) ?? '',
      name:
          _asString(json['name']) ??
          _asString(json['full_name']) ??
          _asString(json['student_name']) ??
          'YogaFX Student',
      email: _asString(json['email']) ?? 'student@example.com',
      phone:
          _asString(json['phone']) ??
          _asString(json['phone_number']) ??
          _asString(json['whatsapp']) ??
          '',
      memberSinceLabel:
          _asString(json['member_since_label']) ??
          _asString(json['joined_at_label']) ??
          _asString(json['created_at']) ??
          'Mobile student',
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final String memberSinceLabel;

  AppUser toAppUser() => AppUser(id: id, email: email, name: name);
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
