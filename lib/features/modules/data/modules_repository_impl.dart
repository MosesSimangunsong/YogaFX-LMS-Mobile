import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/module_detail.dart';
import '../domain/module_summary.dart';
import 'modules_repository.dart';

class ModulesRepositoryImpl implements ModulesRepository {
  ModulesRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<ModuleDetail> fetchModuleDetail(String moduleId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/modules/$moduleId'),
      );
      final body = response.data ?? <String, dynamic>{};
      return ModuleDetail.fromJson(_extractPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<ModuleSummary>> fetchModules() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/modules'),
      );
      final body = response.data ?? <String, dynamic>{};
      final payload = _extractPayload(body);
      final rawList = _extractList(payload);

      final modules = rawList
          .map((item) => ModuleSummary.fromJson(_asMap(item) ?? const {}))
          .where((item) => item.id.isNotEmpty || item.title.isNotEmpty)
          .toList();

      if (modules.isNotEmpty) {
        return modules;
      }

      return const [
        ModuleSummary(
          id: 'module-foundation',
          title: 'Module payload connected',
          subtitle: 'Fallback module while waiting for backend list data.',
          progressLabel: '0%',
          itemCountLabel: '0 items',
          badge: 'Ready',
          accentIndex: 0,
        ),
      ];
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return body;
  }

  List<dynamic> _extractList(Map<String, dynamic> payload) {
    final dataList = payload['data'];
    if (dataList is List) {
      return dataList;
    }

    final modules = payload['modules'];
    if (modules is List) {
      return modules;
    }

    if (payload case {'items': List<dynamic> items}) {
      return items;
    }

    return const [];
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}
