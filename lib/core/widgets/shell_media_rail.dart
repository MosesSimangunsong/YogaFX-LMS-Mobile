import 'package:flutter/material.dart';

import 'shell_media_card.dart';

class ShellMediaRail extends StatelessWidget {
  const ShellMediaRail({super.key, required this.items});

  final List<ShellMediaCardData> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 338,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return ShellMediaCard(
            title: item.title,
            subtitle: item.subtitle,
            duration: item.duration,
            gradient: item.gradient,
            badge: item.badge,
          );
        },
      ),
    );
  }
}

class ShellMediaCardData {
  const ShellMediaCardData({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.gradient,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String duration;
  final List<Color> gradient;
  final String? badge;
}
