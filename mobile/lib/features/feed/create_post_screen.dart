import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'feed_controller.dart';
import 'posts_repository.dart';

const kPostEmojis = [
  '📖', '📚', '📕', '📗', '📘', '📙', '🧠', '💡', '✍️', '📝',
  '🔥', '💪', '🎯', '⭐', '🏆', '🥇', '✅', '💯', '🤔', '💭',
  '🌟', '📈', '🚀', '⏰', '☕', '🎧', '🌙', '🌅', '❤️', '👏',
];

const _maxChars = 100;

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  bool _showEmojis = false;
  bool _posting = false;
  bool _uploading = false;
  String _imageError = '';
  File? _preview;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _isValid => _text.text.trim().isNotEmpty && !_uploading;

  Color get _counterColor {
    final count = _text.text.length;
    if (count >= 95) return AppColors.danger;
    if (count >= 80) return AppColors.warning;
    return AppColors.textDisabled;
  }

  Future<void> _pickImage() async {
    if (_preview != null) return;

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } on Object {
      if (mounted) setState(() => _imageError = 'Не удалось открыть галерею');
      return;
    }
    if (picked == null || !mounted) return;

    setState(() {
      _imageError = '';
      _preview = File(picked!.path);
      _uploading = true;
    });

    try {
      final compressed = await _compress(picked.path);
      final url = await ref.read(postsRepositoryProvider).uploadImage(compressed);
      if (!mounted) return;
      setState(() => _imageUrl = url);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _imageError = e.message;
        _preview = null;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _imageError = 'Не удалось загрузить изображение';
        _preview = null;
      });
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<String> _compress(String path) async {
    final dir = await getTemporaryDirectory();
    final target = '${dir.path}/readx_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      target,
      quality: 80,
      minWidth: 1280,
      minHeight: 1280,
      keepExif: false,
    );
    return result?.path ?? path;
  }

  void _removeImage() {
    setState(() {
      _preview = null;
      _imageUrl = null;
      _imageError = '';
    });
  }

  void _insertEmoji(String emoji) {
    if (_text.text.length + emoji.length > _maxChars) return;
    _text.text = _text.text + emoji;
    _text.selection = TextSelection.collapsed(offset: _text.text.length);
  }

  Future<void> _post() async {
    if (!_isValid || _posting) return;
    setState(() => _posting = true);

    try {
      await ref.read(postsRepositoryProvider).create(
            content: _text.text.trim(),
            imageUrl: _imageUrl,
          );
      ref.read(feedProvider.notifier).invalidateCache();
      await ref.read(authControllerProvider.notifier).refresh();
      if (mounted) context.go(AppRoutes.feed);
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      header: AppHeader(
        leading: Pressable(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        title: 'New Post',
        trailing: Pressable(
          onTap: _isValid && !_posting ? _post : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              _posting ? '…' : 'Post',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isValid && !_posting ? AppColors.primary : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
      bottomBar: _buildToolbar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(avatarUrl: user?.avatarUrl, name: user?.username ?? '', size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    autofocus: true,
                    maxLength: _maxChars,
                    maxLines: null,
                    minLines: 3,
                    cursorColor: AppColors.primary,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_imageError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppErrorBanner(message: _imageError),
            ),
          if (_preview != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                  child: Stack(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: Image.file(_preview!, fit: BoxFit.cover),
                      ),
                      if (_uploading)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: const Center(
                              child: LoadingSpinner(size: 20, color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Pressable(
                          onTap: _removeImage,
                          pressedOpacity: 0.7,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.x, size: 14, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_text.text.length}/$_maxChars',
                style: TextStyle(
                  fontSize: 12,
                  color: _counterColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          if (_showEmojis)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final emoji in kPostEmojis)
                    Pressable(
                      onTap: () => _insertEmoji(emoji),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          Pressable(
            onTap: () => setState(() => _showEmojis = !_showEmojis),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                LucideIcons.smile,
                size: 22,
                color: _showEmojis ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Pressable(
            onTap: _preview == null ? _pickImage : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                LucideIcons.image,
                size: 22,
                color: _preview == null ? AppColors.textSecondary : AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
