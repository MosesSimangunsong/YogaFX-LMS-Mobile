import 'package:flutter/material.dart';

class ShellHeroBanner extends StatelessWidget {
  const ShellHeroBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2733), Color(0xFF121923), Color(0xFF0D121A)],
        ),
        border: Border.all(color: theme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFFFD29A),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.displayLarge),
          const SizedBox(height: 12),
          Text(description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(primaryLabel),
              ),
              OutlinedButton.icon(
                onPressed: onSecondaryTap,
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(secondaryLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
