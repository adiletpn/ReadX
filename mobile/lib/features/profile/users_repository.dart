import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../models/public_profile.dart';

class FollowResult {
  const FollowResult({required this.following, required this.followersCount});

  final bool following;
  final int followersCount;

  factory FollowResult.fromJson(Map<String, dynamic> json) => FollowResult(
        following: asBool(json['following']),
        followersCount: asInt(json['followersCount']),
      );
}

class ProfileFormData {
  const ProfileFormData({
    required this.username,
    required this.name,
    required this.surname,
    required this.bio,
    required this.instagram,
    required this.telegram,
    required this.bookName,
    required this.bookAuthor,
    required this.showBook,
    required this.bookCurrentPage,
    required this.bookTotalPages,
  });

  final String username;
  final String name;
  final String surname;
  final String bio;
  final String instagram;
  final String telegram;
  final String bookName;
  final String bookAuthor;
  final bool showBook;
  final int bookCurrentPage;
  final int bookTotalPages;

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'surname': surname,
        'bio': bio,
        'instagram': instagram,
        'telegram': telegram,
        'book_name': bookName,
        'book_author': bookAuthor,
        'show_book': showBook ? 1 : 0,
        'book_current_page': bookCurrentPage,
        'book_total_pages': bookTotalPages,
      };
}

class UsersRepository {
  UsersRepository(this._api);

  final ApiClient _api;

  Future<PublicProfile> profile(int id) async {
    return PublicProfile.fromJson(asMap(await _api.get(Endpoints.user(id))));
  }

  Future<List<SearchUser>> search(String query) async {
    return mapList(
      await _api.get(Endpoints.userSearch, query: {'q': query}),
      SearchUser.fromJson,
    );
  }

  Future<FollowResult> toggleFollow(int id) async {
    return FollowResult.fromJson(asMap(await _api.post(Endpoints.userFollow(id))));
  }

  Future<List<FollowUser>> followers(int id) async {
    return mapList(await _api.get(Endpoints.userFollowers(id)), FollowUser.fromJson);
  }

  Future<List<FollowUser>> following(int id) async {
    return mapList(await _api.get(Endpoints.userFollowing(id)), FollowUser.fromJson);
  }

  Future<void> updateProfile(ProfileFormData data) async {
    await _api.put(Endpoints.userProfile, body: data.toJson());
  }

  Future<String> uploadAvatar(String filePath) async {
    final data = asMap(await _api.upload(
      Endpoints.userAvatar,
      field: Endpoints.uploadFieldAvatar,
      filePath: filePath,
    ));
    return asString(data['avatar_url']);
  }

  Future<List<Comment>> userComments(int userId) async {
    return mapList(await _api.get(Endpoints.userComments(userId)), Comment.fromJson);
  }

  Future<List<Comment>> myLikedComments(int userId) async {
    return mapList(await _api.get(Endpoints.myLikedComments(userId)), Comment.fromJson);
  }

  Future<List<Post>> likedPosts() async {
    return mapList(await _api.get(Endpoints.postsLiked), Post.fromJson);
  }
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiClientProvider)),
);
