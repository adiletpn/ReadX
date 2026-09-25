import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/models/post.dart';
import 'package:readx/widgets/post_card.dart';

import '../helpers/harness.dart';

Post _post({
  int userId = 2,
  String content = 'Дочитал вторую главу',
  int likes = 3,
  bool liked = false,
  int comments = 1,
  String? image,
}) =>
    Post.fromJson({
      'id': 1,
      'user_id': userId,
      'username': 'reader',
      'content': content,
      'time': '5m ago',
      'created_at': '2026-09-24 12:00:00',
      'likes': likes,
      'liked': liked ? 1 : 0,
      'commentsCount': comments,
      'image_url': image,
    });

Future<void> _pumpCard(
  WidgetTester tester, {
  Post? post,
  int? currentUserId = 2,
  VoidCallback? onLike,
  VoidCallback? onComment,
  VoidCallback? onOpenUser,
  VoidCallback? onDelete,
  VoidCallback? onMore,
}) =>
    pumpWidgetUnderTest(
      tester,
      SingleChildScrollView(
        child: PostCard(
          post: post ?? _post(),
          currentUserId: currentUserId,
          onLike: onLike ?? () {},
          onComment: onComment ?? () {},
          onOpenUser: onOpenUser ?? () {},
          onDelete: onDelete,
          onMore: onMore,
        ),
      ),
    );

void main() {
  testWidgets('shows the author, the server time string and the counts', (tester) async {
    await _pumpCard(tester);

    expect(find.text('reader'), findsOneWidget);
    expect(find.text('5m ago'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('the like and comment callbacks fire', (tester) async {
    var likes = 0;
    var comments = 0;
    await _pumpCard(tester, onLike: () => likes++, onComment: () => comments++);

    await tester.tap(find.byIcon(LucideIcons.messageCircle));
    expect(comments, 1);

    await tester.tap(find.text('3'));
    expect(likes, 1);
  });

  testWidgets('tapping the name or the avatar opens the profile', (tester) async {
    var opened = 0;
    await _pumpCard(tester, onOpenUser: () => opened++);

    await tester.tap(find.text('reader'));
    expect(opened, 1);
  });

  testWidgets('a long post is clamped until Read more is tapped', (tester) async {
    await _pumpCard(tester, post: _post(content: 'а' * 400));

    final clamped = tester.widget<Text>(find.textContaining('ааа'));
    expect(clamped.maxLines, 4);
    expect(find.text('Read more'), findsOneWidget);

    await tester.tap(find.text('Read more'));
    await tester.pump();

    expect(tester.widget<Text>(find.textContaining('ааа')).maxLines, isNull);
    expect(find.text('Read more'), findsNothing);
  });

  testWidgets('a short post has no Read more', (tester) async {
    await _pumpCard(tester);

    expect(find.text('Read more'), findsNothing);
  });

  testWidgets('my own post offers delete, never report', (tester) async {
    await _pumpCard(tester, currentUserId: 2, onDelete: () {}, onMore: () {});

    expect(find.byIcon(LucideIcons.trash2), findsOneWidget);
    expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
  });

  testWidgets('someone else post offers the report menu, never delete', (tester) async {
    await _pumpCard(tester, currentUserId: 99, onDelete: () {}, onMore: () {});

    expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
    expect(find.byIcon(LucideIcons.trash2), findsNothing);
  });

  testWidgets('a signed-out reader gets neither action', (tester) async {
    await _pumpCard(tester, currentUserId: null);

    expect(find.byIcon(LucideIcons.trash2), findsNothing);
    expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
  });

  testWidgets('a post with no image renders nothing extra', (tester) async {
    await _pumpCard(tester);

    expect(find.byType(ClipRRect), findsNothing);
  });
}
