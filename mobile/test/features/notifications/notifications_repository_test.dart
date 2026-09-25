import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/notifications/notifications_repository.dart';
import 'package:readx/models/app_notification.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(buildTestClient(backend, token: 'jwt'))],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => backend = FakeBackend());

  group('list', () {
    test('parses the notification types the server sends', () async {
      backend.on('GET', Endpoints.notifications, body: [
        {'id': 1, 'type': 'like', 'actor_username': 'a', 'is_read': 0},
        {'id': 2, 'type': 'follow', 'actor_username': 'b', 'is_read': 1},
      ]);

      final repo = NotificationsRepository(buildTestClient(backend, token: 'jwt'));
      final items = await repo.list();

      expect(items.map((n) => n.type), [NotificationType.like, NotificationType.follow]);
      expect(items.first.isRead, isFalse);
    });

    test('an empty inbox is an empty list', () async {
      backend.on('GET', Endpoints.notifications, body: const []);

      final repo = NotificationsRepository(buildTestClient(backend, token: 'jwt'));
      expect(await repo.list(), isEmpty);
    });
  });

  group('unreadCount', () {
    test('reads the number off the unread endpoint', () async {
      backend.on('GET', Endpoints.notificationsUnread, body: {'unread': 7});

      final repo = NotificationsRepository(buildTestClient(backend, token: 'jwt'));
      expect(await repo.unreadCount(), 7);
    });

    test('a missing field counts as zero', () async {
      backend.on('GET', Endpoints.notificationsUnread, body: const <String, Object?>{});

      final repo = NotificationsRepository(buildTestClient(backend, token: 'jwt'));
      expect(await repo.unreadCount(), 0);
    });
  });

  group('the unread badge', () {
    test('a failed request leaves the badge at zero instead of erroring', () async {
      backend.on('GET', Endpoints.notificationsUnread, status: 500, body: {'error': 'boom'});

      expect(await container().read(unreadCountProvider.future), 0);
    });

    test('clear zeroes it without another request', () async {
      backend.on('GET', Endpoints.notificationsUnread, body: {'unread': 3});
      final c = container();

      expect(await c.read(unreadCountProvider.future), 3);
      final callsBefore = backend.requests.length;

      c.read(unreadCountProvider.notifier).clear();

      expect(c.read(unreadCountProvider).value, 0);
      expect(backend.requests.length, callsBefore);
    });
  });

  test('opening the list marks the badge as seen', () async {
    backend
      ..on('GET', Endpoints.notifications, body: [
        {'id': 1, 'type': 'like'},
      ])
      ..on('GET', Endpoints.notificationsUnread, body: {'unread': 4});
    final c = container();

    expect(await c.read(unreadCountProvider.future), 4);

    await c.read(notificationsProvider.future);

    expect(c.read(unreadCountProvider).value, 0);
  });
}
