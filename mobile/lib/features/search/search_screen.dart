import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/public_profile.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/section_header.dart';
import '../auth/auth_controller.dart';
import '../profile/users_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();

  Timer? _debounce;
  List<SearchUser> _results = const [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  Future<void> _search() async {
    final text = _query.text.trim();
    if (text.isEmpty) {
      setState(() {
        _results = const [];
        _error = '';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final results = await ref.read(usersRepositoryProvider).search(text);
      if (!mounted || _query.text.trim() != text) return;
      setState(() => _results = results);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Search',
        trailing: const SizedBox(width: 36),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppMetrics.radiusField),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      autocorrect: false,
                      cursorColor: AppColors.primary,
                      style: AppText.field,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        hintText: 'Search people',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  if (_query.text.isNotEmpty)
                    Pressable(
                      onTap: _query.clear,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(LucideIcons.x, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SectionHeader(icon: LucideIcons.sparkles, label: 'SUGGESTED'),
          ),
          Expanded(child: _buildBody(me?.id)),
        ],
      ),
    );
  }

  Widget _buildBody(int? myId) {
    if (_error.isNotEmpty) {
      return ErrorState(message: _error, onRetry: _search);
    }
    if (_loading && _results.isEmpty) {
      return const LoadingState();
    }
    if (_results.isEmpty) {
      return EmptyState(
        icon: LucideIcons.search,
        title: _query.text.trim().isEmpty ? 'Find people to follow' : 'Никого не нашли',
        subtitle: _query.text.trim().isEmpty
            ? 'Start typing a name or username.'
            : 'Попробуй другое имя или ник.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final user = _results[index];
        return Pressable(
          onTap: () => context.push(
            user.id == myId ? AppRoutes.profile : AppRoutes.user(user.id),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                UserAvatar(avatarUrl: user.avatarUrl, name: user.displayName, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.flame, size: 12, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${user.totalPoints} points',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
