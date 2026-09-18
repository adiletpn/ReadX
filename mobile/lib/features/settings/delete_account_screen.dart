import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_controller.dart';
import '../profile/users_repository.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _password = TextEditingController();

  bool _deleting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty || _deleting) return;
    setState(() {
      _deleting = true;
      _error = '';
    });

    try {
      await ref.read(usersRepositoryProvider).deleteAccount(_password.text);
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) AppToast.show(context, 'Your account has been deleted.');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _deleting = false);
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
        title: 'Delete Account',
        trailing: const SizedBox(width: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Text(
            'Delete your account?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This will permanently delete your profile, posts, comments, habits, '
            'points and badges. This cannot be undone.',
            style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (_error.isNotEmpty) ...[
            AppErrorBanner(message: _error),
            const SizedBox(height: 16),
          ],
          const Text(
            'Введите пароль, чтобы подтвердить',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _password,
            hintText: 'Password',
            obscureText: true,
            revealToggle: true,
            autocorrect: false,
            radius: AppMetrics.radiusField,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _delete(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _deleting ? 'Deleting…' : 'Delete Account',
            enabled: _password.text.isNotEmpty,
            loading: _deleting,
            gradient: const [AppColors.danger, Color(0xFFFF7A5C)],
            onPressed: _delete,
          ),
        ],
      ),
    );
  }
}
