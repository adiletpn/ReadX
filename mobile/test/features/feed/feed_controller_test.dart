import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/busy_set.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/feed/feed_controller.dart';
import 'package:readx/features/feed/posts_repository.dart';

import '../../helpers/fake_api.dart';

Map<String, Object?> _row({int id = 1, int likes = 3, int liked = 0}) => {
      'id': id,
      'user_id': 2,
      'username': 'reader',
      'content': 'пост $id',
      'time': '5m ago',
      'likes': likes,
      'liked': liked,
      'commentsCount': 0,
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
      ..on('GET', Endpoints.posts, body: [_row(), _row(id: 2)])
      ..on('GET', Endpoints.postsFollowing, body: [_row(id: 9)])
      ..on('GET', Endpoints.postsLiked, body: [_row(id: 7, liked: 1)]);
  });

  test('loads the global tab first, like the web', () async {
    final c = container();

    final posts = await c.read(feedProvider.future);

    expect(c.read(feedTabProvider), FeedTab.global);
    expect(posts.map((p) => p.id), [1, 2]);
  });

  test('switching tabs reloads from that tab endpoint', () async {
    final c = container();
    await c.read(feedProvider.future);

    c.read(feedTabProvider.notifier).select(FeedTab.following);

    expect((await c.read(feedProvider.future)).single.id, 9);
  });

  test('a like is applied straight away and confirmed by the server', () async {
    backend.on('POST', Endpoints.postLike(1), body: {'liked': 1, 'likes': 4});
    final c = container();
    await c.read(feedProvider.future);

    final error = await c.read(feedProvider.notifier).toggleLike(1);

    expect(error, isNull);
    final post = c.read(feedProvider).value!.firstWhere((p) => p.id == 1);
    expect(post.liked, isTrue);
    expect(post.likes, 4);
  });

  test('a failed like is rolled back to what it was', () async {
    backend.on('POST', Endpoints.postLike(1), status: 500, body: {'error': 'boom'});
    final c = container();
    await c.read(feedProvider.future);

    final error = await c.read(feedProvider.notifier).toggleLike(1);

    expect(error, isNotNull);
    final post = c.read(feedProvider).value!.firstWhere((p) => p.id == 1);
    expect(post.liked, isFalse);
    expect(post.likes, 3);
  });

  test('a second tap while the first is in flight is ignored', () async {
    backend.on('POST', Endpoints.postLike(1), body: {'liked': 1, 'likes': 4});
    final c = container();
    await c.read(feedProvider.future);

    final first = c.read(feedProvider.notifier).toggleLike(1);
    final second = c.read(feedProvider.notifier).toggleLike(1);
    await Future.wait([first, second]);

    expect(backend.requests.where((r) => r.path == '/posts/1/like').length, 1);
    expect(c.read(busySetProvider), isEmpty);
  });

  test('liking a post that is no longer in the list is a no-op', () async {
    final c = container();
    await c.read(feedProvider.future);

    expect(await c.read(feedProvider.notifier).toggleLike(999), isNull);
    expect(backend.requests.where((r) => r.path.contains('/like')), isEmpty);
  });

  test('a deleted post leaves the list without a reload', () async {
    backend.on('DELETE', Endpoints.post(1), body: {'deleted': true});
    final c = container();
    await c.read(feedProvider.future);

    await c.read(feedProvider.notifier).deletePost(1);

    expect(c.read(feedProvider).value!.map((p) => p.id), [2]);
  });

  test('upsert replaces a post in place and ignores unknown ids', () async {
    final c = container();
    final posts = await c.read(feedProvider.future);

    c.read(feedProvider.notifier).upsert(posts.first.copyWith(likes: 99));
    expect(c.read(feedProvider).value!.first.likes, 99);

    final before = c.read(feedProvider).value!;
    c.read(feedProvider.notifier).upsert(posts.first.copyWith(likes: 1).copyWith());
    expect(c.read(feedProvider).value!.length, before.length);
  });

  test('reload puts the screen back into its loading state', () async {
    final c = container();
    await c.read(feedProvider.future);

    final pending = c.read(feedProvider.notifier).reload();
    expect(c.read(feedProvider).isLoading, isTrue);

    await pending;
    expect(c.read(feedProvider).value, isNotNull);
  });
}
