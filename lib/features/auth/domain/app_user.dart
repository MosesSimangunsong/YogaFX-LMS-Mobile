class AppUser {
  const AppUser({required this.id, required this.email, required this.name});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _stringValue(json['id']) ?? '',
      email: _stringValue(json['email']) ?? '',
      name:
          _stringValue(json['name']) ??
          _stringValue(json['full_name']) ??
          _stringValue(json['student_name']) ??
          'Student',
    );
  }

  final String id;
  final String email;
  final String name;

  static String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}
