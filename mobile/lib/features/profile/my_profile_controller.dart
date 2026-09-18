import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/comment.dart';
import '../../models/post.dart';
import '../auth/auth_controller.dart';
import '../feed/posts_repository.dart';
import 'users_repository.dart';

enum ProfileTab { posts, likes, comments }

enum LikesSubTab { posts, comments }

class ProfileTabState extends Notifier<ProfileTab> {
  @override
  ProfileTab build() => ProfileTab.posts;

  void select(ProfileTab tab) => state = tab;
}

class LikesSubTabState extends Notifier<LikesSubTab> {
  @override
  LikesSubTab build() => LikesSubTab.posts;

  void select(LikesSubTab tab) => state = tab;
}

final profileTabProvider = NotifierProvider<ProfileTabState, ProfileTab>(ProfileTabState.new);

final likesSubTabProvider =
    NotifierProvider<LikesSubTabState, LikesSubTab>(LikesSubTabState.new);

final myPostsProvider = FutureProvider<List<Post>>((ref) async {
  final me = ref.watch(currentUserProvider);
  if (me == null) return const [];
  final all = await ref.read(postsRepositoryProvider).feed(FeedTab.global);
  return all.where((p) => p.userId == me.id).toList();
});

final myLikedPostsProvider = FutureProvider<List<Post>>((ref) async {
  return ref.read(usersRepositoryProvider).likedPosts();
});

final myCommentsProvider = FutureProvider<List<Comment>>((ref) async {
  final me = ref.watch(currentUserProvider);
  if (me == null) return const [];
  return ref.read(usersRepositoryProvider).userComments(me.id);
});

final myLikedCommentsProvider = FutureProvider<List<Comment>>((ref) async {
  final me = ref.watch(currentUserProvider);
  if (me == null) return const [];
  return ref.read(usersRepositoryProvider).myLikedComments(me.id);
});
