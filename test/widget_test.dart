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

    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('YogaFX Student'), findsOneWidget);
    expect(find.text('Keep your streak moving'), findsOneWidget);
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
      relatedAssessment: const LessonAssessment(
        id: 'assessment-1',
        title: 'Quiz',
        ctaLabel: 'Open assessment',
        isAvailable: false,
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
  @override
  Future<AssignmentDetail> fetchAssignmentDetail(String assignmentId) async {
    return const AssignmentDetail(
      id: 'assignment-1',
      title: 'Daily Reflection Upload',
      description: 'Upload a short practice reflection video.',
      instructions: 'Record your practice, then upload the video file.',
      statusLabel: 'Pending',
      dueLabel: 'No due date',
      canUpload: true,
      latestSubmission: AssignmentSubmission(
        statusLabel: 'No submission yet',
        fileName: '',
        fileUrl: '',
        submittedAtLabel: 'Waiting for upload',
      ),
      feedback: AssignmentFeedback(title: '', message: '', statusLabel: ''),
    );
  }

  @override
  Future<AssignmentSubmissionResult> submitAssignmentVideo({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    return const AssignmentSubmissionResult(
      status: 'submitted',
      summary: 'Assignment uploaded.',
      feedbackLabel: '',
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
