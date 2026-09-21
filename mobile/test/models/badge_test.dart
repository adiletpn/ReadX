import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/badge.dart';

void main() {
  group('Badge.fromJson', () {
    test('reads the colours the admin panel stored', () {
      final badge = Badge.fromJson({
        'id': 2,
        'name': 'Top reader',
        'text_color': '#FFD60A',
        'bg_color': '#FF9F0A',
      });

      expect(badge.id, 2);
      expect(badge.name, 'Top reader');
      expect(badge.textColor, '#FFD60A');
      expect(badge.bgColor, '#FF9F0A');
    });

    test('falls back to white on accent when the colours are missing', () {
      final badge = Badge.fromJson({'id': 1, 'name': 'Beta'});

      expect(badge.textColor, '#FFFFFF');
      expect(badge.bgColor, '#0077FF');
    });

    test('a null colour also falls back instead of crashing the chip', () {
      final badge = Badge.fromJson({
        'id': 1,
        'name': 'Beta',
        'text_color': null,
        'bg_color': null,
      });

      expect(badge.textColor, '#FFFFFF');
      expect(badge.bgColor, '#0077FF');
    });
  });
}
