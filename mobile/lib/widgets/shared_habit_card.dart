import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/api/api_exception.dart';
import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../features/habits/shared_habits_repository.dart';
import '../models/shared_habit.dart';
import '../router.dart';
import 'app_toast.dart';
import 'pressable.dart';
import 'user_avatar.dart';

class SharedHabitCard extends ConsumerStatefulWidget {
  const SharedHabitCard({super.key, required this.sharedHabit, required this.onChanged});

  final SharedHabitSummary sharedHabit;
  final ValueChanged<SharedHabitSummary> onChanged;

  @override
  ConsumerState<SharedHabitCard> createState() => _SharedHabitCardState();
}

class _SharedHabitCardState extends ConsumerState<SharedHabitCard> {
  bool _joining = false;
  bool _limitNote = false;
  Timer? _limitTimer;

  @override
  void dispose() {
    _limitTimer?.cancel();
    super.dispose();
  }

  Future<void> _join() async {
    if (_joining || widget.sharedHabit.amIMember) return;
    setState(() => _joining = true);

    try {
      final result = await ref
          .read(sharedHabitsRepositoryProvider)
          .join(widget.sharedHabit.id);

      widget.onChanged(widget.sharedHabit.copyWith(
        amIMember: true,
        memberCount: widget.sharedHabit.memberCount + 1,
      ));

      if (result.eligibleLimitReached && mounted) {
        setState(() => _limitNote = true);
        _limitTimer?.cancel();
        _limitTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _limitNote = false);
        });
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.sharedHabit;
    final shown = habit.members.take(5).toList();
    final extra = (habit.memberCount - shown.length).clamp(0, 99);
    final stackCount = shown.length + (extra > 0 ? 1 : 0);
    final stackWidth = stackCount == 0 ? 0.0 : (stackCount - 1) * 20.0 + 28.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary30),
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.users, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'SHARED HABIT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            habit.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.flame, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                '${habit.currentStreak}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              const Text('days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  '${habit.memberCount} ${habit.memberCount == 1 ? 'person' : 'people'} doing this',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 28,
                width: stackWidth,
                child: Stack(
                  children: [
                    for (var i = 0; i < shown.length; i++)
                      Positioned(
                        left: i * 20,
                        child: _AvatarRing(
                          child: UserAvatar(
                            avatarUrl: shown[i].avatarUrl,
                            name: shown[i].username,
                            size: 28,
                          ),
                        ),
                      ),
                    if (extra > 0)
                      Positioned(
                        left: shown.length * 20,
                        child: _AvatarRing(
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceHi2,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '+$extra',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _action(habit),
            ],
          ),
          if (_limitNote)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Joined without points — you're at your 5-habit limit.",
                style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.warning),
              ),
            ),
        ],
      ),
    );
  }

  Widget _action(SharedHabitSummary habit) {
    if (habit.amICreator) {
      return Pressable(
        onTap: () => context.push(AppRoutes.sharedHabit(habit.id)),
        child: const Text(
          'Manage',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (habit.amIMember) {
      return const Text(
        "✓ You're in",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      );
    }

    return Pressable(
      onTap: _joining ? null : _join,
      pressedOpacity: 0.8,
      child: Opacity(
        opacity: _joining ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppMetrics.radiusField),
          ),
          child: Text(
            _joining ? 'Joining…' : 'Join',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: child,
    );
  }
}
