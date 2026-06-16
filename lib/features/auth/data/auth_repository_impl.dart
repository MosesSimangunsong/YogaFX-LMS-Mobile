import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required TokenStorage tokenStorage,
    required AppConfig config,
  }) : _dio = dio,
       _tokenStorage = tokenStorage,
       _config = config;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final AppConfig _config;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.resolvePath('/auth/login'),
        data: {'email': email, 'password': password},
      );

      final body = response.data ?? <String, dynamic>{};
      final token = _extractToken(body);
      if (token == null || token.isEmpty) {
        throw const NetworkException(
          'Login succeeded but no auth token was returned.',
        );
      }

      await _tokenStorage.writeToken(token);

      final userPayload = _extractUserPayload(body);
      if (userPayload != null) {
        return AppUser.fromJson(userPayload);
      }

      return _fetchCurrentUser();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>(_config.resolvePath('/auth/logout'));
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != 401) {
        throw mapDioException(error);
      }
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await _fetchCurrentUser();
    } on DioException catch (error) {
      await _tokenStorage.clearToken();
      if (error.response?.statusCode == 401) {
        return null;
      }
      throw mapDioException(error);
    }
  }

  Future<AppUser> _fetchCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _config.resolvePath('/me'),
    );

    final body = response.data ?? <String, dynamic>{};
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        return AppUser.fromJson(user);
      }
      return AppUser.fromJson(data);
    }

    final user = body['user'];
    if (user is Map<String, dynamic>) {
      return AppUser.fromJson(user);
    }

    return AppUser.fromJson(body);
  }

  String? _extractToken(Map<String, dynamic> body) {
    final topLevel = body['token'];
    if (topLevel is String && topLevel.isNotEmpty) {
      return topLevel;
    }

    final accessToken = body['access_token'];
    if (accessToken is String && accessToken.isNotEmpty) {
      return accessToken;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['token'];
      if (nestedToken is String && nestedToken.isNotEmpty) {
        return nestedToken;
      }

      final nestedAccessToken = data['access_token'];
      if (nestedAccessToken is String && nestedAccessToken.isNotEmpty) {
        return nestedAccessToken;
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic> body) {
    final user = body['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      if (data.containsKey('id') || data.containsKey('email')) {
        return data;
      }
    }

    return null;
  }
}
