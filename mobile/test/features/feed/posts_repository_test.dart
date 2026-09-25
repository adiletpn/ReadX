import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/feed/posts_repository.dart';

import '../../helpers/fake_api.dart';

Map<String, Object?> _postRow({int id = 1, String content = 'hello'}) => {
      'id': id,
      'user_id': 2,
      'username': 'reader',
      'content': content,
      'time': '5m ago',
      'created_at': '2026-09-24 12:00:00',
      'likes': 3,
      'liked': 1,
      'commentsCount': 2,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late PostsRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = PostsRepository(buildTestClient(backend, token: 'jwt'));
  });

  group('feed', () {
    test('each tab hits its own endpoint', () async {
      backend
        ..on('GET', Endpoints.postsFollowing, body: [_postRow()])
        ..on('GET', Endpoints.posts, body: [_postRow(id: 2)])
        ..on('GET', Endpoints.postsLiked, body: [_postRow(id: 3)]);

      expect((await repo.feed(FeedTab.following)).single.id, 1);
      expect((await repo.feed(FeedTab.global)).single.id, 2);
      expect((await repo.feed(FeedTab.liked)).single.id, 3);
    });

    test('an empty feed is an empty list, not a failure', () async {
      backend.on('GET', Endpoints.posts, body: const []);

      expect(await repo.feed(FeedTab.global), isEmpty);
    });

    test('one malformed row does not blank out the feed', () async {
      backend.on('GET', Endpoints.posts, body: [_postRow(), 'garbage', _postRow(id: 2)]);

      expect((await repo.feed(FeedTab.global)).length, 2);
    });
  });

  group('creating', () {
    test('sends only the content when there is no image', () async {
      backend.on('POST', Endpoints.posts, body: _postRow());

      await repo.create(content: 'Дочитал главу');

      expect(backend.lastRequest.body, {'content': 'Дочитал главу'});
    });

    test('includes the uploaded image url when there is one', () async {
      backend.on('POST', Endpoints.posts, body: _postRow());

      await repo.create(content: 'фото', imageUrl: '/uploads/1.png');

      expect(backend.lastRequest.body, {
        'content': 'фото',
        'image_url': '/uploads/1.png',
      });
    });

    test('an empty image url is left out rather than sent blank', () async {
      backend.on('POST', Endpoints.posts, body: _postRow());

      await repo.create(content: 'текст', imageUrl: '');

      expect(backend.lastRequest.body, {'content': 'текст'});
    });
  });

  group('likes', () {
    test('a toggle returns the new state and count from the server', () async {
      backend.on('POST', Endpoints.postLike(7), body: {'liked': 1, 'likes': 12});

      final result = await repo.toggleLike(7);

      expect(result.liked, isTrue);
      expect(result.likes, 12);
    });

    test('comment likes use the comment endpoint', () async {
      backend.on('POST', Endpoints.commentLike(3), body: {'liked': 0, 'likes': 1});

      final result = await repo.toggleCommentLike(3);

      expect(result.liked, isFalse);
      expect(backend.lastRequest.path, '/comments/3/like');
    });
  });

  group('comments', () {
    test('a reply carries its parent id', () async {
      backend.on('POST', Endpoints.postComments(4), body: {
        'id': 9,
        'post_id': 4,
        'user_id': 2,
        'username': 'reader',
        'content': 'agreed',
        'parent_id': 8,
        'time': 'just now',
      });

      final comment = await repo.addComment(postId: 4, content: 'agreed', parentId: 8);

      expect(backend.lastRequest.body, {'content': 'agreed', 'parent_id': 8});
      expect(comment.parentId, 8);
    });

    test('a top-level comment sends no parent id', () async {
      backend.on('POST', Endpoints.postComments(4), body: {'id': 9, 'content': 'hi'});

      await repo.addComment(postId: 4, content: 'hi');

      expect(backend.lastRequest.body, {'content': 'hi'});
    });
  });

  group('deleting', () {
    test('a post and a comment each hit their own path', () async {
      backend
        ..on('DELETE', Endpoints.post(5), body: {'deleted': true})
        ..on('DELETE', Endpoints.comment(6), body: {'deleted': true});

      await repo.delete(5);
      await repo.deleteComment(6);

      expect(backend.requests.map((r) => r.path), ['/posts/5', '/comments/6']);
    });
  });
}
