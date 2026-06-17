import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_lms/app/app.dart';
import 'package:mobile_lms/app/providers.dart' as app_providers;
import 'package:mobile_lms/core/config/app_config.dart';
import 'package:mobile_lms/core/storage/token_storage.dart';
import 'package:mobile_lms/features/auth/data/auth_repository.dart';
import 'package:mobile_lms/features/auth/domain/app_user.dart';
import 'package:mobile_lms/features/assessments/data/assessments_repository.dart';
import 'package:mobile_lms/features/assessments/domain/assessment_result.dart';
import 'package:mobile_lms/features/assessments/domain/assessment_session.dart';
import 'package:mobile_lms/features/assignments/data/assignments_repository.dart';
import 'package:mobile_lms/features/assignments/domain/assignment_detail.dart';
import 'package:mobile_lms/features/assignments/domain/assignment_submission_result.dart';
import 'package:mobile_lms/features/assignments/presentation/screens/assignment_detail_screen.dart';
import 'package:mobile_lms/features/certificates/data/certificates_repository.dart';
import 'package:mobile_lms/features/certificates/domain/certificate_detail.dart';
import 'package:mobile_lms/features/certificates/domain/certificate_summary.dart';
import 'package:mobile_lms/features/home/data/dashboard_repository.dart';
import 'package:mobile_lms/features/home/domain/dashboard_data.dart';
import 'package:mobile_lms/features/lessons/data/lessons_repository.dart';
import 'package:mobile_lms/features/lessons/domain/lesson_detail.dart';
import 'package:mobile_lms/features/modules/data/modules_repository.dart';
import 'package:mobile_lms/features/modules/domain/module_detail.dart';
import 'package:mobile_lms/features/modules/domain/module_summary.dart';
import 'package:mobile_lms/features/profile/data/profile_repository.dart';
import 'package:mobile_lms/features/profile/domain/password_change_request.dart';
import 'package:mobile_lms/features/profile/domain/student_profile.dart';

