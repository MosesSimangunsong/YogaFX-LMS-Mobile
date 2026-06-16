import '../domain/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser?> restoreSession();

  Future<void> logout();
}
