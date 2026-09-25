import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/surfaces.dart';
import '../../core/theme/typography.dart';
import '../../widgets/entrance.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/skeleton.dart';
import '../../models/habit.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/readx_logo.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_controller.dart';
import '../settings/app_settings.dart';
import 'habit_card.dart';
import 'habits_controller.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  Future<void> _complete(BuildContext context, WidgetRef ref, int habitId) async {
    final outcome = await ref.read(habitsProvider.notifier).complete(habitId);
    if (!context.mounted) return;

    switch (outcome) {
      case CompleteAutoDeleted():
        AppToast.show(
          context,
          'Привычка удалена — пропущено слишком много дней',
          isError: true,
        );
      case CompleteFailed(:final message) when message.isNotEmpty:
        AppToast.show(context, message, isError: true);
      case CompleteFailed():
        break;
      case CompleteOk():
        break;
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int habitId) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete Habit?',
      message: 'This will permanently remove this habit. '
          'Points already earned will not be removed.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref.read(habitsProvider.notifier).delete(habitId);
    if (error != null && context.mounted) {
      AppToast.show(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.fallback;
    final busy = ref.watch(busySetProvider);

    final list = habits.value ?? const <Habit>[];
    final completed = list.where((h) => h.completedToday).length;
    final total = list.length;
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();

    return AppScaffold(
      header: const AppHeader(middle: ReadXLogo()),
      bottomNav: const BottomNav(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(habitsProvider.notifier).refresh(),
        child: ListView(
          key: const PageStorageKey('habits'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 16, AppMetrics.hPadding, 28),
          children: [
            _SummaryCard(
              monthlyPoints: user?.monthlyPoints ?? 0,
              streak: user?.currentStreak ?? 0,
              completed: completed,
              total: total,
              percent: percent,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MY HABITS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                Pressable(
                  onTap: () => context.push(AppRoutes.habitNew),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Swipe left to delete · Swipe right to undo',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 16),
            switch (habits) {
              AsyncData(:final value) when value.isEmpty => EmptyState(
                  illustrated: true,
                  title: 'No habits yet',
                  subtitle: 'Create your first habit to start tracking.',
                  action: SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      label: 'Create Habit',
                      onPressed: () => context.push(AppRoutes.habitNew),
                    ),
                  ),
                ),
              AsyncData(:final value) => Column(
                  children: [
                    for (final (index, habit) in value.indexed)
                      Entrance(
                        index: index,
                        child: HabitCard(
                        key: ValueKey(habit.id),
                        habit: habit,
                        globalStreak: user?.currentStreak ?? 0,
                        skipsLimit: settings.skipsLimit,
                        busy: busy.contains('complete-${habit.id}'),
                        onComplete: () => _complete(context, ref, habit.id),
                        onDelete: () => _delete(context, ref, habit.id),
                        onOpenShared: () => context.push(
                          AppRoutes.sharedHabit(habit.sharedHabit!.id),
                        ),
                      ),
                      ),
                  ],
                ),
              AsyncError(:final error) => ErrorState(
                  message: error is ApiException
                      ? error.message
                      : 'Не удалось загрузить привычки',
                  onRetry: () => ref.read(habitsProvider.notifier).reload(),
                ),
              _ => const ListSkeleton(count: 3, height: 150),
            },
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthlyPoints,
    required this.streak,
    required this.completed,
    required this.total,
    required this.percent,
  });

  final int monthlyPoints;
  final int streak;
  final int completed;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppSurfaces.card(radius: AppMetrics.radiusHero, glow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCounter(value: monthlyPoints, style: AppText.counter),
                  const SizedBox(height: 2),
                  const Text(
                    'Monthly Points',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(LucideIcons.flame, size: 22, color: AppColors.warning),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GradientText(
                        '$streak',
                        style: AppText.counter,
                        gradient: AppSurfaces.textStreak,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Day Streak',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed of $total done today',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.surfaceHi),
                LayoutBuilder(
                  builder: (context, box) => AnimatedContainer(
                    duration: AppDuration.slow,
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: total == 0 ? 0 : box.maxWidth * (completed / total),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.brandGradient),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
