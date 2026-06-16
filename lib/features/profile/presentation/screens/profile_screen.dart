import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/shell_metric_strip.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../certificates/presentation/screens/certificates_screen.dart';
import '../controllers/profile_controller.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: profileState.when(
            data: (profile) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileControllerProvider);
                await ref.read(profileControllerProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE85D04), Color(0xFFFF8A00)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initialFromName(profile.name),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profile.email,
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (profile.phone.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  profile.phone,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AppSectionHeader(
                    title: 'Account hub',
                    subtitle:
                        'Profile data stays backend-owned while mobile handles authenticated update and password flows.',
                  ),
                  const SizedBox(height: 16),
                  ShellMetricStrip(
                    items: [
                      const ShellMetricItem(
                        label: 'Access',
                        value: 'Student only',
                        icon: Icons.lock_person_rounded,
                        iconColor: Color(0xFF89C2FF),
                      ),
                      const ShellMetricItem(
                        label: 'Auth mode',
                        value: 'Token',
                        icon: Icons.key_rounded,
                        iconColor: Color(0xFFFFB347),
                      ),
                      ShellMetricItem(
                        label: 'Member since',
                        value: profile.memberSinceLabel,
                        icon: Icons.memory_rounded,
                        iconColor: const Color(0xFF63D2A1),
                      ),
                      ShellMetricItem(
                        label: 'Signed in as',
                        value: user?.email ?? profile.email,
                        icon: Icons.manage_accounts_rounded,
                        iconColor: const Color(0xFFFF8A80),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfileActionCard(
                    title: 'Edit profile',
                    description:
                        'Update your canonical student profile information from mobile.',
                    icon: Icons.edit_rounded,
                    onTap: () => context.pushNamed(EditProfileScreen.routeName),
                  ),
                  const SizedBox(height: 14),
                  _ProfileActionCard(
                    title: 'Change password',
                    description:
                        'Update your password inside the authenticated student flow.',
                    icon: Icons.password_rounded,
                    onTap: () =>
                        context.pushNamed(ChangePasswordScreen.routeName),
                  ),
                  const SizedBox(height: 14),
                  _ProfileActionCard(
                    title: 'Certificates',
                    description:
                        'Open your completion certificates and download the backend-provided file from mobile.',
                    icon: Icons.workspace_premium_rounded,
                    onTap: () =>
                        context.pushNamed(CertificatesScreen.routeName),
                  ),
                  const SizedBox(height: 14),
                  _ProfileActionCard(
                    title: 'Logout',
                    description:
                        'Available now so the authenticated mobile student flow remains complete.',
                    icon: Icons.logout_rounded,
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: const [
                ShellSkeleton(height: 120, width: double.infinity, radius: 28),
                SizedBox(height: 24),
                ShellSkeleton(height: 160, width: double.infinity, radius: 24),
              ],
            ),
            error: (error, _) => AppErrorView(message: error.toString()),
          ),
        ),
      ),
    );
  }
}

String _initialFromName(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Y';
  }

  return trimmed.substring(0, 1).toUpperCase();
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
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
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
