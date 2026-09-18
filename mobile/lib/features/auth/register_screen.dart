import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import 'auth_controller.dart';

/// Регистрация — порт RegisterPage.tsx.
///
/// The two client-side patterns are the ones the web uses, which in turn match
/// `registerSchema` in server/schemas.js — so a form that passes here is not
/// rejected by the server for a different reason.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Инлайновая ошибка показывается только после того, как поле теряло фокус —
  /// как `touched` в вебе.
  final _touched = <String>{};

  String _error = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _surname, _username, _email, _password]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in [_name, _surname, _username, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _markTouched(String field) {
    if (_touched.add(field)) setState(() {});
  }

  bool get _usernameValid => RegisterScreen._usernamePattern.hasMatch(_username.text.trim());
  bool get _emailValid => RegisterScreen._emailPattern.hasMatch(_email.text.trim());

  String get _usernameError =>
      _touched.contains('username') && _username.text.isNotEmpty && !_usernameValid
          ? '3-20 characters: letters, numbers, underscore only'
          : '';

  String get _emailError => _touched.contains('email') && _email.text.isNotEmpty && !_emailValid
      ? 'Enter a valid email address'
      : '';

  String get _passwordError =>
      _password.text.isNotEmpty && _password.text.length < 6 ? 'Password must be at least 6 characters' : '';

  bool get _isValid =>
      _name.text.trim().isNotEmpty &&
      _surname.text.trim().isNotEmpty &&
      _usernameValid &&
      _emailValid &&
      _password.text.length >= 6;

  Future<void> _submit() async {
    setState(() => _touched.addAll(['name', 'surname', 'username', 'email', 'password']));
    if (!_isValid || _loading) return;
    setState(() {
      _error = '';
      _loading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text,
            surname: _surname.text,
            username: _username.text,
            email: _email.text,
            password: _password.text,
          );
    } on ApiException catch (e) {
      // "Username or email already exists" arrives as a 400 — the form keeps
      // everything the user typed so only the clashing field needs changing.
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
        title: 'Create Account',
        trailing: const SizedBox(width: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          if (_error.isNotEmpty) ...[
            AppErrorBanner(message: _error),
            const SizedBox(height: 12),
          ],
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _markTouched('name');
            },
            child: AppTextField(
              controller: _name,
              hintText: 'Name',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _markTouched('surname');
            },
            child: AppTextField(
              controller: _surname,
              hintText: 'Surname',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _markTouched('username');
            },
            child: AppTextField(
              controller: _username,
              hintText: 'Username',
              maxLength: 20,
              autocorrect: false,
              hasError: _usernameError.isNotEmpty,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            ),
          ),
          _FieldHint(
            text: _usernameError.isNotEmpty ? _usernameError : 'Username will be public.',
            isError: _usernameError.isNotEmpty,
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _markTouched('email');
            },
            child: AppTextField(
              controller: _email,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              hasError: _emailError.isNotEmpty,
              textInputAction: TextInputAction.next,
            ),
          ),
          if (_emailError.isNotEmpty) _FieldHint(text: _emailError, isError: true),
          const SizedBox(height: 12),
          AppTextField(
            controller: _password,
            hintText: 'Password (min 6 chars)',
            obscureText: true,
            revealToggle: true,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_passwordError.isNotEmpty) _FieldHint(text: _passwordError, isError: true),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _loading ? 'Creating…' : 'Create Account',
            enabled: _isValid,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'By creating an account, you agree to the rules of fair competition.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDisabled),
            ),
          ),
          const SizedBox(height: 8),
          const _LegalLinks(),
        ],
      ),
    );
  }
}

class _FieldHint extends StatelessWidget {
  const _FieldHint({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isError ? AppColors.danger : AppColors.textDisabled,
        ),
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  static Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'By creating an account you agree to the ',
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDisabled),
          ),
          Pressable(
            onTap: () => _open(kTermsUrl),
            child: const Text('Terms', style: linkStyle),
          ),
          const Text(
            ' and ',
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDisabled),
          ),
          Pressable(
            onTap: () => _open(kPrivacyUrl),
            child: const Text('Privacy Policy', style: linkStyle),
          ),
          const Text(
            '.',
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}
