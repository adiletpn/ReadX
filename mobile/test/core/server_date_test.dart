import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/utils/json.dart';
import 'package:readx/core/utils/time_ago.dart';

void main() {
  group('parseServerDate', () {
    test('a SQLite timestamp is read as UTC, not as local time', () {
      final parsed = parseServerDate('2026-09-20 09:00:00');

      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 9, 20, 9));
    });

    test('an already-zoned timestamp is not shifted twice', () {
      expect(parseServerDate('2026-09-20T09:00:00Z')!.toUtc(), DateTime.utc(2026, 9, 20, 9));
      expect(parseServerDate('2026-09-20T14:00:00+05:00')!.toUtc(), DateTime.utc(2026, 9, 20, 9));
    });

    test('junk and non-strings give null instead of throwing', () {
      expect(parseServerDate(null), isNull);
      expect(parseServerDate(''), isNull);
      expect(parseServerDate('   '), isNull);
      expect(parseServerDate('nonsense'), isNull);
      expect(parseServerDate(1771563007880), isNull);
    });

    test('surrounding whitespace is tolerated', () {
      expect(parseServerDate('  2026-09-20 09:00:00 ')!.toUtc(), DateTime.utc(2026, 9, 20, 9));
    });
  });

  group('timeAgo', () {
    String stamp(Duration ago) => DateTime.now()
        .toUtc()
        .subtract(ago)
        .toIso8601String()
        .split('.')
        .first
        .replaceFirst('T', ' ');

    test('switches bucket exactly on the minute, hour and day', () {
      expect(timeAgo(stamp(const Duration(seconds: 59))), 'just now');
      expect(timeAgo(stamp(const Duration(seconds: 61))), '1m ago');
      expect(timeAgo(stamp(const Duration(minutes: 61))), '1h ago');
      expect(timeAgo(stamp(const Duration(hours: 25))), '1d ago');
    });

    test('an unparsable timestamp renders as nothing, not as an error', () {
      expect(timeAgo(null), '');
      expect(timeAgo('nonsense'), '');
    });
  });
}
