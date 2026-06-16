import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../../assignments/presentation/screens/assignment_detail_screen.dart';
import '../../../lessons/presentation/screens/lesson_detail_screen.dart';
import '../../domain/module_detail.dart';
import '../controllers/module_detail_controller.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({super.key, required this.moduleId});

  static const routeName = 'module-detail';
  static const routePath = '/modules/:moduleId';

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleDetailControllerProvider(moduleId));

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(moduleDetailControllerProvider(moduleId));
              await ref.read(moduleDetailControllerProvider(moduleId).future);
            },
            child: state.when(
              data: (detail) => _ModuleDetailContent(detail: detail),
              loading: () => const _ModuleDetailLoadingState(),
              error: (error, _) => AppErrorView(message: error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleDetailContent extends StatelessWidget {
  const _ModuleDetailContent({required this.detail});

  final ModuleDetail detail;

  @override
  Widget build(BuildContext context) {
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
              child: Text(detail.title, style: theme.textTheme.headlineMedium),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
              Text(detail.subtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              ShellMetricStrip(
                items: [
                  ShellMetricItem(
                    label: 'Progress',
                    value: detail.progressLabel,
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFF63D2A1),
                  ),
                  ShellMetricItem(
                    label: 'Status',
                    value: detail.completionLabel,
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFFFFB347),
                  ),
                  ShellMetricItem(
                    label: 'Lessons',
                    value: detail.lessons.length.toString(),
                    icon: Icons.play_circle_outline_rounded,
                    iconColor: const Color(0xFF89C2FF),
                  ),
                  ShellMetricItem(
                    label: 'Assignments',
                    value: detail.assignments.length.toString(),
                    icon: Icons.assignment_rounded,
                    iconColor: const Color(0xFFFF8A80),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _EntrySection(
          moduleId: detail.id,
          title: 'Lessons',
          subtitle: 'Ordered lesson items from the backend mobile payload.',
          items: detail.lessons,
          emptyTitle: 'No lessons available',
          emptyMessage: 'This module does not expose lesson items yet.',
          entryKind: _EntryKind.lesson,
        ),
        const SizedBox(height: 28),
        _EntrySection(
          moduleId: detail.id,
          title: 'Assignments',
          subtitle: 'Ordered assignment items from the backend mobile payload.',
          items: detail.assignments,
          emptyTitle: 'No assignments available',
          emptyMessage:
              'Assignments will appear here once the API returns them.',
          entryKind: _EntryKind.assignment,
        ),
      ],
    );
  }
}

enum _EntryKind { lesson, assignment }

class _EntrySection extends StatelessWidget {
  const _EntrySection({
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.entryKind,
  });

  final String moduleId;
  final String title;
  final String subtitle;
  final List<ModuleEntry> items;
  final String emptyTitle;
  final String emptyMessage;
  final _EntryKind entryKind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        if (items.isEmpty)
          SizedBox(
            height: 180,
            child: AppEmptyView(
              title: emptyTitle,
              message: emptyMessage,
              icon: Icons.layers_outlined,
            ),
          )
        else
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: item.id.isEmpty
                    ? null
                    : () => switch (entryKind) {
                        _EntryKind.lesson => context.pushNamed(
                          LessonDetailScreen.routeName,
                          pathParameters: {
                            'moduleId': moduleId,
                            'lessonId': item.id,
                          },
                        ),
                        _EntryKind.assignment => context.pushNamed(
                          AssignmentDetailScreen.routeName,
                          pathParameters: {
                            'moduleId': moduleId,
                            'assignmentId': item.id,
                          },
                        ),
                      },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          entryKind == _EntryKind.lesson
                              ? Icons.play_arrow_rounded
                              : Icons.assignment_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.trailingLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (item.badge != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.badge!,
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.id.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _ModuleDetailLoadingState extends StatelessWidget {
  const _ModuleDetailLoadingState();

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
            Expanded(child: ShellSkeleton(height: 28, radius: 12)),
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
      ],
    );
  }
}
