import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/comment.dart';
import '../../models/post.dart';

enum FeedTab { following, global, liked }

extension FeedTabEndpoint on FeedTab {
  String get path => switch (this) {
        FeedTab.following => Endpoints.postsFollowing,
        FeedTab.global => Endpoints.posts,
        FeedTab.liked => Endpoints.postsLiked,
      };

  String get label => switch (this) {
        FeedTab.following => 'Following',
        FeedTab.global => 'For You',
        FeedTab.liked => 'Liked',
      };

  String get hint => switch (this) {
        FeedTab.following => 'Posts from your network',
        FeedTab.global => 'Global posts shared today',
        FeedTab.liked => 'Posts you liked',
      };
}

class LikeResult {
  const LikeResult({required this.liked, required this.likes});

  final bool liked;
  final int likes;

  factory LikeResult.fromJson(Map<String, dynamic> json) => LikeResult(
        liked: asBool(json['liked']),
        likes: asInt(json['likes']),
      );
}

class PostsRepository {
  PostsRepository(this._api);

  final ApiClient _api;

  Future<List<Post>> feed(FeedTab tab) async {
    return mapList(await _api.get(tab.path), Post.fromJson);
  }

  Future<Post> post(int id) async {
    return Post.fromJson(asMap(await _api.get(Endpoints.post(id))));
  }

  Future<Post> create({required String content, String? imageUrl}) async {
    final body = <String, dynamic>{'content': content};
    if (imageUrl != null && imageUrl.isNotEmpty) body['image_url'] = imageUrl;
    return Post.fromJson(asMap(await _api.post(Endpoints.posts, body: body)));
  }

  Future<void> delete(int id) async {
    await _api.delete(Endpoints.post(id));
  }

  Future<LikeResult> toggleLike(int id) async {
    return LikeResult.fromJson(asMap(await _api.post(Endpoints.postLike(id))));
  }

  Future<String> uploadImage(String filePath) async {
    final data = asMap(await _api.upload(
      Endpoints.postsUpload,
      field: Endpoints.uploadFieldImage,
      filePath: filePath,
    ));
    return asString(data['image_url']);
  }

  Future<List<Comment>> comments(int postId) async {
    return mapList(await _api.get(Endpoints.postComments(postId)), Comment.fromJson);
  }

  Future<Comment> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final body = <String, dynamic>{'content': content};
    if (parentId != null) body['parent_id'] = parentId;
    return Comment.fromJson(
      asMap(await _api.post(Endpoints.postComments(postId), body: body)),
    );
  }

  Future<void> deleteComment(int id) async {
    await _api.delete(Endpoints.comment(id));
  }

  Future<LikeResult> toggleCommentLike(int id) async {
    return LikeResult.fromJson(asMap(await _api.post(Endpoints.commentLike(id))));
  }
}

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(ref.watch(apiClientProvider)),
);
