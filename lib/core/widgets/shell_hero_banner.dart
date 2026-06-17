import 'package:flutter/material.dart';

class ShellHeroBanner extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onPlayPressed;

  const ShellHeroBanner({
    super.key, 
    required this.imageUrl, 
    required this.title, 
    required this.subtitle, 
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Gambar Utama Poster
        Container(
          height: size.height * 0.55,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Efek Gradien Memudar Ke Bawah (Vignette & Fade Effect)
        Container(
          height: size.height * 0.55,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black38,
                Colors.transparent,
                Colors.transparent,
                Color(0xFF000000), // Memudar penuh ke background aplikasi
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        // Konten Informasi & Tombol CTA
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              // Tombol Mainkan / Lanjutkan Belajar ala Netflix
              ElevatedButton.icon(
                onPressed: onPlayPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text('Lanjutkan Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}