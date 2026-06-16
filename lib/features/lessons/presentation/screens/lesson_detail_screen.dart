import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/external_launcher.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../../assessments/presentation/screens/assessment_screen.dart';
import '../../domain/lesson_detail.dart';
import '../controllers/lesson_detail_controller.dart';
import '../controllers/lesson_progress_controller.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
  });

  static const routeName = 'lesson-detail';
  static const routePath = '/modules/:moduleId/lessons/:lessonId';

  final String moduleId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonDetailControllerProvider(lessonId));

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(lessonDetailControllerProvider(lessonId));
              await ref.read(lessonDetailControllerProvider(lessonId).future);
            },
            child: state.when(
              data: (lesson) =>
                  _LessonDetailContent(moduleId: moduleId, lesson: lesson),
              loading: () => const _LessonDetailLoadingState(),
              error: (error, _) => AppErrorView(message: error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonDetailContent extends ConsumerWidget {
  const _LessonDetailContent({required this.moduleId, required this.lesson});

  final String moduleId;
  final LessonDetail lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressState = ref.watch(
      lessonProgressControllerProvider(lesson.id),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Module $moduleId', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(lesson.title, style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.body, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              ShellMetricStrip(
                items: [
                  ShellMetricItem(
                    label: 'Progress',
                    value: lesson.progressLabel,
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFF63D2A1),
                  ),
                  ShellMetricItem(
                    label: 'Status',
                    value: lesson.completionLabel,
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFFFFB347),
                  ),
                  ShellMetricItem(
                    label: 'Video',
                    value: lesson.video.isAvailable ? 'Ready' : 'Missing',
                    icon: Icons.video_library_rounded,
                    iconColor: const Color(0xFF89C2FF),
                  ),
                  ShellMetricItem(
                    label: 'Audio',
                    value: lesson.audio.isAvailable ? 'Ready' : 'Missing',
                    icon: Icons.graphic_eq_rounded,
                    iconColor: const Color(0xFFFF8A80),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Progress sync',
          subtitle:
              'Push lesson progress updates to the backend and refresh related student state.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep mobile and web aligned',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'These actions post progress back to the backend, then refresh lesson, module, modules list, and dashboard states.',
                style: theme.textTheme.bodyMedium,
              ),
              if (progressState.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  progressState.error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: progressState.isLoading
                        ? null
                        : () => ref
                              .read(
                                lessonProgressControllerProvider(
                                  lesson.id,
                                ).notifier,
                              )
                              .syncProgress(
                                moduleId: moduleId,
                                progressPercent: 50,
                                completed: false,
                                source: 'mobile_lesson_screen',
                              ),
                    icon: progressState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: const Text('Sync 50%'),
                  ),
                  OutlinedButton.icon(
                    onPressed: progressState.isLoading
                        ? null
                        : () => ref
                              .read(
                                lessonProgressControllerProvider(
                                  lesson.id,
                                ).notifier,
                              )
                              .syncProgress(
                                moduleId: moduleId,
                                progressPercent: 100,
                                completed: true,
                                source: 'mobile_lesson_screen',
                              ),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Mark complete'),
                  ),
                  TextButton.icon(
                    onPressed: progressState.isLoading
                        ? null
                        : () => ref.invalidate(
                            lessonDetailControllerProvider(lesson.id),
                          ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh lesson'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Lesson video',
          subtitle: 'HLS-ready lesson video player for mobile consumption.',
        ),
        const SizedBox(height: 16),
        lesson.video.isAvailable
            ? _LessonVideoCard(video: lesson.video)
            : const SizedBox(
                height: 220,
                child: AppEmptyView(
                  title: 'No lesson video',
                  message:
                      'This lesson did not include a playable video source.',
                  icon: Icons.video_library_outlined,
                ),
              ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Lesson audio',
          subtitle:
              'Stream mobile audio directly from the backend-provided URL.',
        ),
        const SizedBox(height: 16),
        lesson.audio.isAvailable
            ? _LessonAudioCard(audio: lesson.audio)
            : const SizedBox(
                height: 180,
                child: AppEmptyView(
                  title: 'No lesson audio',
                  message: 'There is no audio attachment on this lesson yet.',
                  icon: Icons.headphones_outlined,
                ),
              ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Workbook',
          subtitle:
              'Open or download workbook files from the existing backend.',
        ),
        const SizedBox(height: 16),
        _WorkbookCard(workbook: lesson.workbook),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Assessment',
          subtitle:
              'Related assessment CTA placeholder before the full assessment module.',
        ),
        const SizedBox(height: 16),
        _AssessmentCard(
          moduleId: moduleId,
          lessonId: lesson.id,
          assessment: lesson.relatedAssessment,
        ),
      ],
    );
  }
}

