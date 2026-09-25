import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/busy_set.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/habits/habits_controller.dart';
import 'package:readx/models/habit.dart';

import '../../helpers/fake_api.dart';

Map<String, Object?> _row({int id = 1, int completed = 0, int streak = 4}) => {
      'id': id,
      'user_id': 2,
      'title': 'Читать $id',
      'streak': streak,
      'completed_today': completed,
      'is_point_eligible': 1,
      'skips_remaining': 3,
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
      ..on('GET', Endpoints.habits, body: [_row(), _row(id: 2)])
      ..on('GET', Endpoints.me, body: {'id': 2, 'username': 'reader', 'totalPoints': 10});
  });

  test('loads the habit list', () async {
    expect((await container().read(habitsProvider.future)).length, 2);
  });

  test('completing flips the habit and reports the points awarded', () async {
    backend.on('POST', Endpoints.habitComplete(1), body: {
      'habit_id': 1,
      'completed_today': true,
      'points_awarded': 2,
      'skips_remaining': 2,
    });
    final c = container();
    await c.read(habitsProvider.future);

    final outcome = await c.read(habitsProvider.notifier).complete(1);

    expect(outcome, isA<CompleteOk>());
    expect((outcome as CompleteOk).pointsAwarded, 2);
    final habit = c.read(habitsProvider).value!.firstWhere((h) => h.id == 1);
    expect(habit.completedToday, isTrue);
    expect(habit.skipsRemaining, 2);
  });

  test('un-completing awards nothing', () async {
    backend.on('POST', Endpoints.habitComplete(1), body: {
      'habit_id': 1,
      'completed_today': false,
      'skips_remaining': 3,
    });
    final c = container();
    await c.read(habitsProvider.future);

    final outcome = await c.read(habitsProvider.notifier).complete(1) as CompleteOk;

    expect(outcome.completed, isFalse);
    expect(outcome.pointsAwarded, isNull);
  });

  test('a habit the server auto-deleted drops out of the list', () async {
    backend.on('POST', Endpoints.habitComplete(1), body: {'deleted': true});
    final c = container();
    await c.read(habitsProvider.future);

    final outcome = await c.read(habitsProvider.notifier).complete(1);

    expect(outcome, isA<CompleteAutoDeleted>());
    expect(c.read(habitsProvider).value!.map((h) => h.id), [2]);
  });

  test('a server failure returns its message and leaves the habit alone', () async {
    backend.on('POST', Endpoints.habitComplete(1),
        status: 400, body: {'error': 'Already completed today'});
    final c = container();
    await c.read(habitsProvider.future);

    final outcome = await c.read(habitsProvider.notifier).complete(1);

    expect((outcome as CompleteFailed).message, 'Already completed today');
    expect(c.read(habitsProvider).value!.first.completedToday, isFalse);
  });

  test('a double tap only sends one complete request', () async {
    backend.on('POST', Endpoints.habitComplete(1), body: {
      'habit_id': 1,
      'completed_today': true,
      'skips_remaining': 3,
    });
    final c = container();
    await c.read(habitsProvider.future);

    await Future.wait([
      c.read(habitsProvider.notifier).complete(1),
      c.read(habitsProvider.notifier).complete(1),
    ]);

    expect(backend.requests.where((r) => r.path == '/habits/1/complete').length, 1);
    expect(c.read(busySetProvider), isEmpty);
  });

  test('deleting removes the habit and reports no error', () async {
    backend.on('DELETE', Endpoints.habit(1), body: {'deleted': true});
    final c = container();
    await c.read(habitsProvider.future);

    expect(await c.read(habitsProvider.notifier).delete(1), isNull);
    expect(c.read(habitsProvider).value!.map((h) => h.id), [2]);
  });

  test('a failed delete keeps the habit and returns the message', () async {
    backend.on('DELETE', Endpoints.habit(1), status: 500, body: {'error': 'boom'});
    final c = container();
    await c.read(habitsProvider.future);

    expect(await c.read(habitsProvider.notifier).delete(1), isNotNull);
    expect(c.read(habitsProvider).value!.length, 2);
  });

  test('a freshly created habit goes to the top of the list', () async {
    final c = container();
    await c.read(habitsProvider.future);

    c.read(habitsProvider.notifier).prepend(Habit.fromJson(_row(id: 99)));

    expect(c.read(habitsProvider).value!.first.id, 99);
  });
}
