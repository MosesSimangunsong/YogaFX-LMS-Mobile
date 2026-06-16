import '../domain/password_change_request.dart';
import '../domain/student_profile.dart';

abstract class ProfileRepository {
  Future<StudentProfile> fetchProfile();

  Future<StudentProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  });

  Future<void> changePassword(PasswordChangeRequest request);
}
