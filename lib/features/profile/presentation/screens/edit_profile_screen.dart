import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/student_profile.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = 'edit-profile';
  static const routePath = '/profile/edit';

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _didSeed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<StudentProfile?>>(profileUpdateControllerProvider, (
      previous,
      next,
    ) {
      final messenger = ScaffoldMessenger.of(context);
      if (next.hasError && previous?.error != next.error) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }

      if (next.valueOrNull != null && previous?.isLoading == true) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
      }
    });

    final theme = Theme.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final updateState = ref.watch(profileUpdateControllerProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: profileState.when(
            data: (profile) {
              if (!_didSeed) {
                _didSeed = true;
                _nameController.text = profile.name;
                _emailController.text = profile.email;
                _phoneController.text = profile.phone;
              }

              return ListView(
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
                          'Edit profile',
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Student profile',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Update the canonical student profile returned by the mobile backend.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator: (value) {
                              if ((value?.trim() ?? '').isEmpty) {
                                return 'Full name is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Email is required.';
                              }
                              if (!text.contains('@')) {
                                return 'Enter a valid email.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              hintText: 'Optional',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              'Member since: ${profile.memberSinceLabel}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: updateState.isLoading ? null : _submit,
                            child: updateState.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const _EditProfileLoadingState(),
            error: (error, _) => AppErrorView(message: error.toString()),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(profileUpdateControllerProvider.notifier)
        .submit(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
  }
}

class _EditProfileLoadingState extends StatelessWidget {
  const _EditProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        ShellSkeleton(height: 340, width: double.infinity, radius: 28),
      ],
    );
  }
}
