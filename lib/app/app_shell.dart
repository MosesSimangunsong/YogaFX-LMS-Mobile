import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/modules/presentation/screens/modules_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    _ShellItem(
      label: 'Home',
      routePath: HomeScreen.routePath,
      icon: Icons.home_rounded,
      activeIcon: Icons.home_filled,
    ),
    _ShellItem(
      label: 'Modules',
      routePath: ModulesScreen.routePath,
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _ShellItem(
      label: 'Profile',
      routePath: ProfileScreen.routePath,
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
  body: currentScreen,
  extendBody: true, // WAJIB: Agar konten meluas ke belakang navbar melayang
  bottomNavigationBar: Padding(
    padding: const EdgeInsets.only(bottom: 24.0, left: 32.0, right: 32.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: const Color(0xFF1A1A1A).withOpacity(0.85), // Semi transparan
        height: 65,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFE50914),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Modules'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    ),
  ),
);
  }
}

class _ShellItem {
  const _ShellItem({
    required this.label,
    required this.routePath,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String routePath;
  final IconData icon;
  final IconData activeIcon;
}
