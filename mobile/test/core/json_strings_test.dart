import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/utils/json.dart';

void main() {
  group('asString', () {
    test('collapses null to the fallback', () {
      expect(asString(null), '');
      expect(asString(null, fallback: '#FFFFFF'), '#FFFFFF');
    });

    test('stringifies the scalars SQLite can return', () {
      expect(asString('bio'), 'bio');
      expect(asString(42), '42');
      expect(asString(true), 'true');
    });

    test('keeps an empty string rather than reaching for the fallback', () {
      expect(asString('', fallback: 'x'), '');
    });
  });

  group('asStringOrNull', () {
    test('keeps absence and emptiness apart for avatars', () {
      expect(asStringOrNull(null), isNull);
      expect(asStringOrNull(''), isNull);
      expect(asStringOrNull('/uploads/a.png'), '/uploads/a.png');
    });
  });

  group('asIntOrNull', () {
    test('keeps null distinct from zero for optional ids', () {
      expect(asIntOrNull(null), isNull);
      expect(asIntOrNull(0), 0);
      expect(asIntOrNull('12'), 12);
      expect(asIntOrNull(12.0), 12);
    });
  });

  group('asMap', () {
    test('narrows a decoded object', () {
      expect(asMap({'id': 1}), {'id': 1});
      expect(asMap(<Object?, Object?>{'id': 1}), {'id': 1});
    });

    test('an error page or an empty body reads as an empty object', () {
      expect(asMap(null), isEmpty);
      expect(asMap('<html>502</html>'), isEmpty);
      expect(asMap(<Object?>[]), isEmpty);
    });
  });
}
