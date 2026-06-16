import 'package:flutter/material.dart';

class ShellMetricStrip extends StatelessWidget {
  const ShellMetricStrip({super.key, required this.items});

  final List<ShellMetricItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: item.iconColor, size: 20),
              const SizedBox(height: 12),
              Text(item.value, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(item.label, style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ShellMetricItem {
  const ShellMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
}
