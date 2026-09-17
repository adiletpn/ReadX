import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import 'auth_repository.dart';

/// Восстановление пароля — порт ForgotPasswordPage.tsx. Тексты на казахском
/// перенесены дословно.
///
/// The confirmation text is the screen's own, not the server's `message`:
/// the API replies with a shorter sentence, and the web has always shown this
/// longer one.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _isValid => ForgotPasswordScreen._emailPattern.hasMatch(_email.text.trim());

  Future<void> _submit() async {
    if (!_isValid || _loading) return;
    setState(() {
      _error = '';
      _loading = true;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.go(AppRoutes.login),
        ),
        title: 'Құпия сөзді қалпына келтіру',
        trailing: const SizedBox(width: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          if (_sent)
            const AppSuccessBanner(
              message: 'Егер бұл email тіркелген болса, құпия сөзді қалпына келтіру '
                  'сілтемесі жіберілді. Пошта жәшігіңізді тексеріңіз.',
            )
          else ...[
            const Text(
              'Тіркелген email-ыңызды енгізіңіз — қалпына келтіру сілтемесін жібереміз.',
              style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (_error.isNotEmpty) ...[
              AppErrorBanner(message: _error),
              const SizedBox(height: 12),
            ],
            AppTextField(
              controller: _email,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: _loading ? 'Жіберілуде…' : 'Сілтеме жіберу',
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
