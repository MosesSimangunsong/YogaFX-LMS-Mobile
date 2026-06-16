import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/student_profile.dart';

final profileControllerProvider = FutureProvider.autoDispose<StudentProfile>((
  ref,
) {
  return ref.read(app_providers.profileRepositoryProvider).fetchProfile();
});

final profileUpdateControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileUpdateController, StudentProfile?>(
      ProfileUpdateController.new,
    );

class ProfileUpdateController
    extends AutoDisposeAsyncNotifier<StudentProfile?> {
  @override
  Future<StudentProfile?> build() async => null;

  Future<StudentProfile> submit({
    required String name,
    required String email,
    String? phone,
  }) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      final profile = await ref
          .read(app_providers.profileRepositoryProvider)
          .updateProfile(name: name, email: email, phone: phone);

      ref
          .read(authControllerProvider.notifier)
          .replaceUser(profile.toAppUser());
      ref.invalidate(profileControllerProvider);

      return profile;
    });
    state = nextState;
    return nextState.requireValue;
  }
}
