import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/habits/habits_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late HabitsRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = HabitsRepository(buildTestClient(backend, token: 'jwt'));
  });

  group('list', () {
    test('parses the habits, shared ones included', () async {
      backend.on('GET', Endpoints.habits, body: [
        {'id': 1, 'title': 'Читать', 'streak': 4, 'completed_today': 1},
        {
          'id': 2,
          'title': 'Читать вместе',
          'shared_habit_id': 12,
          'shared_habit': {'id': 12, 'title': 'Читать вместе', 'member_count': 3},
        },
      ]);

      final habits = await repo.list();

      expect(habits.length, 2);
      expect(habits.first.completedToday, isTrue);
      expect(habits.last.isShared, isTrue);
      expect(habits.last.sharedHabit!.memberCount, 3);
    });

    test('no habits yet is an empty list', () async {
      backend.on('GET', Endpoints.habits, body: const []);

      expect(await repo.list(), isEmpty);
    });
  });

  group('create', () {
    test('sends the title and the points flag as a real boolean', () async {
      backend.on('POST', Endpoints.habits, body: {'id': 3, 'title': 'Читать'});

      await repo.create(title: 'Читать', isPointEligible: true);

      expect(backend.lastRequest.body, {'title': 'Читать', 'is_point_eligible': true});
    });

    test('reports when the account is already at its five-habit limit', () async {
      backend.on('POST', Endpoints.habits, body: {
        'id': 6,
        'title': 'Шестая',
        'is_point_eligible': 0,
        'eligible_limit_reached': 1,
      });

      final result = await repo.create(title: 'Шестая', isPointEligible: true);

      expect(result.eligibleLimitReached, isTrue);
      expect(result.habit.isPointEligible, isFalse);
    });
  });

  group('createShared', () {
    test('posts to the shared endpoint and returns all three ids', () async {
      backend.on('POST', Endpoints.sharedHabits, body: {
        'post_id': 44,
        'shared_habit_id': 12,
        'habit_id': 7,
      });

      final result = await repo.createShared(title: 'Читать вместе', isPointEligible: true);

      expect(backend.lastRequest.path, '/habits/shared');
      expect(result.postId, 44);
      expect(result.sharedHabitId, 12);
      expect(result.habitId, 7);
    });

    test('an optional caption is included only when filled in', () async {
      backend.on('POST', Endpoints.sharedHabits, body: {'post_id': 1});

      await repo.createShared(title: 'Читать', isPointEligible: false, caption: 'го');
      expect(backend.lastRequest.body, {
        'title': 'Читать',
        'is_point_eligible': false,
        'caption': 'го',
      });

      await repo.createShared(title: 'Читать', isPointEligible: false, caption: '');
      expect(backend.lastRequest.body, {'title': 'Читать', 'is_point_eligible': false});
    });
  });

  group('complete', () {
    test('returns the points and streak the server recalculated', () async {
      backend.on('POST', Endpoints.habitComplete(4), body: {
        'habit_id': 4,
        'completed_today': true,
        'monthly_streak': 6,
        'monthly_points': 42,
        'points_awarded': 2,
        'skips_remaining': 3,
      });

      final result = await repo.complete(4);

      expect(result.completedToday, isTrue);
      expect(result.pointsAwarded, 2);
      expect(result.monthlyPoints, 42);
    });

    test('a habit the server deleted comes back flagged', () async {
      backend.on('POST', Endpoints.habitComplete(4), body: {'deleted': true});

      expect((await repo.complete(4)).deleted, isTrue);
    });
  });

  test('delete hits the habit path', () async {
    backend.on('DELETE', Endpoints.habit(9), body: {'deleted': true});

    await repo.delete(9);

    expect(backend.lastRequest.path, '/habits/9');
    expect(backend.lastRequest.method, 'DELETE');
  });
}
