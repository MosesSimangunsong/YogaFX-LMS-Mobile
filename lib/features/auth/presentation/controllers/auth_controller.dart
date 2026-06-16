import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/app_user.dart';
import '../../domain/auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  bool _didBootstrap = false;

  @override
  AuthState build() {
    ref.listen<int>(sessionInvalidationProvider, (previous, next) {
      if ((previous ?? 0) == next) {
        return;
      }

      state = const AuthState.unauthenticated(
        errorMessage: 'Your session has expired. Please log in again.',
      );
    });

    if (!_didBootstrap) {
      _didBootstrap = true;
      Future<void>(_restoreSession);
    }

    return const AuthState.checking();
  }

  Future<void> login({required String email, required String password}) async {
    if (state.isSubmitting) {
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      state = AuthState.authenticated(user);
    } catch (error) {
      state = const AuthState.unauthenticated().copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  void replaceUser(AppUser user) {
    final currentUser = state.user;
    if (state.status != AuthStatus.authenticated || currentUser == null) {
      return;
    }

    state = AuthState.authenticated(user);
  }

  Future<void> _restoreSession() async {
    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      if (user == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      state = AuthState.authenticated(user);
    } catch (error) {
      state = const AuthState.unauthenticated().copyWith(
        errorMessage: error.toString(),
      );
    }
  }
}
