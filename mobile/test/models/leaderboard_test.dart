import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/leaderboard.dart';

void main() {
  group('Leaderboard.fromJson', () {
    test('parses both boards and my own standing', () {
      final board = Leaderboard.fromJson({
        'monthly': [
          {'rank': 1, 'id': 2, 'username': 'a', 'points': 120},
          {'rank': 2, 'id': 3, 'username': 'b', 'points': 90},
        ],
        'total': [
          {'rank': 1, 'id': 3, 'username': 'b', 'points': 900},
        ],
        'me': {
          'monthlyPoints': 40,
          'totalPoints': 310,
          'monthlyRank': 7,
          'totalRank': 5,
        },
      });

      expect(board.monthly.length, 2);
      expect(board.total.length, 1);
      expect(board.monthly.first.points, 120);
      expect(board.me.monthlyRank, 7);
      expect(board.me.totalPoints, 310);
    });

    test('an empty month gives empty boards and a zeroed standing', () {
      final board = Leaderboard.fromJson(const {});

      expect(board.monthly, isEmpty);
      expect(board.total, isEmpty);
      expect(board.me.monthlyPoints, 0);
      expect(board.me.totalRank, 0);
    });
  });

  group('LeaderboardEntry.displayName', () {
    test('prefers the full name', () {
      final entry = LeaderboardEntry.fromJson({
        'rank': 1,
        'id': 2,
        'username': 'reader',
        'name': 'Бекзат',
        'surname': 'Ким',
      });

      expect(entry.displayName, 'Бекзат Ким');
    });

    test('falls back to the username when the name is blank', () {
      final entry = LeaderboardEntry.fromJson({
        'rank': 1,
        'id': 2,
        'username': 'reader',
        'name': null,
        'surname': null,
      });

      expect(entry.displayName, 'reader');
    });

    test('a first name alone is not padded with a stray space', () {
      final entry = LeaderboardEntry.fromJson({
        'rank': 1,
        'id': 2,
        'username': 'reader',
        'name': 'Бекзат',
        'surname': '',
      });

      expect(entry.displayName, 'Бекзат');
    });
  });
}
