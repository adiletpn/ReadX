import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import 'auth_repository.dart';

/// Новый пароль — порт ResetPasswordPage.tsx.
///
/// The token comes from the `?token=` on the reset link the email carries, so
/// this screen is reached by a universal link rather than from inside the app.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _done = false;
  Timer? _redirect;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _redirect?.cancel();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _passwordsMatch => _password.text.isNotEmpty && _password.text == _confirm.text;

  bool get _isValid => widget.token.isNotEmpty && _password.text.length >= 6 && _passwordsMatch;

  Future<void> _submit() async {
    if (!_isValid || _loading) return;
    setState(() {
      _error = '';
      _loading = true;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: widget.token,
            password: _password.text,
          );
      if (!mounted) return;
      setState(() => _done = true);
      // Two seconds to read the confirmation, then back to the login form —
      // the same delay the web uses.
      _redirect = Timer(const Duration(seconds: 2), () {
        if (mounted) context.go(AppRoutes.login);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) return const _InvalidLink();

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.go(AppRoutes.login),
        ),
        title: 'Жаңа құпия сөз',
        trailing: const SizedBox(width: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          if (_done)
            const AppSuccessBanner(
              message: 'Құпия сөз сәтті өзгертілді. Кіру бетіне бағыттаудамыз…',
            )
          else ...[
            if (_error.isNotEmpty) ...[
              AppErrorBanner(message: _error),
              const SizedBox(height: 12),
            ],
            AppTextField(
              controller: _password,
              hintText: 'Жаңа құпия сөз (min 6 chars)',
              obscureText: true,
              revealToggle: true,
              autocorrect: false,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirm,
              hintText: 'Құпия сөзді қайталаңыз',
              obscureText: true,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            if (_confirm.text.isNotEmpty && !_passwordsMatch)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Құпия сөздер сәйкес келмейді',
                  style: TextStyle(fontSize: 11, color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: _loading ? 'Сақталуда…' : 'Құпия сөзді сақтау',
              enabled: _isValid,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ],
      ),
    );
  }
}

/// Открыли `/reset-password` без токена — ссылка битая.
class _InvalidLink extends StatelessWidget {
  const _InvalidLink();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppMetrics.contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Сілтеме жарамсыз',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 16),
                Pressable(
                  onTap: () => context.go(AppRoutes.forgotPassword),
                  child: const Text(
                    'Қайта сұрау',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
