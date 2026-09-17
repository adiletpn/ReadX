import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../router.dart';
import 'pressable.dart';

/// Four tabs — Home, Target, Trophy, User — on a 64 pt bar with a hairline on
/// top, matching BottomNav.tsx. The active icon is blue and drawn heavier;
/// Settings counts as part of the Profile tab, the same way the web does it.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: AppMetrics.bottomNavHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset, left: 8, right: 8),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: LucideIcons.house,
            label: 'Feed',
            active: location == AppRoutes.feed,
            onTap: () => context.go(AppRoutes.feed),
          ),
          _NavItem(
            icon: LucideIcons.target,
            label: 'Habits',
            active: location == AppRoutes.habits,
            onTap: () => context.go(AppRoutes.habits),
          ),
          _NavItem(
            icon: LucideIcons.trophy,
            label: 'Points',
            active: location == AppRoutes.points,
            onTap: () => context.go(AppRoutes.points),
          ),
          _NavItem(
            icon: LucideIcons.user,
            label: 'Profile',
            active: location == AppRoutes.profile || location == AppRoutes.settings,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;

  /// Only read by VoiceOver — the web tabs carry `aria-label` and no visible
  /// caption, so neither does this.
  final String label;

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 24,
          // The web also thickens the active icon's stroke (2 vs 1.5).
          // Lucide ships here as a non-variable icon font, so weight is not
          // adjustable and the colour carries the state on its own.
          color: active ? AppColors.primary : AppColors.textSecondary,
          semanticLabel: label,
        ),
      ),
    );
  }
}
