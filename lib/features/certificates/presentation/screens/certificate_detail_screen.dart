import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/external_launcher.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/certificate_detail.dart';
import '../controllers/certificate_detail_controller.dart';

class CertificateDetailScreen extends ConsumerWidget {
  const CertificateDetailScreen({super.key, required this.certificateId});

  static const routeName = 'certificate-detail';
  static const routePath = '/profile/certificates/:certificateId';

  final String certificateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(certificateDetailControllerProvider(certificateId));

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                certificateDetailControllerProvider(certificateId),
              );
              await ref.read(
                certificateDetailControllerProvider(certificateId).future,
              );
            },
            child: state.when(
              data: (certificate) =>
                  _CertificateDetailContent(certificate: certificate),
              loading: () => const _CertificateDetailLoadingState(),
              error: (error, _) => AppErrorView(message: error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateDetailContent extends StatelessWidget {
  const _CertificateDetailContent({required this.certificate});

  final CertificateDetail certificate;

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
                certificate.title,
                style: theme.textTheme.headlineMedium,
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
              Text(certificate.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              ShellMetricStrip(
                items: [
                  ShellMetricItem(
                    label: 'Status',
                    value: certificate.statusLabel,
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFF63D2A1),
                  ),
                  ShellMetricItem(
                    label: 'Issued',
                    value: certificate.issuedLabel,
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFFFFB347),
                  ),
                  ShellMetricItem(
                    label: 'Recipient',
                    value: certificate.recipientName,
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF89C2FF),
                  ),
                  ShellMetricItem(
                    label: 'Eligibility',
                    value: certificate.eligibilityLabel,
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFFFF8A80),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppSectionHeader(
          title: 'Certificate preview',
          subtitle: 'Open or download the backend-provided certificate file.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
          ),
          child: certificate.canOpen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your certificate is ready',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the actions below to open or download the same certificate exposed by the existing backend.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => launchExternalUrl(
                            context,
                            (certificate.openUri ?? certificate.downloadUri)
                                    ?.toString() ??
                                '',
                            errorMessage:
                                'The certificate file could not be opened on this device.',
                          ),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Open'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => launchExternalUrl(
                            context,
                            (certificate.downloadUri ?? certificate.openUri)
                                    ?.toString() ??
                                '',
                            errorMessage:
                                'The certificate file could not be downloaded on this device.',
                          ),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download'),
                        ),
                      ],
                    ),
                  ],
                )
              : const AppEmptyView(
                  title: 'Certificate not available',
                  message:
                      'The backend has not exposed a certificate file for this item yet.',
                  icon: Icons.workspace_premium_outlined,
                ),
        ),
      ],
    );
  }
}

class _CertificateDetailLoadingState extends StatelessWidget {
  const _CertificateDetailLoadingState();

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
