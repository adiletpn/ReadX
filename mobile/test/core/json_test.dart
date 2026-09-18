import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/utils/json.dart';
import 'package:readx/core/utils/media_url.dart';
import 'package:readx/core/utils/time_ago.dart';

void main() {
  group('asBool', () {
    test('accepts the shapes SQLite and the API produce', () {
      expect(asBool(1), isTrue);
      expect(asBool(0), isFalse);
      expect(asBool(true), isTrue);
      expect(asBool('1'), isTrue);
      expect(asBool('0'), isFalse);
      expect(asBool(null), isFalse);
      expect(asBool(null, fallback: true), isTrue);
    });
  });

  group('asInt', () {
    test('narrows doubles and numeric strings', () {
      expect(asInt(10), 10);
      expect(asInt(10.0), 10);
      expect(asInt('400'), 400);
      expect(asInt(null), 0);
      expect(asInt('nonsense', fallback: 7), 7);
    });
  });

  group('parseServerDate', () {
    test('treats a timestamp with no zone as UTC', () {
      final parsed = parseServerDate('2026-09-17 12:00:00');
      expect(parsed, isNotNull);
      expect(parsed!.toUtc().hour, 12);
      expect(parsed.toUtc().year, 2026);
    });

    test('leaves an explicit zone alone', () {
      expect(parseServerDate('2026-09-17T12:00:00Z')!.toUtc().hour, 12);
    });

    test('returns null for junk', () {
      expect(parseServerDate(''), isNull);
      expect(parseServerDate(null), isNull);
      expect(parseServerDate(42), isNull);
    });
  });

  group('timeAgo', () {
    test('matches the server buckets', () {
      final now = DateTime.now().toUtc();
      String stamp(Duration ago) =>
          now.subtract(ago).toIso8601String().split('.').first.replaceFirst('T', ' ');

      expect(timeAgo(stamp(const Duration(seconds: 5))), 'just now');
      expect(timeAgo(stamp(const Duration(minutes: 5))), '5m ago');
      expect(timeAgo(stamp(const Duration(hours: 3))), '3h ago');
      expect(timeAgo(stamp(const Duration(days: 2))), '2d ago');
    });
  });

  group('mediaUrl', () {
    test('prefixes the relative paths the API returns', () {
      expect(mediaUrl('/uploads/1771563007880.png'),
          'https://readx.kz/uploads/1771563007880.png');
      expect(mediaUrl('uploads/x.png'), 'https://readx.kz/uploads/x.png');
    });

    test('passes absolute urls and nulls through', () {
      expect(mediaUrl('https://cdn.example.com/a.png'), 'https://cdn.example.com/a.png');
      expect(mediaUrl(null), isNull);
      expect(mediaUrl('   '), isNull);
    });
  });

  group('mapList', () {
    test('drops entries that fail to parse', () {
      final result = mapList<int>(
        [
          {'v': 1},
          'not a map',
          {'v': 2},
        ],
        (json) => asInt(json['v']),
      );
      expect(result, [1, 2]);
    });

    test('returns empty for a non-list', () {
      expect(mapList<int>('nope', (_) => 0), isEmpty);
    });
  });
}
