import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/feed/post_detail_controller.dart';

import '../../helpers/fake_api.dart';

const _postId = 4;

Map<String, Object?> _post({int likes = 3, int liked = 0, int comments = 2}) => {
      'id': _postId,
      'user_id': 2,
      'username': 'reader',
      'content': 'пост',
      'time': '5m ago',
      'likes': likes,
      'liked': liked,
      'commentsCount': comments,
    };

Map<String, Object?> _comment({int id = 1, int? parentId, int likes = 0, int liked = 0}) => {
      'id': id,
      'post_id': _postId,
      'user_id': 3,
      'username': 'other',
      'content': 'коммент $id',
      'parent_id': parentId,
      'likes': likes,
      'liked': liked,
      'time': '1m ago',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(buildTestClient(backend, token: 'jwt'))],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    backend = FakeBackend();
    backend
      ..on('GET', Endpoints.posts, body: [_post()])
      ..on('GET', Endpoints.post(_postId), body: _post())
      ..on('GET', Endpoints.postComments(_postId), body: [_comment(), _comment(id: 2)]);
  });

  test('loads the post and its comments in one go', () async {
    final detail = await container().read(postDetailProvider(_postId).future);

    expect(detail.post.id, _postId);
    expect(detail.comments.length, 2);
  });

  test('a like updates the post and is confirmed by the server', () async {
    backend.on('POST', Endpoints.postLike(_postId), body: {'liked': 1, 'likes': 4});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    expect(await c.read(postDetailProvider(_postId).notifier).toggleLike(), isNull);

    final post = c.read(postDetailProvider(_postId)).value!.post;
    expect(post.liked, isTrue);
    expect(post.likes, 4);
  });

  test('a failed like is rolled back', () async {
    backend.on('POST', Endpoints.postLike(_postId), status: 500, body: {'error': 'boom'});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    expect(await c.read(postDetailProvider(_postId).notifier).toggleLike(), isNotNull);

    final post = c.read(postDetailProvider(_postId)).value!.post;
    expect(post.liked, isFalse);
    expect(post.likes, 3);
  });

  test('a comment like only touches that comment', () async {
    backend.on('POST', Endpoints.commentLike(1), body: {'liked': 1, 'likes': 1});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    await c.read(postDetailProvider(_postId).notifier).toggleCommentLike(1);

    final comments = c.read(postDetailProvider(_postId)).value!.comments;
    expect(comments.firstWhere((x) => x.id == 1).liked, isTrue);
    expect(comments.firstWhere((x) => x.id == 2).liked, isFalse);
  });

  test('a new comment is appended and the counter goes up', () async {
    backend.on('POST', Endpoints.postComments(_postId), body: _comment(id: 3));
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    await c.read(postDetailProvider(_postId).notifier).addComment(content: 'новый');

    final detail = c.read(postDetailProvider(_postId)).value!;
    expect(detail.comments.last.id, 3);
    expect(detail.post.commentsCount, 3);
  });

  test('deleting a comment also removes its replies from the count', () async {
    backend
      ..on('GET', Endpoints.postComments(_postId), body: [
        _comment(),
        _comment(id: 2, parentId: 1),
        _comment(id: 3),
      ])
      ..on('DELETE', Endpoints.comment(1), body: {'deleted': true});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    await c.read(postDetailProvider(_postId).notifier).deleteComment(1);

    final detail = c.read(postDetailProvider(_postId)).value!;
    expect(detail.comments.map((x) => x.id), [3]);
    expect(detail.post.commentsCount, 0);
  });

  test('the comment count never goes below zero', () async {
    backend
      ..on('GET', Endpoints.post(_postId), body: _post(comments: 0))
      ..on('GET', Endpoints.postComments(_postId), body: [_comment()])
      ..on('DELETE', Endpoints.comment(1), body: {'deleted': true});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    await c.read(postDetailProvider(_postId).notifier).deleteComment(1);

    expect(c.read(postDetailProvider(_postId)).value!.post.commentsCount, 0);
  });

  test('a second like tap while one is in flight is ignored', () async {
    backend.on('POST', Endpoints.postLike(_postId), body: {'liked': 1, 'likes': 4});
    final c = container();
    await c.read(postDetailProvider(_postId).future);

    final notifier = c.read(postDetailProvider(_postId).notifier);
    await Future.wait([notifier.toggleLike(), notifier.toggleLike()]);

    expect(backend.requests.where((r) => r.path == '/posts/$_postId/like').length, 1);
  });
}
