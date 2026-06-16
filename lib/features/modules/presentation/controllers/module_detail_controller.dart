import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/module_detail.dart';

final moduleDetailControllerProvider = FutureProvider.family
    .autoDispose<ModuleDetail, String>((ref, moduleId) {
      return ref
          .read(app_providers.modulesRepositoryProvider)
          .fetchModuleDetail(moduleId);
    });
