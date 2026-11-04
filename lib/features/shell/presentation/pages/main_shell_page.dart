import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';

/// Scaffold utama yang membungkus empat tab navigasi bawah.
///
/// Gunakan [StatefulShellRoute.indexedStack] di router untuk
/// meneruskan [StatefulNavigationShell] ke widget ini.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Kembali ke rute awal branch jika tab yang sama ditekan lagi.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar kustom
// ---------------------------------------------------------------------------

/// Definisi satu item tab navigasi bawah.
class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const _kTabs = [
  _TabItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
  _TabItem(
    label: 'Live',
    icon: Icons.videocam_outlined,
    activeIcon: Icons.videocam,
  ),
  _TabItem(label: 'Egg Check', icon: Icons.egg_outlined, activeIcon: Icons.egg),
  _TabItem(
    label: 'History',
    icon: Icons.show_chart,
    activeIcon: Icons.show_chart,
  ),
  _TabItem(
    label: 'Setting',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
  ),
];

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _kTabs.length,
              (i) => _NavBarItem(
                tab: _kTabs[i],
                isActive: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(tab.activeIcon, color: AppColors.tertiary, size: 20),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              child: Icon(tab.icon, color: AppColors.textMuted, size: 20),
            ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
