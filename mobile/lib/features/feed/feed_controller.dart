import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/busy_set.dart';
import '../../models/post.dart';
import 'posts_repository.dart';

class FeedTabController extends Notifier<FeedTab> {
  @override
  FeedTab build() => FeedTab.global;

  void select(FeedTab tab) => state = tab;
}

final feedTabProvider = NotifierProvider<FeedTabController, FeedTab>(FeedTabController.new);

class FeedController extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final tab = ref.watch(feedTabProvider);
    return ref.read(postsRepositoryProvider).feed(tab);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(postsRepositoryProvider).feed(ref.read(feedTabProvider)),
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    await refresh();
  }

  Future<String?> toggleLike(int postId) async {
    final posts = state.value;
    if (posts == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'like-post-$postId';
    if (!busy.start(key)) return null;

    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) {
      busy.finish(key);
      return null;
    }

    final previous = posts[index];
    _replace(previous.copyWith(
      liked: !previous.liked,
      likes: previous.liked ? previous.likes - 1 : previous.likes + 1,
    ));

    try {
      final result = await ref.read(postsRepositoryProvider).toggleLike(postId);
      _replace(previous.copyWith(liked: result.liked, likes: result.likes));
      return null;
    } on Object catch (e) {
      _replace(previous);
      return e.toString();
    } finally {
      busy.finish(key);
    }
  }

  Future<void> deletePost(int postId) async {
    await ref.read(postsRepositoryProvider).delete(postId);
    final posts = state.value;
    if (posts == null) return;
    state = AsyncData(posts.where((p) => p.id != postId).toList());
  }

  void upsert(Post post) {
    final posts = state.value;
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;
    final next = [...posts];
    next[index] = post;
    state = AsyncData(next);
  }

  void invalidateCache() => ref.invalidateSelf();

  void _replace(Post post) {
    final posts = state.value;
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;
    final next = [...posts];
    next[index] = post;
    state = AsyncData(next);
  }
}

final feedProvider = AsyncNotifierProvider<FeedController, List<Post>>(FeedController.new);
