import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/pressable.dart';
import '../profile/users_repository.dart';

Future<void> showModerationMenu(
  BuildContext context,
  WidgetRef ref, {
  required ReportTarget target,
  required int targetId,
  required int authorId,
  required String username,
  VoidCallback? onBlocked,
}) async {
  final action = await showCupertinoModalPopup<String>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('report'),
          child: const Text('Report'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop('block'),
          child: Text('Block @$username'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  if (action == 'report') {
    await _report(context, ref, target: target, targetId: targetId);
    return;
  }

  final confirmed = await showConfirmSheet(
    context,
    title: 'Block @$username?',
    message: "You won't see their posts or comments, and they won't see yours.",
    confirmLabel: 'Block',
  );
  if (!confirmed || !context.mounted) return;

  try {
    await ref.read(usersRepositoryProvider).block(authorId);
    if (context.mounted) AppToast.show(context, 'Пользователь заблокирован');
    onBlocked?.call();
  } on ApiException catch (e) {
    if (context.mounted) AppToast.show(context, e.message, isError: true);
  }
}

Future<void> _report(
  BuildContext context,
  WidgetRef ref, {
  required ReportTarget target,
  required int targetId,
}) async {
  final reason = await showModalBottomSheet<ReportReason>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _ReasonSheet(),
  );
  if (reason == null || !context.mounted) return;

  String? details;
  if (reason.needsDetails) {
    details = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _DetailsSheet(),
    );
    if (details == null || details.trim().isEmpty || !context.mounted) return;
  }

  try {
    await ref.read(usersRepositoryProvider).report(
          target: target,
          targetId: targetId,
          reason: reason,
          details: details,
        );
    if (context.mounted) {
      AppToast.show(context, "Thanks. We'll review this within 24 hours.");
    }
  } on ApiException catch (e) {
    if (context.mounted) AppToast.show(context, e.message, isError: true);
  }
}

class _ReasonSheet extends StatelessWidget {
  const _ReasonSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
          border: Border.all(color: AppColors.surfaceHi2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Почему вы жалуетесь?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            for (final reason in ReportReason.values)
              Pressable(
                onTap: () => Navigator.of(context).pop(reason),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.surfaceHi2)),
                  ),
                  child: Text(
                    reason.label,
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailsSheet extends StatefulWidget {
  const _DetailsSheet();

  @override
  State<_DetailsSheet> createState() => _DetailsSheetState();
}

class _DetailsSheetState extends State<_DetailsSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
            border: Border.all(color: AppColors.surfaceHi2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Опишите проблему',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 4,
                  maxLength: 1000,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintText: 'Что именно не так?',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Pressable(
                onTap: _controller.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_controller.text),
                pressedOpacity: 0.8,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _controller.text.trim().isEmpty
                        ? AppColors.surfaceHi2
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                  ),
                  child: Text(
                    'Отправить',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _controller.text.trim().isEmpty
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
