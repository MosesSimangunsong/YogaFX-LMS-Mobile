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
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xCC0F141C),
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final isActive = navigationShell.currentIndex == index;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => context.go(item.routePath),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: isActive
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFE85D04),
                                        Color(0xFFFF7B00),
                                      ],
                                    )
                                  : null,
                              color: isActive ? null : Colors.transparent,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFFB4BFCE),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF8D99AA),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
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