void main() {
  testWidgets('shows login screen when no session is restored', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            _FakeAssignmentsRepository(),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('YogaFX Student'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('shows authenticated home when a session is restored', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              restoredUser: const AppUser(
                id: '42',
                email: 'student@example.com',
                name: 'YogaFX Student',
              ),
            ),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            _FakeAssignmentsRepository(),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('YogaFX Student'), findsOneWidget);
    expect(find.text('Keep your streak moving'), findsWidgets);
  });

  testWidgets('opens modules tab and keeps it distinct from home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              restoredUser: const AppUser(
                id: '42',
                email: 'student@example.com',
                name: 'YogaFX Student',
              ),
            ),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            _FakeAssignmentsRepository(),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Keep your streak moving'), findsWidgets);

    await tester.tap(find.text('Modules').last);
    await tester.pumpAndSettle();

    expect(find.text('Featured modules'), findsOneWidget);
    expect(find.text('All modules'), findsOneWidget);
    expect(find.text('Keep your streak moving'), findsNothing);
  });

  testWidgets(
    'continue learning opens lesson detail when module and lesson ids exist',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            app_providers.appConfigProvider.overrideWithValue(
              const AppConfig(
                apiBaseUrl: 'https://example.com',
                mobileApiPrefix: '/api/mobile/v1',
                connectTimeoutMs: 1000,
                receiveTimeoutMs: 1000,
                enableNetworkLogs: false,
              ),
            ),
            app_providers.tokenStorageProvider.overrideWithValue(
              _InMemoryTokenStorage(),
            ),
            app_providers.authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(
                restoredUser: const AppUser(
                  id: '42',
                  email: 'student@example.com',
                  name: 'YogaFX Student',
                ),
              ),
            ),
            app_providers.assessmentsRepositoryProvider.overrideWithValue(
              _FakeAssessmentsRepository(),
            ),
            app_providers.assignmentsRepositoryProvider.overrideWithValue(
              _FakeAssignmentsRepository(),
            ),
            app_providers.certificatesRepositoryProvider.overrideWithValue(
              _FakeCertificatesRepository(),
            ),
            app_providers.dashboardRepositoryProvider.overrideWithValue(
              _FakeDashboardRepository(),
            ),
            app_providers.modulesRepositoryProvider.overrideWithValue(
              _FakeModulesRepository(),
            ),
            app_providers.lessonsRepositoryProvider.overrideWithValue(
              _FakeLessonsRepository(),
            ),
            app_providers.profileRepositoryProvider.overrideWithValue(
              _FakeProfileRepository(),
            ),
          ],
          child: const MobileLmsApp(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      expect(find.text('Lesson detail test body.'), findsOneWidget);
      expect(find.text('Progress sync'), findsOneWidget);
    },
  );

  testWidgets('lesson assessment can be opened and submitted safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              restoredUser: const AppUser(
                id: '42',
                email: 'student@example.com',
                name: 'YogaFX Student',
              ),
            ),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            _FakeAssignmentsRepository(),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(assessmentAvailable: true),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(find.text('Open assessment'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open assessment'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson quiz'), findsOneWidget);
    expect(find.text('How do you feel after the lesson?'), findsOneWidget);

    await tester.tap(find.text('Strong'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit assessment'));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text('Assessment result'), findsOneWidget);
    expect(find.text('Score: 100'), findsOneWidget);
    expect(find.text('Assessment submitted.'), findsWidgets);
  });

  testWidgets('module assignment detail can upload safely and refresh status', (
    tester,
  ) async {
    final assignmentsRepository = _FakeAssignmentsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              restoredUser: const AppUser(
                id: '42',
                email: 'student@example.com',
                name: 'YogaFX Student',
              ),
            ),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            assignmentsRepository,
          ),
          assignmentVideoPickerProvider.overrideWithValue(
            () async => const PickedAssignmentVideo(
              path: 'D:/tmp/practice.mp4',
              name: 'practice.mp4',
            ),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Modules').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Core Flow Foundations').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Reflection Upload'));
    await tester.pumpAndSettle();

    expect(
      find.text('Record your practice, then upload the video file.'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(find.text('Pick video'), findsOneWidget);

    await tester.tap(find.text('Pick video'));
    await tester.pumpAndSettle();

    expect(find.text('practice.mp4'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload video').last);
    await tester.pumpAndSettle();

    expect(find.text('Assignment uploaded.'), findsWidgets);

    await tester.tap(find.text('Refresh assignment'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, 650));
    await tester.pumpAndSettle();

    expect(find.text('Under review'), findsOneWidget);
    expect(find.text('practice.mp4'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(find.text('Your upload is in the review queue.'), findsOneWidget);
  });

  testWidgets('profile certificates open list and detail safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_providers.appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'https://example.com',
              mobileApiPrefix: '/api/mobile/v1',
              connectTimeoutMs: 1000,
              receiveTimeoutMs: 1000,
              enableNetworkLogs: false,
            ),
          ),
          app_providers.tokenStorageProvider.overrideWithValue(
            _InMemoryTokenStorage(),
          ),
          app_providers.authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              restoredUser: const AppUser(
                id: '42',
                email: 'student@example.com',
                name: 'YogaFX Student',
              ),
            ),
          ),
          app_providers.assessmentsRepositoryProvider.overrideWithValue(
            _FakeAssessmentsRepository(),
          ),
          app_providers.assignmentsRepositoryProvider.overrideWithValue(
            _FakeAssignmentsRepository(),
          ),
          app_providers.certificatesRepositoryProvider.overrideWithValue(
            _FakeCertificatesRepository(),
          ),
          app_providers.dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          app_providers.modulesRepositoryProvider.overrideWithValue(
            _FakeModulesRepository(),
          ),
          app_providers.lessonsRepositoryProvider.overrideWithValue(
            _FakeLessonsRepository(),
          ),
          app_providers.profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(),
          ),
        ],
        child: const MobileLmsApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Certificates'));
    await tester.pumpAndSettle();

    expect(find.text('YogaFX Completion Certificate'), findsWidgets);
    expect(find.text('Eligible'), findsWidgets);

    await tester.tap(find.text('YogaFX Completion Certificate').first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Your certificate is ready'), findsOneWidget);
    expect(find.text('YogaFX Student'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.restoredUser});

  final AppUser? restoredUser;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    return restoredUser ?? AppUser(id: '1', email: email, name: 'Student');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> restoreSession() async => restoredUser;
}

