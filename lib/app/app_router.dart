import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assessments/presentation/screens/assessment_screen.dart';
import '../features/assignments/presentation/screens/assignment_detail_screen.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/certificates/presentation/screens/certificate_detail_screen.dart';
import '../features/certificates/presentation/screens/certificates_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/lessons/presentation/screens/lesson_detail_screen.dart';
import '../features/modules/presentation/screens/module_detail_screen.dart';
import '../features/modules/presentation/screens/modules_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.routePath,
                name: HomeScreen.routeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ModulesScreen.routePath,
                name: ModulesScreen.routeName,
                builder: (context, state) => const ModulesScreen(),
                routes: [
                  GoRoute(
                    path: ':moduleId',
                    name: ModuleDetailScreen.routeName,
                    builder: (context, state) {
                      final moduleId = state.pathParameters['moduleId'] ?? '';
                      return ModuleDetailScreen(moduleId: moduleId);
                    },
                    routes: [
                      GoRoute(
                        path: 'assignments/:assignmentId',
                        name: AssignmentDetailScreen.routeName,
                        builder: (context, state) {
                          final moduleId =
                              state.pathParameters['moduleId'] ?? '';
                          final assignmentId =
                              state.pathParameters['assignmentId'] ?? '';
                          return AssignmentDetailScreen(
                            moduleId: moduleId,
                            assignmentId: assignmentId,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'lessons/:lessonId',
                        name: LessonDetailScreen.routeName,
                        builder: (context, state) {
                          final moduleId =
                              state.pathParameters['moduleId'] ?? '';
                          final lessonId =
                              state.pathParameters['lessonId'] ?? '';
                          return LessonDetailScreen(
                            moduleId: moduleId,
                            lessonId: lessonId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'assessments/:assessmentId',
                            name: AssessmentScreen.routeName,
                            builder: (context, state) {
                              final moduleId =
                                  state.pathParameters['moduleId'] ?? '';
                              final lessonId =
                                  state.pathParameters['lessonId'] ?? '';
                              final assessmentId =
                                  state.pathParameters['assessmentId'] ?? '';
                              return AssessmentScreen(
                                moduleId: moduleId,
                                lessonId: lessonId,
                                assessmentId: assessmentId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileScreen.routePath,
                name: ProfileScreen.routeName,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: EditProfileScreen.routeName,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'password',
                    name: ChangePasswordScreen.routeName,
                    builder: (context, state) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'certificates',
                    name: CertificatesScreen.routeName,
                    builder: (context, state) => const CertificatesScreen(),
                    routes: [
                      GoRoute(
                        path: ':certificateId',
                        name: CertificateDetailScreen.routeName,
                        builder: (context, state) {
                          final certificateId =
                              state.pathParameters['certificateId'] ?? '';
                          return CertificateDetailScreen(
                            certificateId: certificateId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (authState.status == AuthStatus.checking) {
        return location == SplashScreen.routePath
            ? null
            : SplashScreen.routePath;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return location == LoginScreen.routePath ? null : LoginScreen.routePath;
      }

      if (location == SplashScreen.routePath ||
          location == LoginScreen.routePath ||
          !_isShellLocation(location)) {
        return HomeScreen.routePath;
      }

      return null;
    },
  );
});

bool _isShellLocation(String location) {
  if (location == HomeScreen.routePath ||
      location == ModulesScreen.routePath ||
      location == ProfileScreen.routePath) {
    return true;
  }

  return location.startsWith('${ModulesScreen.routePath}/') ||
      location.startsWith('${ProfileScreen.routePath}/');
}
