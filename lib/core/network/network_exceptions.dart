import 'package:dio/dio.dart';

class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

NetworkException mapDioException(DioException error) {
  final responseData = error.response?.data;
  final statusCode = error.response?.statusCode;

  if (responseData is Map<String, dynamic>) {
    final message = responseData['message'];
    if (message is String && message.trim().isNotEmpty) {
      return NetworkException(message);
    }

    final errors = responseData['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return NetworkException(value.first as String);
        }
      }
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException('Connection timed out. Please try again.');
    case DioExceptionType.badCertificate:
      return const NetworkException(
        'The server certificate could not be verified.',
      );
    case DioExceptionType.connectionError:
      return const NetworkException('Unable to reach the server.');
    case DioExceptionType.cancel:
      return const NetworkException('The request was cancelled.');
    case DioExceptionType.badResponse:
      if (statusCode == 401) {
        return const NetworkException(
          'Your session has expired. Please log in again.',
        );
      }
      if (statusCode == 403) {
        return const NetworkException(
          'You do not have access to this resource.',
        );
      }
      return const NetworkException(
        'The server returned an unexpected response.',
      );
    case DioExceptionType.unknown:
      return const NetworkException(
        'Something went wrong while contacting the server.',
      );
  }
}
