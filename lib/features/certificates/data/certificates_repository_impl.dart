import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/certificate_detail.dart';
import '../domain/certificate_summary.dart';
import 'certificates_repository.dart';

class CertificatesRepositoryImpl implements CertificatesRepository {
  CertificatesRepositoryImpl({required Dio dio, required AppConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<CertificateDetail> fetchCertificateDetail(String certificateId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/certificates/$certificateId'),
      );
      final body = response.data ?? <String, dynamic>{};
      return CertificateDetail.fromJson(_extractDetailPayload(body));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<CertificateSummary>> fetchCertificates() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvePath('/certificates'),
      );
      final body = response.data ?? <String, dynamic>{};
      final payload = _extractPayload(body);
      final items = _extractList(payload);

      return items
          .map((item) => CertificateSummary.fromJson(_asMap(item) ?? const {}))
          .where((item) => item.id.isNotEmpty || item.title.isNotEmpty)
          .toList();
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

  Map<String, dynamic> _extractDetailPayload(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final certificate = data['certificate'];
      if (certificate is Map<String, dynamic>) {
        return {...data, ...certificate}..remove('certificate');
      }
      return data;
    }

    final certificate = body['certificate'];
    if (certificate is Map<String, dynamic>) {
      return {...body, ...certificate}..remove('certificate');
    }

    return body;
  }

  List<dynamic> _extractList(Map<String, dynamic> payload) {
    final dataList = payload['data'];
    if (dataList is List) {
      return dataList;
    }

    final certificates = payload['certificates'];
    if (certificates is List) {
      return certificates;
    }

    if (payload case {'items': List<dynamic> items}) {
      return items;
    }

    if (payload case {'results': List<dynamic> results}) {
      return results;
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
