import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/busy_set.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/profile/user_profile_controller.dart';

import '../../helpers/fake_api.dart';

const _userId = 4;

Map<String, Object?> _profile({int followers = 12, int following = 0}) => {
      'id': _userId,
      'username': 'reader',
      'name': 'Бекзат',
      'surname': 'Ким',
      'followersCount': followers,
      'followingCount': 3,
      'isFollowing': following,
      'posts': const [],
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
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'jwt'});
    backend = FakeBackend();
    backend
      ..on('GET', Endpoints.user(_userId), body: _profile())
      ..on('GET', Endpoints.me, body: {'id': 2, 'username': 'me'});
  });

  test('loads the profile', () async {
    final profile = await container().read(userProfileProvider(_userId).future);

    expect(profile.displayName, 'Бекзат Ким');
    expect(profile.followersCount, 12);
    expect(profile.isFollowing, isFalse);
  });

  test('following bumps the counter straight away and then confirms it', () async {
    backend.on('POST', Endpoints.userFollow(_userId),
        body: {'following': 1, 'followersCount': 13});
    final c = container();
    await c.read(userProfileProvider(_userId).future);

    expect(await c.read(userProfileProvider(_userId).notifier).toggleFollow(), isNull);

    final profile = c.read(userProfileProvider(_userId)).value!;
    expect(profile.isFollowing, isTrue);
    expect(profile.followersCount, 13);
  });

  test('unfollowing takes the counter back down', () async {
    backend
      ..on('GET', Endpoints.user(_userId), body: _profile(following: 1))
      ..on('POST', Endpoints.userFollow(_userId), body: {'following': 0, 'followersCount': 11});
    final c = container();
    await c.read(userProfileProvider(_userId).future);

    await c.read(userProfileProvider(_userId).notifier).toggleFollow();

    final profile = c.read(userProfileProvider(_userId)).value!;
    expect(profile.isFollowing, isFalse);
    expect(profile.followersCount, 11);
  });

  test('a failed follow is rolled back and the message returned', () async {
    backend.on('POST', Endpoints.userFollow(_userId), status: 500, body: {'error': 'boom'});
    final c = container();
    await c.read(userProfileProvider(_userId).future);

    final error = await c.read(userProfileProvider(_userId).notifier).toggleFollow();

    expect(error, 'Сервер недоступен. Попробуйте позже');
    final profile = c.read(userProfileProvider(_userId)).value!;
    expect(profile.isFollowing, isFalse);
    expect(profile.followersCount, 12);
  });

  test('a double tap only sends one follow request', () async {
    backend.on('POST', Endpoints.userFollow(_userId),
        body: {'following': 1, 'followersCount': 13});
    final c = container();
    await c.read(userProfileProvider(_userId).future);

    final notifier = c.read(userProfileProvider(_userId).notifier);
    await Future.wait([notifier.toggleFollow(), notifier.toggleFollow()]);

    expect(backend.requests.where((r) => r.path == '/users/$_userId/follow').length, 1);
    expect(c.read(busySetProvider), isEmpty);
  });

  test('two profiles on screen keep separate follow guards', () async {
    backend
      ..on('GET', Endpoints.user(5), body: {'id': 5, 'username': 'other', 'isFollowing': 0})
      ..on('POST', Endpoints.userFollow(_userId), body: {'following': 1, 'followersCount': 13})
      ..on('POST', Endpoints.userFollow(5), body: {'following': 1, 'followersCount': 1});
    final c = container();
    await c.read(userProfileProvider(_userId).future);
    await c.read(userProfileProvider(5).future);

    await Future.wait([
      c.read(userProfileProvider(_userId).notifier).toggleFollow(),
      c.read(userProfileProvider(5).notifier).toggleFollow(),
    ]);

    expect(backend.requests.where((r) => r.path.endsWith('/follow')).length, 2);
  });
}
