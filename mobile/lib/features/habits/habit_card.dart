import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/habit.dart';
import '../../widgets/pressable.dart';
import '../../widgets/user_avatar.dart';

enum _Revealed { none, delete, undo }

class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.globalStreak,
    required this.skipsLimit,
    required this.busy,
    required this.onComplete,
    required this.onDelete,
    required this.onOpenShared,
  });

  final Habit habit;
  final int globalStreak;
  final int skipsLimit;
  final bool busy;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onOpenShared;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  static const _threshold = 80.0;
  static const _deleteWidth = 90.0;
  static const _edgeGuard = 20.0;

  _Revealed _revealed = _Revealed.none;
  double _offset = 0;
  bool _dragging = false;
  bool _ignoreDrag = false;

  double get _restingOffset => switch (_revealed) {
        _Revealed.delete => -_deleteWidth,
        _Revealed.undo => 80,
        _Revealed.none => 0,
      };

  void close() {
    if (_revealed == _Revealed.none) return;
    setState(() {
      _revealed = _Revealed.none;
      _offset = 0;
    });
  }

  void _onDragStart(DragStartDetails details) {
    _ignoreDrag = details.globalPosition.dx < _edgeGuard;
    if (_ignoreDrag) return;
    setState(() {
      _dragging = true;
      _offset = _restingOffset;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_ignoreDrag) return;
    setState(() => _offset = (_offset + details.delta.dx).clamp(-140.0, 120.0));
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_ignoreDrag) {
      _ignoreDrag = false;
      return;
    }

    final offset = _offset;
    setState(() => _dragging = false);

    if (offset <= -_threshold) {
      setState(() {
        _revealed = _Revealed.delete;
        _offset = -_deleteWidth;
      });
      return;
    }

    if (offset >= _threshold && widget.habit.completedToday) {
      setState(() {
        _revealed = _Revealed.undo;
        _offset = 80;
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _revealed = _Revealed.none;
        _offset = 0;
      });
      widget.onComplete();
      return;
    }

    setState(() {
      _revealed = _Revealed.none;
      _offset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final done = habit.completedToday;
    final translate = _dragging ? _offset : _restingOffset;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
        child: Stack(
          children: [
            Positioned.fill(child: _background(done)),
            GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTap: _revealed == _Revealed.none ? null : close,
              child: AnimatedContainer(
                duration: Duration(milliseconds: _dragging ? 0 : 180),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(translate, 0, 0),
                decoration: BoxDecoration(
                  color: done ? AppColors.habitDoneBg : AppColors.surface,
                  border: Border.all(color: done ? AppColors.habitDoneBorder : AppColors.border),
                  borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
                ),
                child: _content(habit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _background(bool done) {
    if (_revealed == _Revealed.undo || (_dragging && _offset > 0)) {
      return Container(
        color: AppColors.habitDoneBg,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.undo2, size: 20, color: AppColors.success),
            SizedBox(height: 4),
            Text(
              'Undo / Today',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Pressable(
        onTap: widget.onDelete,
        pressedOpacity: 0.8,
        child: Container(
          width: _deleteWidth,
          height: double.infinity,
          color: AppColors.danger,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.trash2, size: 18, color: AppColors.textPrimary),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(Habit habit) {
    final shared = habit.sharedHabit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (shared != null) ...[
                const SizedBox(width: 6),
                const _Chip(
                  label: 'Shared',
                  color: AppColors.success,
                  icon: LucideIcons.users,
                ),
              ],
              if (habit.isPointEligible) ...[
                const SizedBox(width: 6),
                const _Chip(label: 'Point Eligible', color: AppColors.primary),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.globalStreak}', style: AppText.counterSm),
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      Icon(LucideIcons.flame, size: 13, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text('Days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (habit.skipsRemaining > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${habit.skipsRemaining}/${widget.skipsLimit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Text(
                      'Skips left',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                )
              else
                const Text(
                  'No skips left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),
        if (shared != null)
          Pressable(
            onTap: widget.onOpenShared,
            pressedOpacity: 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 24,
                    width: shared.members.isEmpty
                        ? 0
                        : (shared.members.take(3).length - 1) * 16.0 + 28.0,
                    child: Stack(
                      children: [
                        for (var i = 0; i < shared.members.take(3).length; i++)
                          Positioned(
                            left: i * 16,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: UserAvatar(
                                avatarUrl: shared.members[i].avatarUrl,
                                name: shared.members[i].username,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(LucideIcons.flame, size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '${shared.currentStreak}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'group streak',
                        style: TextStyle(fontSize: 11, color: AppColors.textFaint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Pressable(
            onTap: habit.completedToday || widget.busy ? null : widget.onComplete,
            pressedOpacity: 0.8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: habit.completedToday ? AppColors.success15 : AppColors.primary,
                borderRadius: BorderRadius.circular(AppMetrics.radiusField),
              ),
              child: habit.completedToday
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.circleCheck, size: 16, color: AppColors.success),
                        SizedBox(width: 8),
                        Text(
                          'Completed Today',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Mark as Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}
