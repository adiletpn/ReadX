import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/shared_habit.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/section_header.dart';
import '../auth/auth_controller.dart';
import 'shared_habit_controller.dart';

class SharedHabitScreen extends ConsumerWidget {
  const SharedHabitScreen({super.key, required this.sharedHabitId});

  final int sharedHabitId;

  Future<void> _run(
    BuildContext context,
    Future<String?> Function() action,
  ) async {
    final error = await action();
    if (error != null && error.isNotEmpty && context.mounted) {
      AppToast.show(context, error, isError: true);
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Leave this group?',
      message: 'Your habit stays in your list, but it will stop counting '
          "toward the group's shared streak.",
      confirmLabel: 'Leave',
    );
    if (!confirmed || !context.mounted) return;
    await _run(context, ref.read(sharedHabitProvider(sharedHabitId).notifier).leave);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(sharedHabitProvider(sharedHabitId));
    final me = ref.watch(currentUserProvider);
    final busy = ref.watch(busySetProvider);
    final controller = ref.read(sharedHabitProvider(sharedHabitId).notifier);

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Shared Habit',
      ),
      bottomBar: detail.hasValue
          ? _Actions(
              detail: detail.value!,
              userId: me?.id,
              busy: busy,
              onComplete: () => _run(context, controller.complete),
              onJoin: () => _run(context, controller.join),
              onLeave: () => _leave(context, ref),
            )
          : null,
      body: switch (detail) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 16, AppMetrics.hPadding, 28),
            children: [
              _HeaderCard(detail: value),
              const SizedBox(height: 24),
              const SectionHeader(icon: LucideIcons.users, label: 'MEMBERS'),
              for (final member in value.members)
                _MemberRow(member: member),
              if (value.postId != null) ...[
                const SizedBox(height: 20),
                Center(
                  child: Pressable(
                    onTap: () => context.push(AppRoutes.post(value.postId!)),
                    child: const Text(
                      'View original post',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        AsyncError(:final error) => ErrorState(
            message: error is ApiException
                ? error.message
                : 'Не удалось загрузить привычку',
            onRetry: controller.reload,
          ),
        _ => const LoadingState(),
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail});

  final SharedHabitDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary30),
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            detail.title,
            textAlign: TextAlign.center,
            style: AppText.h1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.flame, size: 28, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('${detail.currentStreak}', style: AppText.counterMd),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'day streak · everyone must complete daily',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            '${detail.longestStreak} day best · ${detail.memberCount} members',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final SharedHabitMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          UserAvatar(avatarUrl: member.avatarUrl, name: member.username, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          if (member.completedToday)
            const Icon(LucideIcons.circleCheck, size: 20, color: AppColors.success)
          else
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textDisabled),
              ),
            ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.detail,
    required this.userId,
    required this.busy,
    required this.onComplete,
    required this.onJoin,
    required this.onLeave,
  });

  final SharedHabitDetail detail;
  final int? userId;
  final Set<Object> busy;
  final VoidCallback onComplete;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final done = detail.completedTodayFor(userId);
    final isBusy = busy.contains('complete-${detail.myHabitId}') ||
        busy.contains('join-${detail.id}') ||
        busy.contains('leave-${detail.id}');

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!detail.amIMember)
            PrimaryButton(label: 'Join This Habit', loading: isBusy, onPressed: onJoin)
          else if (done)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.success15,
                borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.circleCheck, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Completed Today',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )
          else
            PrimaryButton(label: 'Mark as Done', loading: isBusy, onPressed: onComplete),
          if (detail.amIMember) ...[
            const SizedBox(height: 8),
            Pressable(
              onTap: isBusy ? null : onLeave,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Leave Group',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
