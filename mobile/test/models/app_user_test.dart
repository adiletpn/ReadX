import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/app_user.dart';

void main() {
  group('AppUser.fromJson', () {
    test('reads a full GET /auth/me response', () {
      final user = AppUser.fromJson({
        'id': 7,
        'username': 'aigerim',
        'email': 'aigerim@example.kz',
        'name': 'Айгерім',
        'surname': 'Нұрлан',
        'bio': 'Оқимын',
        'avatar_url': '/uploads/1771563007880.png',
        'instagram': 'aigerim',
        'telegram': 'aigerim',
        'book_name': 'Абай жолы',
        'book_author': 'М. Әуезов',
        'show_book': 1,
        'book_current_page': 120,
        'book_total_pages': 400,
        'is_admin': 0,
        'totalPoints': 530,
        'total_points': 530,
        'monthlyPoints': 128,
        'monthlyRank': 3,
        'postCount': 12,
        'habitCount': 4,
        'currentStreak': 7,
        'skipsRemaining': 2,
        'followersCount': 9,
        'followingCount': 11,
        'badges': [
          {'id': 1, 'name': 'Fire Starter', 'text_color': '#FF9500', 'bg_color': '#FF9500'},
        ],
      });

      expect(user.id, 7);
      expect(user.showBook, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.totalPoints, 530);
      expect(user.badges.single.name, 'Fire Starter');
      expect(user.displayName, 'Айгерім Нұрлан');
    });

    test('survives the SQLite quirks: 0/1 booleans, doubles, nulls', () {
      final user = AppUser.fromJson({
        'id': 2,
        'username': 'reader',
        'name': null,
        'surname': null,
        'bio': null,
        'avatar_url': null,
        'show_book': 0,
        'is_admin': 1,
        'totalPoints': 50.0,
        'monthlyPoints': 0.0,
      });

      expect(user.name, '');
      expect(user.avatarUrl, isNull);
      expect(user.isAdmin, isTrue);
      expect(user.showBook, isFalse);
      expect(user.totalPoints, 50);
      // Falls back to the username the way the web's `name || username` does.
      expect(user.displayName, 'reader');
    });

    test('falls back to total_points when the camelCase twin is absent', () {
      final user = AppUser.fromJson({'id': 3, 'username': 'x', 'total_points': 410});
      expect(user.totalPoints, 410);
    });

    test('drops a malformed badge instead of failing the whole user', () {
      final user = AppUser.fromJson({
        'id': 4,
        'username': 'x',
        'badges': [
          'not-an-object',
          {'id': 5, 'name': 'Top', 'text_color': '#FFFFFF', 'bg_color': '#0077FF'},
        ],
      });
      expect(user.badges, hasLength(1));
      expect(user.badges.single.id, 5);
    });
  });
}
