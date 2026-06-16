import 'app_user.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.checking()
    : status = AuthStatus.checking,
      user = null,
      isSubmitting = false,
      errorMessage = null;

  const AuthState.unauthenticated({
    this.isSubmitting = false,
    this.errorMessage,
  }) : status = AuthStatus.unauthenticated,
       user = null;

  const AuthState.authenticated(AppUser this.user, {this.isSubmitting = false})
    : status = AuthStatus.authenticated,
      errorMessage = null;

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