class _InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> fetchDashboard() async {
    return DashboardData(
      greetingTitle: 'Keep your streak moving',
      greetingSubtitle: 'Your YogaFX dashboard is connected.',
      continueLearning: const DashboardContinueLearning(
        eyebrow: 'Continue learning',
        title: 'Keep your streak moving',
        description: 'Resume your latest session from the mobile dashboard.',
        primaryActionLabel: 'Resume',
        secondaryActionLabel: 'Details',
        moduleId: 'module-1',
        lessonId: 'lesson-1',
      ),
      metrics: const [
        DashboardMetric(label: 'Progress', value: '68%'),
        DashboardMetric(label: 'Modules', value: '6'),
        DashboardMetric(label: 'Assignments', value: '2'),
      ],
      sections: const [
        DashboardSection(
          title: 'Featured',
          subtitle: 'Recommended content for today.',
          items: [
            DashboardCardItem(
              title: 'Breathwork Reset',
              subtitle: 'Focus rail item',
              durationLabel: '12 min',
              badge: 'New',
              moduleId: 'module-1',
              lessonId: 'lesson-1',
            ),
          ],
        ),
      ],
    );
  }
}

class _FakeModulesRepository implements ModulesRepository {
  @override
  Future<ModuleDetail> fetchModuleDetail(String moduleId) async {
    return ModuleDetail(
      id: moduleId,
      title: 'Core Flow Foundations',
      subtitle: 'Module detail for testing ordered items.',
      progressLabel: '68%',
      completionLabel: 'In progress',
      lessons: const [
        ModuleEntry(
          id: 'lesson-1',
          title: 'Breathwork Reset',
          subtitle: 'Lesson entry',
          trailingLabel: '12 min',
          badge: 'Ready',
        ),
      ],
      assignments: const [
        ModuleEntry(
          id: 'assignment-1',
          title: 'Daily Reflection Upload',
          subtitle: 'Assignment entry',
          trailingLabel: 'Pending',
          badge: 'Upload',
        ),
      ],
    );
  }

  @override
  Future<List<ModuleSummary>> fetchModules() async {
    return const [
      ModuleSummary(
        id: 'module-1',
        title: 'Core Flow Foundations',
        subtitle: 'Module summary for test',
        progressLabel: '68%',
        itemCountLabel: '8 items',
        badge: 'Active',
        accentIndex: 0,
      ),
    ];
  }
}

class _FakeLessonsRepository implements LessonsRepository {
  _FakeLessonsRepository({this.assessmentAvailable = false});

  final bool assessmentAvailable;

  @override
  Future<LessonDetail> fetchLessonDetail(String lessonId) async {
    return LessonDetail(
      id: lessonId,
      title: 'Breathwork Reset',
      body: 'Lesson detail test body.',
      progressLabel: '32%',
      completionLabel: 'In progress',
      video: const LessonVideo(
        title: 'Lesson video',
        hlsUrl: '',
        posterUrl: '',
      ),
      audio: const LessonAudio(title: 'Lesson audio', url: ''),
      workbook: const LessonWorkbook(label: 'Workbook', url: ''),
      relatedAssessment: LessonAssessment(
        id: 'assessment-1',
        title: 'Quiz',
        ctaLabel: 'Open assessment',
        isAvailable: assessmentAvailable,
      ),
    );
  }

  @override
  Future<void> updateLessonProgress({
    required String lessonId,
    int? progressPercent,
    bool? completed,
    String? source,
  }) async {}
}

