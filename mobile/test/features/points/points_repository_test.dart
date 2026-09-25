import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/points/points_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  ProviderContainer container({bool retry = true}) {
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(buildTestClient(backend, token: 'jwt'))],
      retry: retry ? null : (_, _) => null,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => backend = FakeBackend());

  test('parses both boards and my own standing', () async {
    backend.on('GET', Endpoints.leaderboard, body: {
      'monthly': [
        {'rank': 1, 'id': 2, 'username': 'a', 'name': 'Бекзат', 'surname': 'Ким', 'points': 120},
      ],
      'total': [
        {'rank': 1, 'id': 3, 'username': 'b', 'points': 900},
      ],
      'me': {'monthlyPoints': 40, 'totalPoints': 310, 'monthlyRank': 7, 'totalRank': 5},
    });

    final board = await container().read(leaderboardProvider.future);

    expect(board.monthly.single.displayName, 'Бекзат Ким');
    expect(board.total.single.points, 900);
    expect(board.me.monthlyRank, 7);
  });

  test('a fresh month with nobody scoring yet still loads', () async {
    backend.on('GET', Endpoints.leaderboard, body: {
      'monthly': const [],
      'total': const [],
      'me': {'monthlyPoints': 0, 'totalPoints': 0, 'monthlyRank': 0, 'totalRank': 0},
    });

    final board = await container().read(leaderboardProvider.future);

    expect(board.monthly, isEmpty);
    expect(board.me.monthlyPoints, 0);
  });

  test('a malformed row is dropped rather than failing the whole board', () async {
    backend.on('GET', Endpoints.leaderboard, body: {
      'monthly': [
        {'rank': 1, 'id': 2, 'username': 'a', 'points': 120},
        'garbage',
      ],
      'total': const [],
      'me': const <String, Object?>{},
    });

    final board = await container().read(leaderboardProvider.future);

    expect(board.monthly.length, 1);
  });

  test('a server failure reaches the screen as an ApiException', () async {
    backend.on('GET', Endpoints.leaderboard, status: 500, body: {'error': 'boom'});

    await expectLater(
      container(retry: false).read(leaderboardProvider.future),
      throwsA(isA<ApiException>().having(
        (e) => e.message,
        'message',
        'Сервер недоступен. Попробуйте позже',
      )),
    );
  });

  test('it reads the leaderboard endpoint, not the points one', () async {
    backend.on('GET', Endpoints.leaderboard, body: {
      'monthly': const [],
      'total': const [],
      'me': const <String, Object?>{},
    });

    await container().read(leaderboardProvider.future);

    expect(backend.lastRequest.path, Endpoints.leaderboard);
    expect(backend.lastRequest.method, 'GET');
  });
}
