import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/busy_set.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/habits/shared_habit_controller.dart';

import '../../helpers/fake_api.dart';

const _sharedId = 12;

Map<String, Object?> _detail({int members = 2, int? myHabitId = 31, int amIMember = 1}) => {
      'id': _sharedId,
      'title': 'Читать вместе',
      'created_by': 3,
      'member_count': members,
      'current_streak': 5,
      'longest_streak': 9,
      'post_id': 44,
      'am_i_member': amIMember,
      'my_habit_id': myHabitId,
      'members': [
        {'user_id': 3, 'username': 'creator', 'completed_today': 1},
        {'user_id': 2, 'username': 'me', 'completed_today': 0},
      ],
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
      ..on('GET', Endpoints.sharedHabit(_sharedId), body: _detail())
      ..on('GET', Endpoints.habits, body: const [])
      ..on('GET', Endpoints.posts, body: const []);
  });

  test('loads the group detail', () async {
    final detail = await container().read(sharedHabitProvider(_sharedId).future);

    expect(detail.title, 'Читать вместе');
    expect(detail.members.length, 2);
    expect(detail.amICreator(3), isTrue);
  });

  test('completing goes through my own habit, not the group', () async {
    backend.on('POST', Endpoints.habitComplete(31), body: {
      'habit_id': 31,
      'completed_today': true,
      'skips_remaining': 3,
    });
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    expect(await c.read(sharedHabitProvider(_sharedId).notifier).complete(), isNull);
    expect(backend.requests.any((r) => r.path == '/habits/31/complete'), isTrue);
  });

  test('a non-member has nothing to complete', () async {
    backend.on('GET', Endpoints.sharedHabit(_sharedId),
        body: _detail(myHabitId: null, amIMember: 0));
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    expect(await c.read(sharedHabitProvider(_sharedId).notifier).complete(), isNull);
    expect(backend.requests.any((r) => r.path.contains('/complete')), isFalse);
  });

  test('a failed complete returns the server message', () async {
    backend.on('POST', Endpoints.habitComplete(31),
        status: 400, body: {'error': 'Already completed today'});
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    expect(
      await c.read(sharedHabitProvider(_sharedId).notifier).complete(),
      'Already completed today',
    );
  });

  test('joining reloads the detail and the habit list', () async {
    backend.on('POST', Endpoints.sharedHabitJoin(_sharedId), body: {'habit_id': 31});
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);
    final detailReadsBefore =
        backend.requests.where((r) => r.path == '/habits/shared/$_sharedId').length;

    expect(await c.read(sharedHabitProvider(_sharedId).notifier).join(), isNull);

    expect(
      backend.requests.where((r) => r.path == '/habits/shared/$_sharedId').length,
      greaterThan(detailReadsBefore),
    );
    expect(backend.requests.any((r) => r.path == '/habits' && r.method == 'GET'), isTrue);
  });

  test('a double tap on Join only sends one request', () async {
    backend.on('POST', Endpoints.sharedHabitJoin(_sharedId), body: {'habit_id': 31});
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    final notifier = c.read(sharedHabitProvider(_sharedId).notifier);
    await Future.wait([notifier.join(), notifier.join()]);

    expect(backend.requests.where((r) => r.path.endsWith('/join')).length, 1);
    expect(c.read(busySetProvider), isEmpty);
  });

  test('leaving posts to leave and refreshes', () async {
    backend.on('POST', Endpoints.sharedHabitLeave(_sharedId), body: {'left': true});
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    expect(await c.read(sharedHabitProvider(_sharedId).notifier).leave(), isNull);
    expect(backend.requests.any((r) => r.path.endsWith('/leave')), isTrue);
  });

  test('a failed leave keeps the message and does not throw', () async {
    backend.on('POST', Endpoints.sharedHabitLeave(_sharedId),
        status: 400, body: {'error': 'Creator cannot leave'});
    final c = container();
    await c.read(sharedHabitProvider(_sharedId).future);

    expect(
      await c.read(sharedHabitProvider(_sharedId).notifier).leave(),
      'Creator cannot leave',
    );
  });
}