class _FakeAssessmentsRepository implements AssessmentsRepository {
  @override
  Future<AssessmentSession> fetchAssessment(String assessmentId) async {
    return AssessmentSession(
      id: assessmentId,
      title: 'Lesson quiz',
      description: 'Quick assessment test payload.',
      questions: const [
        AssessmentQuestion(
          id: 'q1',
          prompt: 'How do you feel after the lesson?',
          type: 'single_choice',
          required: true,
          options: [
            AssessmentOption(id: 'a', label: 'Strong'),
            AssessmentOption(id: 'b', label: 'Calm'),
          ],
        ),
      ],
    );
  }

  @override
  Future<AssessmentResult> submitAssessment({
    required String assessmentId,
    required Map<String, dynamic> answers,
  }) async {
    return const AssessmentResult(
      status: 'submitted',
      scoreLabel: '100',
      summary: 'Assessment submitted.',
    );
  }
}

class _FakeAssignmentsRepository implements AssignmentsRepository {
  AssignmentSubmission? _latestSubmission;
  AssignmentFeedback? _feedback;

  @override
  Future<AssignmentDetail> fetchAssignmentDetail(String assignmentId) async {
    return AssignmentDetail(
      id: assignmentId,
      title: 'Daily Reflection Upload',
      description: 'Upload a short practice reflection video.',
      instructions: 'Record your practice, then upload the video file.',
      statusLabel: _latestSubmission == null ? 'Pending' : 'Under review',
      dueLabel: 'No due date',
      canUpload: true,
      latestSubmission:
          _latestSubmission ??
          const AssignmentSubmission(
            statusLabel: 'No submission yet',
            fileName: '',
            fileUrl: '',
            submittedAtLabel: 'Waiting for upload',
          ),
      feedback:
          _feedback ??
          const AssignmentFeedback(title: '', message: '', statusLabel: ''),
    );
  }

  @override
  Future<AssignmentSubmissionResult> submitAssignmentVideo({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    _latestSubmission = AssignmentSubmission(
      statusLabel: 'Under review',
      fileName: fileName,
      fileUrl: 'https://example.com/uploads/$fileName',
      submittedAtLabel: 'Submitted just now',
    );
    _feedback = const AssignmentFeedback(
      title: 'Coach review pending',
      message: 'Your upload is in the review queue.',
      statusLabel: 'Pending review',
    );
    return const AssignmentSubmissionResult(
      status: 'submitted',
      summary: 'Assignment uploaded.',
      feedbackLabel: 'Pending review',
    );
  }
}

class _FakeCertificatesRepository implements CertificatesRepository {
  @override
  Future<CertificateDetail> fetchCertificateDetail(String certificateId) async {
    return const CertificateDetail(
      id: 'certificate-1',
      title: 'YogaFX Completion Certificate',
      description: 'Certificate detail test payload.',
      statusLabel: 'Available',
      issuedLabel: 'Ready to view',
      fileUrl: 'https://example.com/certificate.pdf',
      downloadUrl: 'https://example.com/certificate.pdf',
      eligibilityLabel: 'Eligible',
      recipientName: 'YogaFX Student',
    );
  }

  @override
  Future<List<CertificateSummary>> fetchCertificates() async {
    return const [
      CertificateSummary(
        id: 'certificate-1',
        title: 'YogaFX Completion Certificate',
        subtitle: 'Certificate summary for test',
        statusLabel: 'Available',
        issuedLabel: 'Ready to view',
        badge: 'Eligible',
      ),
    ];
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<void> changePassword(PasswordChangeRequest request) async {}

  @override
  Future<StudentProfile> fetchProfile() async {
    return const StudentProfile(
      id: 'student-1',
      name: 'YogaFX Student',
      email: 'student@example.com',
      phone: '',
      memberSinceLabel: 'Mobile student',
    );
  }

  @override
  Future<StudentProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    return StudentProfile(
      id: 'student-1',
      name: name,
      email: email,
      phone: phone ?? '',
      memberSinceLabel: 'Mobile student',
    );
  }
}
