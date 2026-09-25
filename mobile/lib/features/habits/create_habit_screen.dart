import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/surfaces.dart';
import '../../core/theme/typography.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/section_header.dart';
import '../feed/feed_controller.dart';
import 'habits_controller.dart';
import 'habits_repository.dart';

const _maxTitle = 40;
const _maxCaption = 300;

const _streakRules = [
  'Complete your habit daily to maintain your streak',
  'You get 2 skips per month — use them wisely',
  'Missing a 3rd day resets your entire streak',
  'Skips refresh on the 1st of each month',
];

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _title = TextEditingController();
  final _caption = TextEditingController();

  bool _earnPoints = true;
  bool _isShared = false;
  bool _saving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _caption.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _caption.dispose();
    super.dispose();
  }

  bool get _isValid => _title.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() {
      _saving = true;
      _error = '';
    });

    final repo = ref.read(habitsRepositoryProvider);
    final title = _title.text.trim();

    try {
      if (_isShared) {
        final result = await repo.createShared(
          title: title,
          isPointEligible: _earnPoints,
          caption: _caption.text.trim(),
        );
        ref.read(feedProvider.notifier).invalidateCache();
        await ref.read(habitsProvider.notifier).refresh();
        if (!mounted) return;

        final message = result.eligibleLimitReached
            ? '🎉 Shared! Friends can join it from your post now. '
                "(added without points — you're at your 5-habit limit)"
            : '🎉 Shared! Friends can join it from your post now.';
        context.go(AppRoutes.feed);
        AppToast.show(context, message);
      } else {
        final result = await repo.create(title: title, isPointEligible: _earnPoints);
        ref.read(habitsProvider.notifier).prepend(result.habit);
        if (!mounted) return;

        context.go(AppRoutes.habits);
        if (result.eligibleLimitReached) {
          AppToast.show(
            context,
            'You already have 5 point-earning habits — this one was added without points.',
            isError: true,
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Create Habit',
        trailing: Pressable(
          onTap: _isValid && !_saving ? _save : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              _isShared ? 'Share' : 'Save',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isValid && !_saving ? AppColors.primary : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
      bottomBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: PrimaryButton(
          label: _isShared ? 'Create & Share' : 'Create Habit',
          enabled: _isValid,
          loading: _saving,
          onPressed: _save,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 24, AppMetrics.hPadding, 28),
        children: [
          if (_error.isNotEmpty) ...[
            AppErrorBanner(message: _error),
            const SizedBox(height: 16),
          ],
          const SectionHeader(icon: LucideIcons.target, label: 'HABIT NAME'),
          AppTextField(
            controller: _title,
            hintText: 'Read 20 pages',
            maxLength: _maxTitle,
            radius: AppMetrics.radiusField,
            textCapitalization: TextCapitalization.sentences,
            suffix: Text(
              '${_title.text.length}/$_maxTitle',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDisabled,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ToggleCard(
            title: 'Earn Points for This Habit',
            subtitle: 'Maximum 5 habits can earn points.',
            value: _earnPoints,
            onChanged: (v) => setState(() => _earnPoints = v),
          ),
          const SizedBox(height: 12),
          _ToggleCard(
            title: 'Make it a Shared Habit',
            subtitle: 'Friends can join from your post.',
            value: _isShared,
            onChanged: (v) => setState(() => _isShared = v),
            child: _isShared
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppTextField(
                      controller: _caption,
                      hintText: "Say why you're starting this (optional)",
                      maxLength: _maxCaption,
                      maxLines: 3,
                      minLines: 2,
                      radius: AppMetrics.radiusField,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppSurfaces.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streak Rules', style: AppText.cardTitle),
                const SizedBox(height: 12),
                for (final rule in _streakRules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6, right: 10),
                          child: SizedBox(
                            width: 4,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.child,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.card(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppSwitch(value: value, onChanged: onChanged),
            ],
          ),
          ?child,
        ],
      ),
    );
  }
}
