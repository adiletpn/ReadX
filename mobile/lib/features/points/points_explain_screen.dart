import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/surfaces.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../settings/app_settings.dart';

class PointsExplainScreen extends ConsumerWidget {
  const PointsExplainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threshold =
        (ref.watch(appSettingsProvider).value ?? AppSettings.fallback).lotteryThreshold;

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'How Points Work',
        trailing: const SizedBox(width: 36),
      ),
      bottomNav: const BottomNav(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 24, AppMetrics.hPadding, 28),
        children: [
          const Text(
            'Compete. Improve. Win.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Earn points through consistent reading habits, climb the leaderboard, '
            'and qualify for monthly rewards.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const _RuleCard(
            title: '1. Registration Bonus',
            bullets: [
              '+100 points one-time bonus for creating your account',
              'Applies automatically when you sign up',
            ],
          ),
          const _RuleCard(
            title: '2. Daily Post',
            bullets: [
              '+10 points per day for posting',
              'Maximum 10 points per day regardless of how many posts you make',
              'Post about your reading progress, thoughts, or discoveries',
            ],
          ),
          const _RuleCard(
            title: '3. Habit Completion',
            bullets: [
              'Monthly Streak = Points earned',
              'The longer your streak, the more points you earn',
            ],
            note: _Note(
              label: 'Example:',
              labelColor: AppColors.textPrimary,
              background: AppColors.bg,
              border: AppColors.border,
              text: ' Complete "Read 30 Min" daily for 30 days → '
                  '30 streak points earned for the month',
            ),
            extraBullets: [
              'Monthly streak resets on the 1st of each month',
              'Lifetime streak is tracked separately and never resets',
            ],
          ),
          const _RuleCard(
            title: '4. Skip Rules',
            bullets: [
              'You get 2 skips per month',
              'Skips let you miss a day without losing your streak',
              'Missing a 3rd day resets your entire streak',
              'Skips refresh on the 1st of each month',
            ],
          ),
          const _RuleCard(
            title: '5. Monthly Reset',
            bullets: [
              'Monthly points reset on the 1st',
              'Monthly streaks reset on the 1st',
              'Total (lifetime) points never reset',
              'Total leaderboard reflects all-time performance',
            ],
          ),
          _RuleCard(
            title: '6. Monthly Merch Lottery',
            bullets: [
              'Reach $threshold monthly points to qualify',
              '5-10 winners selected randomly each month',
              'Winners receive exclusive ReadX merch',
            ],
            note: const _Note(
              label: 'Fair play:',
              labelColor: AppColors.primary,
              background: Color(0x140077FF),
              border: Color(0x260077FF),
              text: ' Every qualified person has an equal chance — '
                  "leaderboard rank doesn't affect lottery odds.",
            ),
          ),
          const _RuleCard(
            title: '7. Leaderboards',
            bullets: [
              'Monthly leaderboard — resets each month, competitive',
              'Total leaderboard — lifetime cumulative points',
              'Rankings are updated in real-time',
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Rules are subject to change.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF2E2E2E)),
          ),
        ],
      ),
    );
  }
}

class _Note {
  const _Note({
    required this.label,
    required this.labelColor,
    required this.background,
    required this.border,
    required this.text,
  });

  final String label;
  final Color labelColor;
  final Color background;
  final Color border;
  final String text;
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.title,
    required this.bullets,
    this.note,
    this.extraBullets = const [],
  });

  final String title;
  final List<String> bullets;
  final _Note? note;
  final List<String> extraBullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < bullets.length; i++)
            _Bullet(text: bullets[i], highlight: i == 0),
          if (note != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: note!.background,
                border: Border.all(color: note!.border),
                borderRadius: BorderRadius.circular(AppMetrics.radiusField),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: note!.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: note!.labelColor,
                      ),
                    ),
                    TextSpan(text: note!.text),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          if (extraBullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final bullet in extraBullets) _Bullet(text: bullet, highlight: false),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.highlight});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: highlight ? AppColors.primary : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
