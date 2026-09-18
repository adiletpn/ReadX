import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/busy_set.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../models/shared_habit.dart';
import 'feed_controller.dart';
import 'posts_repository.dart';

class PostDetail {
  const PostDetail({required this.post, required this.comments});

  final Post post;
  final List<Comment> comments;

  PostDetail copyWith({Post? post, List<Comment>? comments}) =>
      PostDetail(post: post ?? this.post, comments: comments ?? this.comments);
}

class PostDetailController extends AsyncNotifier<PostDetail> {
  PostDetailController(this.postId);

  final int postId;

  @override
  Future<PostDetail> build() async {
    final repo = ref.read(postsRepositoryProvider);
    final results = await Future.wait([repo.post(postId), repo.comments(postId)]);
    return PostDetail(
      post: results[0] as Post,
      comments: results[1] as List<Comment>,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<String?> toggleLike() async {
    final detail = state.value;
    if (detail == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'like-post-$postId';
    if (!busy.start(key)) return null;

    final previous = detail.post;
    _setPost(previous.copyWith(
      liked: !previous.liked,
      likes: previous.liked ? previous.likes - 1 : previous.likes + 1,
    ));

    try {
      final result = await ref.read(postsRepositoryProvider).toggleLike(postId);
      final updated = previous.copyWith(liked: result.liked, likes: result.likes);
      _setPost(updated);
      ref.read(feedProvider.notifier).upsert(updated);
      return null;
    } on Object catch (e) {
      _setPost(previous);
      return e.toString();
    } finally {
      busy.finish(key);
    }
  }

  Future<String?> toggleCommentLike(int commentId) async {
    final detail = state.value;
    if (detail == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'like-comment-$commentId';
    if (!busy.start(key)) return null;

    final index = detail.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) {
      busy.finish(key);
      return null;
    }

    final previous = detail.comments[index];
    _setComment(previous.copyWith(
      liked: !previous.liked,
      likes: previous.liked ? previous.likes - 1 : previous.likes + 1,
    ));

    try {
      final result = await ref.read(postsRepositoryProvider).toggleCommentLike(commentId);
      _setComment(previous.copyWith(liked: result.liked, likes: result.likes));
      return null;
    } on Object catch (e) {
      _setComment(previous);
      return e.toString();
    } finally {
      busy.finish(key);
    }
  }

  Future<void> addComment({required String content, int? parentId}) async {
    final detail = state.value;
    if (detail == null) return;

    final comment = await ref.read(postsRepositoryProvider).addComment(
          postId: postId,
          content: content,
          parentId: parentId,
        );

    final updatedPost = detail.post.copyWith(commentsCount: detail.post.commentsCount + 1);
    state = AsyncData(PostDetail(
      post: updatedPost,
      comments: [...detail.comments, comment],
    ));
    ref.read(feedProvider.notifier).upsert(updatedPost);
  }

  Future<void> deleteComment(int commentId) async {
    final detail = state.value;
    if (detail == null) return;

    await ref.read(postsRepositoryProvider).deleteComment(commentId);

    final remaining = detail.comments
        .where((c) => c.id != commentId && c.parentId != commentId)
        .toList();
    final removed = detail.comments.length - remaining.length;
    final updatedPost = detail.post.copyWith(
      commentsCount: (detail.post.commentsCount - removed).clamp(0, 1 << 30),
    );

    state = AsyncData(PostDetail(post: updatedPost, comments: remaining));
    ref.read(feedProvider.notifier).upsert(updatedPost);
  }

  Future<void> deletePost() => ref.read(feedProvider.notifier).deletePost(postId);

  void setSharedHabit(SharedHabitSummary shared) {
    final detail = state.value;
    if (detail == null) return;
    final updated = detail.post.copyWith(sharedHabit: shared);
    _setPost(updated);
    ref.read(feedProvider.notifier).upsert(updated);
  }

  void _setPost(Post post) {
    final detail = state.value;
    if (detail == null) return;
    state = AsyncData(detail.copyWith(post: post));
  }

  void _setComment(Comment comment) {
    final detail = state.value;
    if (detail == null) return;
    final index = detail.comments.indexWhere((c) => c.id == comment.id);
    if (index == -1) return;
    final next = [...detail.comments];
    next[index] = comment;
    state = AsyncData(detail.copyWith(comments: next));
  }
}

final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailController, PostDetail, int>(
  PostDetailController.new,
);
