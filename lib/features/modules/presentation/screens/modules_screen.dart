import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_media_rail.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/module_summary.dart';
import '../controllers/modules_controller.dart';
import 'module_detail_screen.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  static const routeName = 'modules';
  static const routePath = '/modules';

  static const _gradients = [
    [Color(0xFFB24592), Color(0xFF2D1E4F)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF365BFF), Color(0xFF0C193F)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesState = ref.watch(modulesControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(modulesControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                Text('Modules', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Browse your learning path and open each module to continue studying.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                modulesState.when(
                  data: (modules) => _ModulesContent(modules: modules),
                  loading: () => const _ModulesLoadingState(),
                  error: (error, _) => SizedBox(
                    height: 420,
                    child: AppErrorView(
                      message: error.toString(),
                      onRetry: () => ref
                          .read(modulesControllerProvider.notifier)
                          .refresh(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModulesContent extends StatelessWidget {
  const _ModulesContent({required this.modules});

  final List<ModuleSummary> modules;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SizedBox(
        height: 320,
        child: AppEmptyView(
          title: 'No modules available',
          message:
              'The modules endpoint responded, but it did not return any accessible student modules.',
          icon: Icons.grid_off_rounded,
        ),
      );
    }

    final featuredCards = modules.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Featured modules',
          subtitle:
              'Scrollable highlights driven by the mobile modules payload.',
        ),
        const SizedBox(height: 16),
        ShellMediaRail(
          items: featuredCards.asMap().entries.map((entry) {
            final module = entry.value;
            return ShellMediaCardData(
              title: module.title,
              subtitle: module.subtitle,
              duration: module.itemCountLabel,
              badge: module.badge,
              onTap: () => context.pushNamed(
                ModuleDetailScreen.routeName,
                pathParameters: {'moduleId': module.id},
              ),
              gradient: ModulesScreen
                  ._gradients[entry.key % ModulesScreen._gradients.length],
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'All modules',
          subtitle: 'Open a module to inspect ordered lessons and assignments.',
        ),
        const SizedBox(height: 16),
        ...modules.asMap().entries.map((entry) {
          final module = entry.value;
          final gradient = ModulesScreen
              ._gradients[entry.key % ModulesScreen._gradients.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.pushNamed(
                ModuleDetailScreen.routeName,
                pathParameters: {'moduleId': module.id},
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_lesson_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            module.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(label: module.progressLabel),
                              _MetaChip(label: module.itemCountLabel),
                              if (module.badge != null)
                                _MetaChip(label: module.badge!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                    ),
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

class _ModulesLoadingState extends StatelessWidget {
  const _ModulesLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSectionHeader(
          title: 'Loading modules',
          subtitle: 'Preparing module browsing from the mobile API.',
        ),
        SizedBox(height: 16),
        SizedBox(height: 338, child: _ModulesRailSkeleton()),
        SizedBox(height: 28),
        _ModuleListSkeleton(),
      ],
    );
  }
}

class _ModulesRailSkeleton extends StatelessWidget {
  const _ModulesRailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, _) => const SizedBox(
        width: 188,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShellSkeleton(height: 250, width: 188, radius: 26),
            SizedBox(height: 12),
            ShellSkeleton(height: 16, width: 140, radius: 8),
            SizedBox(height: 8),
            ShellSkeleton(height: 12, width: 100, radius: 8),
          ],
        ),
      ),
    );
  }
}

class _ModuleListSkeleton extends StatelessWidget {
  const _ModuleListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Row(
              children: [
                ShellSkeleton(height: 58, width: 58, radius: 18),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShellSkeleton(height: 16, width: 150, radius: 8),
                      SizedBox(height: 8),
                      ShellSkeleton(
                        height: 12,
                        width: double.infinity,
                        radius: 8,
                      ),
                      SizedBox(height: 8),
                      ShellSkeleton(height: 12, width: 110, radius: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
