import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/leaderboard.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/readx_logo.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../settings/app_settings.dart';
import 'points_repository.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  bool _monthly = true;

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(leaderboardProvider);
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.fallback;
    final me = ref.watch(currentUserProvider);

    return AppScaffold(
      header: AppHeader(
        middle: const ReadXLogo(),
        trailing: HeaderIconButton(
          icon: LucideIcons.info,
          semanticLabel: 'How points work',
          onTap: () => context.push(AppRoutes.pointsHowItWorks),
        ),
      ),
      bottomNav: const BottomNav(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async => ref.invalidate(leaderboardProvider),
        child: switch (leaderboard) {
          AsyncData(:final value) => ListView(
              key: const PageStorageKey('points'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _ScoreCard(me: value.me, threshold: settings.lotteryThreshold),
                const SizedBox(height: 16),
                _QualificationCard(me: value.me, threshold: settings.lotteryThreshold),
                const SizedBox(height: 20),
                _Segmented(
                  monthly: _monthly,
                  onChanged: (v) => setState(() => _monthly = v),
                ),
                const SizedBox(height: 16),
                ..._buildList(value, me?.id),
              ],
            ),
          AsyncError(:final error) => ErrorState(
              message: error is ApiException
                  ? error.message
                  : 'Не удалось загрузить рейтинг',
              onRetry: () => ref.invalidate(leaderboardProvider),
            ),
          _ => const LoadingState(),
        },
      ),
    );
  }

  List<Widget> _buildList(Leaderboard board, int? myId) {
    final entries = _monthly ? board.monthly : board.total;

    if (entries.isEmpty) {
      return const [
        EmptyState(
          title: 'Ещё никто не заработал очков в этом месяце.',
          subtitle: 'Выполни привычки — стань первым!',
        ),
      ];
    }

    final inTop = entries.any((e) => e.id == myId);
    final myPoints = _monthly ? board.me.monthlyPoints : board.me.totalPoints;
    final myRank = _monthly ? board.me.monthlyRank : board.me.totalRank;

    return [
      for (final entry in entries)
        _LeaderRow(entry: entry, isMe: entry.id == myId),
      if (!inTop) ...[
        const SizedBox(height: 20),
        const Text('YOUR POSITION', style: AppText.overline),
        const SizedBox(height: 12),
        if (myPoints == 0)
          const Text(
            'Ещё не заработал очков в этом месяце.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          )
        else
          _LeaderRow(
            entry: LeaderboardEntry(
              rank: myRank,
              id: myId ?? 0,
              username: '',
              name: '',
              surname: '',
              avatarUrl: null,
              points: myPoints,
            ),
            isMe: true,
          ),
      ],
    ];
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.me, required this.threshold});

  final LeaderboardMe me;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final qualified = me.monthlyPoints >= threshold;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${me.monthlyPoints}', style: AppText.counter),
                  const SizedBox(height: 2),
                  const Text(
                    'Monthly Points',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#${me.monthlyRank}',
                    style: AppText.counter.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Monthly Rank',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Points',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${me.totalPoints}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              if (qualified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success15,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '✓ Lottery Qualified',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QualificationCard extends StatelessWidget {
  const _QualificationCard({required this.me, required this.threshold});

  final LeaderboardMe me;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final progress = threshold == 0 ? 0.0 : (me.monthlyPoints / threshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Merch Qualification', style: AppText.cardTitle),
              Text(
                '${me.monthlyPoints}/$threshold',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceHi,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.monthly, required this.onChanged});

  final bool monthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.radiusField),
      ),
      child: Row(
        children: [
          Expanded(child: _segment('Monthly', monthly, () => onChanged(true))),
          Expanded(child: _segment('Total', !monthly, () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push(isMe ? AppRoutes.profile : AppRoutes.user(entry.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppMetrics.radiusField),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            UserAvatar(avatarUrl: entry.avatarUrl, name: entry.displayName, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${entry.points}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
