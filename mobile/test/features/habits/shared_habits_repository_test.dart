import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/habits/shared_habits_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late SharedHabitsRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = SharedHabitsRepository(buildTestClient(backend, token: 'jwt'));
  });

  group('join', () {
    test('returns the id of the personal habit the server created', () async {
      backend.on('POST', Endpoints.sharedHabitJoin(12), body: {'habit_id': 31});

      final result = await repo.join(12);

      expect(backend.lastRequest.path, '/habits/shared/12/join');
      expect(result.habitId, 31);
      expect(result.eligibleLimitReached, isFalse);
    });

    test('flags a join that landed over the points limit', () async {
      backend.on('POST', Endpoints.sharedHabitJoin(12), body: {
        'habit_id': 31,
        'eligible_limit_reached': 1,
      });

      expect((await repo.join(12)).eligibleLimitReached, isTrue);
    });

    test('joining twice surfaces the server message', () async {
      backend.on('POST', Endpoints.sharedHabitJoin(12),
          status: 400, body: {'error': 'Already a member'});

      await expectLater(
        repo.join(12),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Already a member')),
      );
    });
  });

  group('detail', () {
    test('parses the full roster and my own habit id', () async {
      backend.on('GET', Endpoints.sharedHabit(12), body: {
        'id': 12,
        'title': 'Читать вместе',
        'created_by': 3,
        'member_count': 2,
        'current_streak': 5,
        'longest_streak': 9,
        'post_id': 44,
        'am_i_member': 1,
        'my_habit_id': 31,
        'members': [
          {'user_id': 3, 'username': 'creator', 'completed_today': 1},
          {'user_id': 4, 'username': 'joiner', 'completed_today': 0},
        ],
      });

      final detail = await repo.detail(12);

      expect(detail.members.length, 2);
      expect(detail.longestStreak, 9);
      expect(detail.myHabitId, 31);
      expect(detail.amICreator(3), isTrue);
      expect(detail.completedTodayFor(4), isFalse);
    });

    test('a group whose post was deleted still loads', () async {
      backend.on('GET', Endpoints.sharedHabit(12), body: {
        'id': 12,
        'title': 'Читать вместе',
        'post_id': null,
        'members': const [],
      });

      final detail = await repo.detail(12);

      expect(detail.postId, isNull);
      expect(detail.members, isEmpty);
    });

    test('a group that no longer exists raises the server 404 text', () async {
      backend.on('GET', Endpoints.sharedHabit(99),
          status: 404, body: {'error': 'Shared habit not found'});

      await expectLater(
        repo.detail(99),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
      );
    });
  });

  test('leave posts to the leave endpoint', () async {
    backend.on('POST', Endpoints.sharedHabitLeave(12), body: {'left': true});

    await repo.leave(12);

    expect(backend.lastRequest.path, '/habits/shared/12/leave');
    expect(backend.lastRequest.method, 'POST');
  });
}
