import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/external_launcher.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/assignment_detail.dart';
import '../../domain/assignment_submission_result.dart';
import '../controllers/assignment_detail_controller.dart';
import '../controllers/assignment_submit_controller.dart';

class PickedAssignmentVideo {
  const PickedAssignmentVideo({required this.path, required this.name});

  final String path;
  final String name;
}

final assignmentVideoPickerProvider =
    Provider<Future<PickedAssignmentVideo?> Function()>((ref) {
      return () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );

        final file = result?.files.singleOrNull;
        final path = file?.path;
        if (path == null || path.isEmpty) {
          return null;
        }

        final fileName = file?.name.isNotEmpty == true
            ? file!.name
            : File(path).uri.pathSegments.last;

        return PickedAssignmentVideo(path: path, name: fileName);
      };
    });

class AssignmentDetailScreen extends ConsumerWidget {
  const AssignmentDetailScreen({
    super.key,
    required this.moduleId,
    required this.assignmentId,
  });

  static const routeName = 'assignment-detail';
  static const routePath = '/modules/:moduleId/assignments/:assignmentId';

  final String moduleId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assignmentDetailControllerProvider(assignmentId));

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignmentDetailControllerProvider(assignmentId));
              await ref.read(
                assignmentDetailControllerProvider(assignmentId).future,
              );
            },
            child: state.when(
              data: (assignment) => _AssignmentDetailContent(
                moduleId: moduleId,
                assignment: assignment,
              ),
              loading: () => const _AssignmentDetailLoadingState(),
              error: (error, _) => AppErrorView(message: error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentDetailContent extends ConsumerWidget {
  const _AssignmentDetailContent({
    required this.moduleId,
    required this.assignment,
  });

  final String moduleId;
  final AssignmentDetail assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                  Text(assignment.title, style: theme.textTheme.headlineMedium),
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
              Text(assignment.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              ShellMetricStrip(
                items: [
                  ShellMetricItem(
                    label: 'Status',
                    value: assignment.statusLabel,
                    icon: Icons.assignment_turned_in_rounded,
                    iconColor: const Color(0xFF63D2A1),
                  ),
                  ShellMetricItem(
                    label: 'Due',
                    value: assignment.dueLabel,
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFFFFB347),
                  ),
                  ShellMetricItem(
                    label: 'Upload',
                    value: assignment.canUpload ? 'Open' : 'Locked',
                    icon: Icons.upload_file_rounded,
                    iconColor: const Color(0xFF89C2FF),
                  ),
                  ShellMetricItem(
                    label: 'Feedback',
                    value: assignment.hasFeedback ? 'Available' : 'Pending',
                    icon: Icons.rate_review_rounded,
                    iconColor: const Color(0xFFFF8A80),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Instructions',
          subtitle: 'Backend-owned assignment brief for the student app.',
        ),
        const SizedBox(height: 16),
        _CopyCard(text: assignment.instructions),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Latest submission',
          subtitle: 'Current submission status and uploaded file details.',
        ),
        const SizedBox(height: 16),
        _SubmissionCard(submission: assignment.latestSubmission),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Feedback',
          subtitle: 'Review state returned by the existing backend workflow.',
        ),
        const SizedBox(height: 16),
        _FeedbackCard(feedback: assignment.feedback),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Upload video',
          subtitle:
              'Phase 1 assignment flow keeps uploads simple and device-based.',
        ),
        const SizedBox(height: 16),
        _UploadCard(moduleId: moduleId, assignment: assignment),
      ],
    );
  }
}

class _CopyCard extends StatelessWidget {
  const _CopyCard({required this.text});

  final String text;

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
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission});

  final AssignmentSubmission submission;

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
      child: submission.hasOpenableFile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submission.statusLabel, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  submission.submittedAtLabel,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Text(
                        submission.fileName.isEmpty
                            ? 'Uploaded file'
                            : submission.fileName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await launchExternalUrl(
                          context,
                          submission.fileUrl,
                          errorMessage:
                              'The submitted file could not be opened on this device.',
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ],
            )
          : submission.hasFile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submission.statusLabel, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  submission.submittedAtLabel,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  submission.fileName.isEmpty
                      ? 'A submission file exists, but the backend did not return a valid mobile file URL.'
                      : '${submission.fileName}\n\nThe backend returned this submission file, but its URL is not valid for mobile opening.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            )
          : const AppEmptyView(
              title: 'No submission yet',
              message:
                  'Pick a video file from the device to create the first assignment submission.',
              icon: Icons.video_file_outlined,
            ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final AssignmentFeedback feedback;

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
      child: feedback.title.isNotEmpty || feedback.message.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feedback.title, style: theme.textTheme.titleLarge),
                if (feedback.statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    feedback.statusLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(feedback.message, style: theme.textTheme.bodyMedium),
              ],
            )
          : const AppEmptyView(
              title: 'No feedback yet',
              message:
                  'Feedback from the review flow will appear here after submission processing.',
              icon: Icons.forum_outlined,
            ),
    );
  }
}

class _UploadCard extends ConsumerStatefulWidget {
  const _UploadCard({required this.moduleId, required this.assignment});

  final String moduleId;
  final AssignmentDetail assignment;

  @override
  ConsumerState<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends ConsumerState<_UploadCard> {
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<AssignmentSubmissionResult?>>(
      assignmentSubmitControllerProvider(widget.assignment.id),
      (previous, next) {
        final previousResult = previous?.valueOrNull;
        final nextResult = next.valueOrNull;

        if (nextResult == null || identical(previousResult, nextResult)) {
          return;
        }

        if (mounted) {
          setState(() {
            _selectedFilePath = null;
            _selectedFileName = null;
          });
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextResult.summary)));
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await ref.read(assignmentVideoPickerProvider)();
    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedFilePath = result.path;
      _selectedFileName = result.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitState = ref.watch(
      assignmentSubmitControllerProvider(widget.assignment.id),
    );

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
          Text(
            widget.assignment.canUpload
                ? 'Select a mobile video file'
                : 'Upload currently unavailable',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.assignment.canUpload
                ? 'The selected file will be posted to the backend assignment endpoint using your current student token.'
                : 'The backend currently marks this assignment as not accepting a new upload.',
            style: theme.textTheme.bodyMedium,
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file_rounded, color: Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (submitState.hasError) ...[
            const SizedBox(height: 12),
            Text(
              submitState.error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (submitState.valueOrNull != null) ...[
            const SizedBox(height: 12),
            Text(
              submitState.valueOrNull!.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF63D2A1),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: submitState.isLoading || !widget.assignment.canUpload
                    ? null
                    : _pickFile,
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Pick video'),
              ),
              ElevatedButton.icon(
                onPressed:
                    submitState.isLoading ||
                        !widget.assignment.canUpload ||
                        _selectedFilePath == null ||
                        _selectedFileName == null
                    ? null
                    : () {
                        ref
                            .read(
                              assignmentSubmitControllerProvider(
                                widget.assignment.id,
                              ).notifier,
                            )
                            .submit(
                              moduleId: widget.moduleId,
                              filePath: _selectedFilePath!,
                              fileName: _selectedFileName!,
                            );
                      },
                icon: submitState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: const Text('Upload video'),
              ),
              TextButton.icon(
                onPressed: submitState.isLoading
                    ? null
                    : () => ref.invalidate(
                        assignmentDetailControllerProvider(
                          widget.assignment.id,
                        ),
                      ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh assignment'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentDetailLoadingState extends StatelessWidget {
  const _AssignmentDetailLoadingState();

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
        ShellSkeleton(height: 220, width: double.infinity, radius: 24),
      ],
    );
  }
}
