class PasswordChangeRequest {
  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    };
  }
}
