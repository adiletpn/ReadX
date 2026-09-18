import '../core/utils/json.dart';
import 'badge.dart';
import 'post.dart';

class PublicProfile {
  const PublicProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.bio,
    required this.avatarUrl,
    required this.instagram,
    required this.telegram,
    required this.bookName,
    required this.bookAuthor,
    required this.showBook,
    required this.bookCurrentPage,
    required this.bookTotalPages,
    required this.totalPoints,
    required this.monthlyPoints,
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
    required this.habitCount,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.badges,
    required this.posts,
  });

  final int id;
  final String username;
  final String name;
  final String surname;
  final String bio;
  final String? avatarUrl;
  final String instagram;
  final String telegram;
  final String bookName;
  final String bookAuthor;
  final bool showBook;
  final int bookCurrentPage;
  final int bookTotalPages;
  final int totalPoints;
  final int monthlyPoints;
  final int postsCount;
  final int commentsCount;
  final int likesReceived;
  final int habitCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final List<Badge> badges;
  final List<Post> posts;

  String get displayName {
    final full = '$name $surname'.trim();
    return full.isEmpty ? username : full;
  }

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    final id = asInt(json['id']);
    final username = asString(json['username']);
    final avatarUrl = asStringOrNull(json['avatar_url']);

    final rawPosts = json['posts'];
    final posts = rawPosts is List
        ? mapList(
            rawPosts
                .whereType<Map>()
                .map((p) => {
                      ...asMap(p),
                      'user_id': id,
                      'username': username,
                      'avatar_url': avatarUrl,
                    })
                .toList(),
            Post.fromJson,
          )
        : const <Post>[];

    return PublicProfile(
      id: id,
      username: username,
      name: asString(json['name']),
      surname: asString(json['surname']),
      bio: asString(json['bio']),
      avatarUrl: avatarUrl,
      instagram: asString(json['instagram']),
      telegram: asString(json['telegram']),
      bookName: asString(json['book_name']),
      bookAuthor: asString(json['book_author']),
      showBook: asBool(json['show_book']),
      bookCurrentPage: asInt(json['book_current_page']),
      bookTotalPages: asInt(json['book_total_pages']),
      totalPoints: asInt(json['total_points']),
      monthlyPoints: asInt(json['monthlyPoints']),
      postsCount: asInt(json['postsCount']),
      commentsCount: asInt(json['commentsCount']),
      likesReceived: asInt(json['likesReceived']),
      habitCount: asInt(json['habitCount']),
      followersCount: asInt(json['followersCount']),
      followingCount: asInt(json['followingCount']),
      isFollowing: asBool(json['isFollowing']),
      badges: mapList(json['badges'], Badge.fromJson),
      posts: posts,
    );
  }

  PublicProfile copyWith({bool? isFollowing, int? followersCount}) => PublicProfile(
        id: id,
        username: username,
        name: name,
        surname: surname,
        bio: bio,
        avatarUrl: avatarUrl,
        instagram: instagram,
        telegram: telegram,
        bookName: bookName,
        bookAuthor: bookAuthor,
        showBook: showBook,
        bookCurrentPage: bookCurrentPage,
        bookTotalPages: bookTotalPages,
        totalPoints: totalPoints,
        monthlyPoints: monthlyPoints,
        postsCount: postsCount,
        commentsCount: commentsCount,
        likesReceived: likesReceived,
        habitCount: habitCount,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount,
        isFollowing: isFollowing ?? this.isFollowing,
        badges: badges,
        posts: posts,
      );
}

class FollowUser {
  const FollowUser({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.avatarUrl,
    required this.isFollowing,
  });

  final int id;
  final String username;
  final String name;
  final String surname;
  final String? avatarUrl;
  final bool isFollowing;

  String get displayName {
    final full = '$name $surname'.trim();
    return full.isEmpty ? username : full;
  }

  factory FollowUser.fromJson(Map<String, dynamic> json) => FollowUser(
        id: asInt(json['id']),
        username: asString(json['username']),
        name: asString(json['name']),
        surname: asString(json['surname']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        isFollowing: asBool(json['isFollowing']),
      );

  FollowUser copyWith({bool? isFollowing}) => FollowUser(
        id: id,
        username: username,
        name: name,
        surname: surname,
        avatarUrl: avatarUrl,
        isFollowing: isFollowing ?? this.isFollowing,
      );
}

class SearchUser {
  const SearchUser({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.avatarUrl,
    required this.totalPoints,
  });

  final int id;
  final String username;
  final String name;
  final String surname;
  final String? avatarUrl;
  final int totalPoints;

  String get displayName {
    final full = '$name $surname'.trim();
    return full.isEmpty ? username : full;
  }

  factory SearchUser.fromJson(Map<String, dynamic> json) => SearchUser(
        id: asInt(json['id']),
        username: asString(json['username']),
        name: asString(json['name']),
        surname: asString(json['surname']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        totalPoints: asInt(json['total_points']),
      );
}