class _LessonVideoCard extends StatefulWidget {
  const _LessonVideoCard({required this.video});

  final LessonVideo video;

  @override
  State<_LessonVideoCard> createState() => _LessonVideoCardState();
}

class _LessonVideoCardState extends State<_LessonVideoCard> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.video.hlsUrl));
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Video could not be initialized on this device.';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.video.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: _controller.value.isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: Colors.black),
                  if (_controller.value.isInitialized)
                    VideoPlayer(_controller)
                  else if (_isLoading)
                    const ShellSkeleton(height: double.infinity, radius: 0)
                  else
                    AppEmptyView(
                      title: 'Video unavailable',
                      message:
                          _errorMessage ??
                          'This lesson video could not be loaded.',
                      icon: Icons.error_outline_rounded,
                    ),
                  if (_controller.value.isInitialized)
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonAudioCard extends StatefulWidget {
  const _LessonAudioCard({required this.audio});

  final LessonAudio audio;

  @override
  State<_LessonAudioCard> createState() => _LessonAudioCardState();
}

class _LessonAudioCardState extends State<_LessonAudioCard> {
  late final AudioPlayer _player = AudioPlayer();
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      await _player.setUrl(widget.audio.url);
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Audio could not be prepared on this device.';
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.audio.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          if (_errorMessage != null)
            Text(_errorMessage!, style: theme.textTheme.bodyMedium)
          else if (!_isReady)
            const ShellSkeleton(height: 48, radius: 18)
          else
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final isPlaying = state?.playing ?? false;

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(isPlaying ? 'Pause audio' : 'Play audio'),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _WorkbookCard extends StatelessWidget {
  const _WorkbookCard({required this.workbook});

  final LessonWorkbook workbook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: workbook.isAvailable
          ? Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_open_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    workbook.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) {
                      await launchExternalUrl(
                        context,
                        workbook.url,
                        errorMessage:
                            'The workbook file could not be opened on this device.',
                      );
                    }
                  },
                  child: const Text('Open'),
                ),
              ],
            )
          : const AppEmptyView(
              title: 'No workbook attached',
              message: 'This lesson does not include a workbook file yet.',
              icon: Icons.file_present_outlined,
            ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.moduleId,
    required this.lessonId,
    required this.assessment,
  });

  final String moduleId;
  final String lessonId;
  final LessonAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: assessment.isAvailable
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assessment.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Assessment flow will connect here in the next module while keeping lesson detail stable.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: assessment.id.isEmpty
                      ? null
                      : () => context.pushNamed(
                          AssessmentScreen.routeName,
                          pathParameters: {
                            'moduleId': moduleId,
                            'lessonId': lessonId,
                            'assessmentId': assessment.id,
                          },
                        ),
                  icon: const Icon(Icons.quiz_rounded),
                  label: Text(assessment.ctaLabel),
                ),
              ],
            )
          : const AppEmptyView(
              title: 'No related assessment',
              message:
                  'This lesson does not expose a linked assessment right now.',
              icon: Icons.quiz_outlined,
            ),
    );
  }
}

class _LessonDetailLoadingState extends StatelessWidget {
  const _LessonDetailLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        Row(
          children: const [
            ShellSkeleton(height: 44, width: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShellSkeleton(height: 12, width: 120, radius: 8),
                  SizedBox(height: 8),
                  ShellSkeleton(height: 28, width: double.infinity, radius: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShellSkeleton(height: 18, width: double.infinity, radius: 10),
              SizedBox(height: 8),
              ShellSkeleton(height: 18, width: 240, radius: 10),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ShellSkeleton(height: 260, width: double.infinity, radius: 24),
      ],
    );
  }
}
