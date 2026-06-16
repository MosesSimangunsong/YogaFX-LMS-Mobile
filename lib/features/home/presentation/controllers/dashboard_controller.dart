import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/dashboard_data.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardData>(
      DashboardController.new,
    );

class DashboardController extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() {
    return ref.read(app_providers.dashboardRepositoryProvider).fetchDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(app_providers.dashboardRepositoryProvider).fetchDashboard(),
    );
  }
}
