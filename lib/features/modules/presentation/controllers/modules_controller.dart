import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/module_summary.dart';

final modulesControllerProvider =
    AsyncNotifierProvider<ModulesController, List<ModuleSummary>>(
      ModulesController.new,
    );

class ModulesController extends AsyncNotifier<List<ModuleSummary>> {
  @override
  Future<List<ModuleSummary>> build() {
    return ref.read(app_providers.modulesRepositoryProvider).fetchModules();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(app_providers.modulesRepositoryProvider).fetchModules(),
    );
  }
}
