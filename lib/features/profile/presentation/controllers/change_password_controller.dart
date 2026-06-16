import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/password_change_request.dart';

final changePasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ChangePasswordController, void>(
      ChangePasswordController.new,
    );

class ChangePasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(PasswordChangeRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(app_providers.profileRepositoryProvider)
          .changePassword(request),
    );
  }
}
