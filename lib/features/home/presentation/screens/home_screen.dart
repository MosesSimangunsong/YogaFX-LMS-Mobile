import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_hero_banner.dart';
import '../../../../core/widgets/shell_media_rail.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/dashboard_data.dart';
import '../controllers/dashboard_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  static const _railGradients = [
    [Color(0xFFE85D04), Color(0xFF6D2500)],
    [Color(0xFF365BFF), Color(0xFF0C193F)],
    [Color(0xFF16A085), Color(0xFF0B3D35)],
    [Color(0xFFB24592), Color(0xFF2D1E4F)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final dashboardState = ref.watch(dashboardControllerProvider);
    final user = authState.user;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                _DashboardTopBar(userName: user?.name ?? 'YogaFX Student'),
                const SizedBox(height: 20),
                dashboardState.when(
                  data: (dashboard) => _DashboardContent(
                    dashboard: dashboard,
                    signedInEmail: user?.email ?? 'student@student.app',
                    apiTarget:
                        '${ref.watch(app_providers.appConfigProvider).apiBaseUrl}${ref.watch(app_providers.appConfigProvider).mobileApiPrefix}',
                  ),
                  loading: () => const _DashboardLoadingState(),
                  error: (error, _) => _DashboardErrorState(
                    message: error.toString(),
                    onRetry: () => ref
                        .read(dashboardControllerProvider.notifier)
                        .refresh(),
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

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good evening', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(userName, style: theme.textTheme.headlineMedium),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Color(0xFFFFB347),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Online now',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.dashboard,
    required this.signedInEmail,
    required this.apiTarget,
  });

  final DashboardData dashboard;
  final String signedInEmail;
  final String apiTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = _buildMetrics();
    final sections = dashboard.sections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShellHeroBanner(
          eyebrow: dashboard.continueLearning.eyebrow,
          title: dashboard.continueLearning.title,
          description: dashboard.continueLearning.description,
          primaryLabel: dashboard.continueLearning.primaryActionLabel,
          secondaryLabel: dashboard.continueLearning.secondaryActionLabel,
        ),
        const SizedBox(height: 20),
        ShellMetricStrip(items: metrics),
        const SizedBox(height: 28),
        if (sections.isEmpty)
          const SizedBox(
            height: 220,
            child: AppEmptyView(
              title: 'No dashboard sections yet',
              message:
                  'The dashboard endpoint responded, but there are no content rails to show yet.',
              icon: Icons.layers_clear_rounded,
            ),
          )
        else
          ...sections.map((section) {
            final railItems = section.items.asMap().entries.map((entry) {
              final item = entry.value;
              return ShellMediaCardData(
                title: item.title,
                subtitle: item.subtitle,
                duration: item.durationLabel,
                badge: item.badge,
                gradient:
                    HomeScreen._railGradients[entry.key %
                        HomeScreen._railGradients.length],
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: section.title,
                    subtitle: section.subtitle,
                  ),
                  const SizedBox(height: 16),
                  ShellMediaRail(items: railItems),
                ],
              ),
            );
          }),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard API connected',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'This home screen now reads mobile dashboard data, supports pull-to-refresh, and keeps the Module 4 shell while waiting for deeper feature modules.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<ShellMetricItem> _buildMetrics() {
    final dashboardMetrics = dashboard.metrics.take(3).toList();
    final iconPalette = [
      const (Icons.verified_rounded, Color(0xFF63D2A1)),
      const (Icons.route_rounded, Color(0xFF89C2FF)),
      const (Icons.person_rounded, Color(0xFFFF8A80)),
    ];

    final items = <ShellMetricItem>[];
    for (var index = 0; index < dashboardMetrics.length; index++) {
      final metric = dashboardMetrics[index];
      final iconData = iconPalette[index % iconPalette.length];
      items.add(
        ShellMetricItem(
          label: metric.label,
          value: metric.value,
          icon: iconData.$1,
          iconColor: iconData.$2,
        ),
      );
    }

    items.add(
      ShellMetricItem(
        label: 'Signed in as',
        value: signedInEmail,
        icon: Icons.alternate_email_rounded,
        iconColor: const Color(0xFFFFB347),
      ),
    );
    items.add(
      ShellMetricItem(
        label: 'API target',
        value: apiTarget,
        icon: Icons.api_rounded,
        iconColor: const Color(0xFFB39DFF),
      ),
    );

    return items;
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _HeroBannerSkeleton(),
        SizedBox(height: 20),
        _MetricSkeletonStrip(),
        SizedBox(height: 28),
        _RailSkeleton(title: 'Loading dashboard'),
      ],
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: AppErrorView(message: message, onRetry: onRetry),
    );
  }
}

class _HeroBannerSkeleton extends StatelessWidget {
  const _HeroBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: theme.cardColor.withValues(alpha: 0.72),
        border: Border.all(color: theme.dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShellSkeleton(height: 12, width: 120, radius: 8),
          SizedBox(height: 14),
          ShellSkeleton(height: 42, width: double.infinity, radius: 14),
          SizedBox(height: 10),
          ShellSkeleton(height: 16, width: double.infinity, radius: 10),
          SizedBox(height: 8),
          ShellSkeleton(height: 16, width: 260, radius: 10),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: ShellSkeleton(height: 54, radius: 18)),
              SizedBox(width: 12),
              Expanded(child: ShellSkeleton(height: 54, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricSkeletonStrip extends StatelessWidget {
  const _MetricSkeletonStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(4, (_) {
        return Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShellSkeleton(height: 18, width: 18, radius: 9),
              SizedBox(height: 12),
              ShellSkeleton(height: 28, width: 90, radius: 10),
              SizedBox(height: 6),
              ShellSkeleton(height: 14, width: 100, radius: 8),
            ],
          ),
        );
      }),
    );
  }
}

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: title,
          subtitle: 'Preparing your personalized dashboard rails.',
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 318,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return const SizedBox(
                width: 188,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShellSkeleton(height: 230, width: 188, radius: 26),
                    SizedBox(height: 12),
                    ShellSkeleton(height: 16, width: 140, radius: 8),
                    SizedBox(height: 8),
                    ShellSkeleton(height: 12, width: 110, radius: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
