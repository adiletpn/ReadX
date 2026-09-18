import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../models/comment.dart';
import '../../models/shared_habit.dart';
import '../../router.dart';
import '../../widgets/animated_like_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/shared_habit_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../moderation/moderation_menu.dart';
import '../profile/users_repository.dart';
import 'post_detail_controller.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  Comment? _replyingTo;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  PostDetailController get _controller =>
      ref.read(postDetailProvider(widget.postId).notifier);

  void _openUser(int userId) {
    final me = ref.read(currentUserProvider);
    context.push(userId == me?.id ? AppRoutes.profile : AppRoutes.user(userId));
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _controller.addComment(content: text, parentId: _replyingTo?.id);
      if (!mounted) return;
      _input.clear();
      setState(() => _replyingTo = null);
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete post?',
      message: 'Are you sure you want to delete this post?',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    try {
      await _controller.deletePost();
      await ref.read(authControllerProvider.notifier).refresh();
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete comment?',
      message: 'Delete this comment?',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    try {
      await _controller.deleteComment(commentId);
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(postDetailProvider(widget.postId));
    final me = ref.watch(currentUserProvider);
    final busy = ref.watch(busySetProvider);
    final post = detail.value?.post;

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Post',
        trailing: post != null && me != null && post.userId == me.id
            ? HeaderIconButton(
                icon: LucideIcons.trash2,
                size: 20,
                semanticLabel: 'Delete post',
                color: AppColors.danger,
                onTap: _deletePost,
              )
            : const SizedBox(width: 36),
      ),
      bottomBar: detail.hasValue ? _buildComposer(me?.avatarUrl, me?.username ?? '') : null,
      body: switch (detail) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _PostBody(
                detail: value,
                likeBusy: busy.contains('like-post-${widget.postId}'),
                onLike: _like,
                onOpenUser: _openUser,
                onSharedHabitChanged: _controller.setSharedHabit,
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'COMMENTS · ${value.comments.length}',
                  style: AppText.overline,
                ),
              ),
              if (value.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Text(
                    'No comments yet',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                )
              else
                for (var i = 0; i < value.comments.length; i++)
                  _CommentTile(
                    comment: value.comments[i],
                    isLast: i == value.comments.length - 1,
                    isMine: me != null && value.comments[i].userId == me.id,
                    busy: busy.contains('like-comment-${value.comments[i].id}'),
                    onLike: () => _likeComment(value.comments[i].id),
                    onReply: () {
                      setState(() => _replyingTo = value.comments[i]);
                      _inputFocus.requestFocus();
                    },
                    onDelete: () => _deleteComment(value.comments[i].id),
                    onMore: () => showModerationMenu(
                      context,
                      ref,
                      target: ReportTarget.comment,
                      targetId: value.comments[i].id,
                      authorId: value.comments[i].userId,
                      username: value.comments[i].username,
                      onBlocked: _controller.reload,
                    ),
                    onOpenUser: () => _openUser(value.comments[i].userId),
                  ),
            ],
          ),
        AsyncError(:final error) => ErrorState(
            message: error is ApiException ? error.message : 'Не удалось загрузить пост',
            onRetry: () => _controller.reload(),
          ),
        _ => const LoadingState(),
      },
    );
  }

  Future<void> _like() async {
    final error = await _controller.toggleLike();
    if (error != null && mounted) {
      AppToast.show(context, 'Не удалось поставить лайк', isError: true);
    }
  }

  Future<void> _likeComment(int id) async {
    final error = await _controller.toggleCommentLike(id);
    if (error != null && mounted) {
      AppToast.show(context, 'Не удалось поставить лайк', isError: true);
    }
  }

  Widget _buildComposer(String? avatarUrl, String name) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Replying to '),
                          TextSpan(
                            text: '@${_replyingTo!.username}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Pressable(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(LucideIcons.x, size: 14, color: AppColors.textFaint),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                UserAvatar(avatarUrl: avatarUrl, name: name, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                      border: Border.all(
                        color: _input.text.isEmpty ? AppColors.border : AppColors.primary,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _input,
                      focusNode: _inputFocus,
                      maxLength: 2000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      cursorColor: AppColors.primary,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        hintText: _replyingTo == null
                            ? 'Write a reply…'
                            : 'Reply to @${_replyingTo!.username}…',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_input.text.isNotEmpty)
                  Pressable(
                    onTap: _send,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6, top: 6, bottom: 6),
                      child: Icon(LucideIcons.send, size: 20, color: AppColors.primary),
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

class _PostBody extends StatelessWidget {
  const _PostBody({
    required this.detail,
    required this.likeBusy,
    required this.onLike,
    required this.onOpenUser,
    required this.onSharedHabitChanged,
  });

  final PostDetail detail;
  final bool likeBusy;
  final VoidCallback onLike;
  final ValueChanged<int> onOpenUser;
  final ValueChanged<SharedHabitSummary> onSharedHabitChanged;

  @override
  Widget build(BuildContext context) {
    final post = detail.post;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => onOpenUser(post.userId),
                pressedOpacity: 0.7,
                child: UserAvatar(avatarUrl: post.avatarUrl, name: post.username, size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: () => onOpenUser(post.userId),
                  pressedOpacity: 0.7,
                  child: Text(
                    post.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
          ),
          if (post.sharedHabit != null) ...[
            const SizedBox(height: 12),
            SharedHabitCard(
              sharedHabit: post.sharedHabit!,
              onChanged: onSharedHabitChanged,
            ),
          ],
          const SizedBox(height: 12),
          Text(post.time, style: AppText.metaSm),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          Row(
            children: [
              AnimatedLikeButton(
                liked: post.liked,
                likes: post.likes,
                onTap: onLike,
                busy: likeBusy,
              ),
              const SizedBox(width: 20),
              const Icon(LucideIcons.messageCircle, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${detail.comments.length}',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isLast,
    required this.isMine,
    required this.busy,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    required this.onMore,
    required this.onOpenUser,
  });

  final Comment comment;
  final bool isLast;
  final bool isMine;
  final bool busy;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final VoidCallback onOpenUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isLast ? Colors.transparent : AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onTap: onOpenUser,
            pressedOpacity: 0.7,
            child: UserAvatar(avatarUrl: comment.avatarUrl, name: comment.username, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Pressable(
                        onTap: onOpenUser,
                        pressedOpacity: 0.7,
                        child: Text(
                          comment.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(comment.time, style: AppText.metaSm),
                    const Spacer(),
                    AnimatedLikeButton(
                      liked: comment.liked,
                      likes: comment.likes,
                      onTap: onLike,
                      size: 14,
                      busy: busy,
                    ),
                    if (isMine)
                      Pressable(
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
                          child: Icon(
                            LucideIcons.trash2,
                            size: 13,
                            color: Color(0x99FF3B30),
                          ),
                        ),
                      )
                    else
                      Pressable(
                        onTap: onMore,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
                          child: Icon(
                            LucideIcons.ellipsis,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      if (comment.replyToUsername != null)
                        TextSpan(
                          text: '@${comment.replyToUsername} ',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      TextSpan(text: comment.content),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textBody,
                  ),
                ),
                Pressable(
                  onTap: onReply,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.reply, size: 13, color: AppColors.textFaint),
                        SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textFaint,
                          ),
                        ),
                      ],
                    ),
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
