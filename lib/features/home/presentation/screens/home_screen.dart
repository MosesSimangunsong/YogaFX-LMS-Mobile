import 'package:flutter/material.dart';
import '../../../../core/widgets/shell_hero_banner.dart';
import '../../../../core/widgets/shell_media_rail.dart';
import '../../../../core/widgets/shell_media_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Top AppBar Minimalis Melayang
          SliverAppBar(
            backgroundColor: Colors.black.withOpacity(0.6),
            floating: true,
            pinned: false,
            snap: true,
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('assets/images/logo_yogafx.png', fit: FontWeight.contain), // Logo Kiri
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
            ],
          ),
          
          // Konten Utama Berbaris
          SliverList(
            delegate: SliverChildListDelegate([
              // 1. Hero Banner Utama
              ShellHeroBanner(
                imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600',
                title: 'Hatha Yoga Foundation',
                subtitle: 'Modul 3 • 4 dari 12 Lessons Selesai',
                onPlayPressed: () {
                  // Arahkan ke halaman lesson aktif terbaru
                },
              ),
              const SizedBox(height: 16),

              // 2. Chip Filter Cepat Konten
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Semua Kursus', 'Modul Baru', 'Tugas', 'Sertifikat'].map((category) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: category == 'Semua Kursus',
                        onSelected: (_) {},
                        selectedColor: Colors.white,
                        textColor: category == 'Semua Kursus' ? Colors.black : Colors.white,
                        backgroundColor: const Color(0xFF222222),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Rail Kategori: Sedang Dipelajari
              const ShellMediaRail(
                sectionTitle: 'Lanjutkan Menonton & Belajar',
                items: [
                  ShellMediaCard(
                    imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=400',
                    title: 'Vinyasa Flow Intro',
                    progressText: 'Lesson 2 dari 8',
                    progressPercentage: 0.25,
                  ),
                  ShellMediaCard(
                    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=400',
                    title: 'Pranayama Breathing',
                    progressText: 'Lesson 5 dari 6',
                    progressPercentage: 0.83,
                  ),
                ],
              ),

              // 4. Rail Kategori: Modul Rekomendasi/Terbaru
              const ShellMediaRail(
                sectionTitle: 'Modul Rekomendasi Untuk Anda',
                items: [
                  ShellMediaCard(
                    imageUrl: 'https://images.unsplash.com/photo-1599447421416-3414500d18a5?q=80&w=400',
                    title: 'Asanas Advanced',
                    progressText: '12 Lessons • Baru',
                  ),
                  ShellMediaCard(
                    imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?q=80&w=400',
                    title: 'Flexibility Mastery',
                    progressText: '8 Lessons',
                  ),
                  ShellMediaCard(
                    imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=400',
                    title: 'Meditation & Balance',
                    progressText: '10 Lessons',
                  ),
                ],
              ),
              
              // Tambahkan padding bawah ekstra agar konten tidak tertutup floating navbar
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }
}