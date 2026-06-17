import 'package:flutter/material.dart';
import 'shell_media_card.dart';

class ShellMediaRail extends StatelessWidget {
  final String sectionTitle;
  final List<ShellMediaCard> items;

  const ShellMediaRail({super.key, required this.sectionTitle, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(sectionTitle, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 210, // Menyesuaikan batas tinggi card agar teks tidak terpotong
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}