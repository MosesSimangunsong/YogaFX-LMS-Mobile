import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

Dio buildApiClient({
  required AppConfig config,
  required TokenStorage tokenStorage,
  Future<void> Function()? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStorage.clearToken();
          await onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  if (config.enableNetworkLogs) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '${options.method} ${options.uri}',
            name: 'api.request',
          );
          handler.next(options);
        },
        onError: (error, handler) {
          developer.log(
            '${error.requestOptions.method} ${error.requestOptions.uri} -> ${error.response?.statusCode}',
            name: 'api.error',
            error: error.message,
          );
          handler.next(error);
        },
      ),
    );
  }

  return dio;
}
