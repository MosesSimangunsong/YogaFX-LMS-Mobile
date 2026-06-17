import 'package:flutter/material.dart';

class ShellMediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String progressText;
  final double? progressPercentage; // Jika ingin menampilkan progress bar kecil di bawah poster

  const ShellMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.progressText,
    this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, // Rasio vertikal aspek poster film
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover, width: 130, height: double.infinity),
                  if (progressPercentage != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFFE50914),
                        minHeight: 4,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Judul Singkat di Bawah Poster
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(progressText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}