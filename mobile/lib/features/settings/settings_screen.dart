import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/app_user.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../profile/users_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _bio = TextEditingController();
  final _instagram = TextEditingController();
  final _telegram = TextEditingController();
  final _bookName = TextEditingController();
  final _bookAuthor = TextEditingController();
  final _currentPage = TextEditingController();
  final _totalPages = TextEditingController();

  bool _showBook = false;
  bool _saving = false;
  bool _uploading = false;
  bool _saved = false;
  String _error = '';
  File? _localAvatar;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) _fill(user);
    for (final c in _controllers) {
      c.addListener(() => setState(() {}));
    }
  }

  List<TextEditingController> get _controllers => [
        _username,
        _name,
        _surname,
        _bio,
        _instagram,
        _telegram,
        _bookName,
        _bookAuthor,
        _currentPage,
        _totalPages,
      ];

  void _fill(AppUser user) {
    _username.text = user.username;
    _name.text = user.name;
    _surname.text = user.surname;
    _bio.text = user.bio;
    _instagram.text = user.instagram;
    _telegram.text = user.telegram;
    _bookName.text = user.bookName;
    _bookAuthor.text = user.bookAuthor;
    _currentPage.text = user.bookCurrentPage == 0 ? '' : '${user.bookCurrentPage}';
    _totalPages.text = user.bookTotalPages == 0 ? '' : '${user.bookTotalPages}';
    _showBook = user.showBook;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } on Object {
      if (mounted) setState(() => _error = 'Не удалось открыть галерею');
      return;
    }
    if (picked == null || !mounted) return;

    setState(() {
      _uploading = true;
      _error = '';
      _localAvatar = File(picked!.path);
    });

    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/readx_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target,
        quality: 75,
        minWidth: 800,
        minHeight: 800,
        keepExif: false,
      );
      await ref.read(usersRepositoryProvider).uploadAvatar(compressed?.path ?? picked.path);
      await ref.read(authControllerProvider.notifier).refresh();
      if (mounted) setState(() => _localAvatar = null);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _localAvatar = null;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить фото';
          _localAvatar = null;
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = '';
      _saved = false;
    });

    try {
      await ref.read(usersRepositoryProvider).updateProfile(
            ProfileFormData(
              username: _username.text.trim(),
              name: _name.text.trim(),
              surname: _surname.text.trim(),
              bio: _bio.text.trim(),
              instagram: _instagram.text.trim(),
              telegram: _telegram.text.trim(),
              bookName: _bookName.text.trim(),
              bookAuthor: _bookAuthor.text.trim(),
              showBook: _showBook,
              bookCurrentPage: int.tryParse(_currentPage.text.trim()) ?? 0,
              bookTotalPages: int.tryParse(_totalPages.text.trim()) ?? 0,
            ),
          );
      await ref.read(authControllerProvider.notifier).refresh();
      if (!mounted) return;
      setState(() => _saved = true);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: LoadingState());

    final progress = int.tryParse(_totalPages.text.trim()) ?? 0;
    final current = int.tryParse(_currentPage.text.trim()) ?? 0;

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Settings',
        trailing: const SizedBox(width: 36),
      ),
      bottomBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: PrimaryButton(
          label: 'Save Changes',
          loading: _saving,
          onPressed: _save,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(
            child: Stack(
              children: [
                if (_localAvatar != null)
                  ClipOval(
                    child: Image.file(
                      _localAvatar!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  UserAvatar(
                    avatarUrl: user.avatarUrl,
                    name: user.displayName,
                    size: 96,
                  ),
                if (_uploading)
                  const Positioned.fill(
                    child: ClipOval(
                      child: ColoredBox(
                        color: Color(0x80000000),
                        child: Center(
                          child: LoadingSpinner(size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Pressable(
                    onTap: _uploading ? null : _pickAvatar,
                    pressedOpacity: 0.8,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_error.isNotEmpty) ...[
            AppErrorBanner(message: _error),
            const SizedBox(height: 16),
          ],
          if (_saved) ...[
            const AppSuccessBanner(message: 'Settings saved successfully!'),
            const SizedBox(height: 16),
          ],
          const Text('ACCOUNT', style: AppText.overline),
          const SizedBox(height: 12),
          _Field(label: 'Nickname', controller: _username, maxLength: 30),
          _Field(label: 'Name', controller: _name, capitalize: true),
          _Field(label: 'Surname', controller: _surname, capitalize: true),
          _Field(label: 'Bio', controller: _bio, maxLength: 500, maxLines: 3),
          const SizedBox(height: 20),
          const Text('SOCIAL LINKS', style: AppText.overline),
          const SizedBox(height: 12),
          _Field(label: 'Instagram', controller: _instagram, maxLength: 50),
          _Field(label: 'Telegram', controller: _telegram, maxLength: 50),
          const SizedBox(height: 20),
          const Text('CURRENTLY READING', style: AppText.overline),
          const SizedBox(height: 12),
          _Field(label: 'Book', controller: _bookName, maxLength: 150),
          _Field(label: 'Author', controller: _bookAuthor, maxLength: 150),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Current page',
                  controller: _currentPage,
                  numeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  label: 'Total pages',
                  controller: _totalPages,
                  numeric: true,
                ),
              ),
            ],
          ),
          if (progress > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (current / progress).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceHi,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppMetrics.radiusField),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Show on profile', style: AppText.field),
                ),
                AppSwitch(
                  value: _showBook,
                  onChanged: (v) => setState(() => _showBook = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('PRIVACY', style: AppText.overline),
          const SizedBox(height: 12),
          _LinkRow(
            label: 'Blocked Users',
            onTap: () => context.push(AppRoutes.blockedUsers),
          ),
          const SizedBox(height: 24),
          const Text('DANGER ZONE', style: AppText.overline),
          const SizedBox(height: 12),
          Pressable(
            onTap: () => context.push(AppRoutes.deleteAccount),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.danger30),
                borderRadius: BorderRadius.circular(AppMetrics.radiusField),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, size: 18, color: AppColors.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppMetrics.radiusField),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.field)),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLength,
    this.maxLines = 1,
    this.numeric = false,
    this.capitalize = false,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;
  final bool numeric;
  final bool capitalize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          AppTextField(
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            minLines: maxLines > 1 ? maxLines : null,
            radius: AppMetrics.radiusField,
            autocorrect: !numeric,
            keyboardType: numeric ? TextInputType.number : null,
            textCapitalization:
                capitalize ? TextCapitalization.words : TextCapitalization.none,
            inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          ),
        ],
      ),
    );
  }
}
