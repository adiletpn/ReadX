import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/auth/auth_controller.dart';
import 'package:readx/features/profile/my_profile_controller.dart';

import '../../helpers/fake_api.dart';

Map<String, Object?> _post(int id, int userId) => {
      'id': id,
      'user_id': userId,
      'username': userId == 2 ? 'me' : 'other',
      'content': 'пост $id',
      'time': '5m ago',
      'likes': 0,
      'commentsCount': 0,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  ProviderContainer container({String? token = 'jwt'}) {
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(buildTestClient(backend, token: token))],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'jwt'});
    backend = FakeBackend();
    backend
      ..on('GET', Endpoints.me, body: {'id': 2, 'username': 'me', 'totalPoints': 50})
      ..on('GET', Endpoints.posts, body: [_post(1, 2), _post(2, 3), _post(3, 2)])
      ..on('GET', Endpoints.postsLiked, body: [_post(9, 3)])
      ..on('GET', Endpoints.userComments(2), body: [
        {'id': 1, 'post_id': 5, 'user_id': 2, 'username': 'me', 'content': 'мой коммент'},
      ])
      ..on('GET', Endpoints.myLikedComments(2), body: [
        {'id': 2, 'post_id': 5, 'user_id': 3, 'username': 'other', 'content': 'чужой'},
      ]);
  });

  group('tabs', () {
    test('open on Posts, with Likes showing posts first', () {
      final c = container();

      expect(c.read(profileTabProvider), ProfileTab.posts);
      expect(c.read(likesSubTabProvider), LikesSubTab.posts);
    });

    test('selecting a tab moves the state', () {
      final c = container();

      c.read(profileTabProvider.notifier).select(ProfileTab.comments);
      c.read(likesSubTabProvider.notifier).select(LikesSubTab.comments);

      expect(c.read(profileTabProvider), ProfileTab.comments);
      expect(c.read(likesSubTabProvider), LikesSubTab.comments);
    });
  });

  group('my posts', () {
    test('are filtered out of the global feed by author', () async {
      final c = container();
      await c.read(authControllerProvider.future);

      final posts = await c.read(myPostsProvider.future);

      expect(posts.map((p) => p.id), [1, 3]);
    });

    test('a signed-out session has none', () async {
      final c = container(token: null);
      await c.read(authControllerProvider.future);

      expect(await c.read(myPostsProvider.future), isEmpty);
    });
  });

  group('likes', () {
    test('liked posts come from the liked endpoint', () async {
      final c = container();
      await c.read(authControllerProvider.future);

      expect((await c.read(myLikedPostsProvider.future)).single.id, 9);
    });

    test('liked comments use the per-user liked path', () async {
      final c = container();
      await c.read(authControllerProvider.future);

      expect((await c.read(myLikedCommentsProvider.future)).single.id, 2);
      expect(backend.requests.any((r) => r.path == '/comments/user/2/liked'), isTrue);
    });
  });

  group('my comments', () {
    test('are read for my own id', () async {
      final c = container();
      await c.read(authControllerProvider.future);

      expect((await c.read(myCommentsProvider.future)).single.content, 'мой коммент');
      expect(backend.requests.any((r) => r.path == '/comments/user/2'), isTrue);
    });

    test('a signed-out session has none', () async {
      final c = container(token: null);
      await c.read(authControllerProvider.future);

      expect(await c.read(myCommentsProvider.future), isEmpty);
    });
  });
}
