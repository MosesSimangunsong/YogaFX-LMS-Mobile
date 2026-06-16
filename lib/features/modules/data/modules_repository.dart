import '../domain/module_detail.dart';
import '../domain/module_summary.dart';

abstract interface class ModulesRepository {
  Future<List<ModuleSummary>> fetchModules();

  Future<ModuleDetail> fetchModuleDetail(String moduleId);
}
