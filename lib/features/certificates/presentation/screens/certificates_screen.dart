import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/certificate_summary.dart';
import '../controllers/certificate_list_controller.dart';
import 'certificate_detail_screen.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  static const routeName = 'certificates';
  static const routePath = '/profile/certificates';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(certificateListControllerProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(certificateListControllerProvider);
              await ref.read(certificateListControllerProvider.future);
            },
            child: state.when(
              data: (certificates) => _CertificatesContent(items: certificates),
              loading: () => const _CertificatesLoadingState(),
              error: (error, _) => AppErrorView(message: error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificatesContent extends StatelessWidget {
  const _CertificatesContent({required this.items});

  final List<CertificateSummary> items;

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
              child: Text(
                'Certificates',
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppSectionHeader(
          title: 'Your awards',
          subtitle:
              'Certificate visibility and ordering should always follow the backend mobile payload.',
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const SizedBox(
            height: 220,
            child: AppEmptyView(
              title: 'No certificates yet',
              message:
                  'Certificates will appear here once your backend account becomes eligible.',
              icon: Icons.workspace_premium_outlined,
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: item.id.isEmpty
                    ? null
                    : () => context.pushNamed(
                        CertificateDetailScreen.routeName,
                        pathParameters: {'certificateId': item.id},
                      ),
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
                        child: const Icon(
                          Icons.workspace_premium_rounded,
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
                            item.statusLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.issuedLabel,
                            style: theme.textTheme.bodySmall,
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
            ),
          ),
      ],
    );
  }
}

class _CertificatesLoadingState extends StatelessWidget {
  const _CertificatesLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: const [
        Row(
          children: [
            ShellSkeleton(height: 44, width: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(child: ShellSkeleton(height: 28, radius: 12)),
          ],
        ),
        SizedBox(height: 18),
        ShellSkeleton(height: 140, width: double.infinity, radius: 24),
        SizedBox(height: 12),
        ShellSkeleton(height: 140, width: double.infinity, radius: 24),
      ],
    );
  }
}
