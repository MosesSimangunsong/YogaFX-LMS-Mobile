import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/assessments/data/assessments_repository.dart';
import '../features/assessments/data/assessments_repository_impl.dart';
import '../features/assignments/data/assignments_repository.dart';
import '../features/assignments/data/assignments_repository_impl.dart';
import '../features/certificates/data/certificates_repository.dart';
import '../features/certificates/data/certificates_repository_impl.dart';
import '../features/home/data/dashboard_repository.dart';
import '../features/home/data/dashboard_repository_impl.dart';
import '../features/lessons/data/lessons_repository.dart';
import '../features/lessons/data/lessons_repository_impl.dart';
import '../features/modules/data/modules_repository.dart';
import '../features/modules/data/modules_repository_impl.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/data/profile_repository_impl.dart';

final sessionInvalidationProvider = StateProvider<int>((ref) => 0);

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig override is required at startup.');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  throw UnimplementedError('TokenStorage override is required at startup.');
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  return buildApiClient(
    config: config,
    tokenStorage: tokenStorage,
    onUnauthorized: () async {
      ref.read(sessionInvalidationProvider.notifier).state++;
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final config = ref.watch(appConfigProvider);

  return AuthRepositoryImpl(
    dio: dio,
    tokenStorage: tokenStorage,
    config: config,
  );
});

final assessmentsRepositoryProvider = Provider<AssessmentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return AssessmentsRepositoryImpl(dio: dio, config: config);
});

final assignmentsRepositoryProvider = Provider<AssignmentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return AssignmentsRepositoryImpl(dio: dio, config: config);
});

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return CertificatesRepositoryImpl(dio: dio, config: config);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return DashboardRepositoryImpl(dio: dio, config: config);
});

final modulesRepositoryProvider = Provider<ModulesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return ModulesRepositoryImpl(dio: dio, config: config);
});

final lessonsRepositoryProvider = Provider<LessonsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return LessonsRepositoryImpl(dio: dio, config: config);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);

  return ProfileRepositoryImpl(dio: dio, config: config);
});
