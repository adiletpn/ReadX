import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/haptics.dart';
import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../router.dart';
import 'pressable.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    void go(String path) {
      Haptics.tap();
      context.go(path);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppMetrics.hPadding,
        right: AppMetrics.hPadding,
        bottom: bottomInset > 0 ? bottomInset - 6 : 10,
      ),
      child: Container(
        height: AppMetrics.bottomNavHeight,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.surfaceGradient,
          ),
          borderRadius: BorderRadius.circular(AppMetrics.radiusNav),
          border: Border.all(color: AppColors.borderBright),
          boxShadow: const [
            BoxShadow(color: Color(0x73000000), blurRadius: 28, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: LucideIcons.house,
              label: 'Feed',
              active: location == AppRoutes.feed,
              onTap: () => go(AppRoutes.feed),
            ),
            _NavItem(
              icon: LucideIcons.target,
              label: 'Habits',
              active: location == AppRoutes.habits,
              onTap: () => go(AppRoutes.habits),
            ),
            _NavItem(
              icon: LucideIcons.trophy,
              label: 'Points',
              active: location == AppRoutes.points,
              onTap: () => go(AppRoutes.points),
            ),
            _NavItem(
              icon: LucideIcons.user,
              label: 'Profile',
              active: location == AppRoutes.profile || location == AppRoutes.settings,
              onTap: () => go(AppRoutes.profile),
            ),
          ],
        ),
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
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = active ? AppColors.primaryBright : AppColors.textMuted;

    return Expanded(
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        pressedOpacity: 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
          child: AnimatedContainer(
            duration: AppDuration.medium,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: active ? AppColors.primary10 : const Color(0x00000000),
              borderRadius: BorderRadius.circular(AppMetrics.radiusNavItem),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.06 : 1,
                  duration: AppDuration.medium,
                  curve: Curves.easeOutBack,
                  child: Icon(icon, size: 21, color: tint, semanticLabel: label),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: AppDuration.medium,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.1,
                    color: tint,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
