import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/utils/media_url.dart';

void main() {
  group('mediaUrl', () {
    test('never produces a double slash', () {
      expect(mediaUrl('/uploads/a.png'), 'https://readx.kz/uploads/a.png');
      expect(mediaUrl('uploads/a.png'), 'https://readx.kz/uploads/a.png');
    });

    test('leaves an absolute url alone whichever scheme it uses', () {
      expect(mediaUrl('http://cdn.example.com/a.png'), 'http://cdn.example.com/a.png');
      expect(mediaUrl('https://cdn.example.com/a.png'), 'https://cdn.example.com/a.png');
    });

    test('trims the path before building the url', () {
      expect(mediaUrl('  /uploads/a.png  '), 'https://readx.kz/uploads/a.png');
    });

    test('an absent avatar stays absent so the initials are drawn', () {
      expect(mediaUrl(null), isNull);
      expect(mediaUrl(''), isNull);
      expect(mediaUrl('   '), isNull);
    });

    test('a query string survives the prefixing', () {
      expect(mediaUrl('/uploads/a.png?v=2'), 'https://readx.kz/uploads/a.png?v=2');
    });
  });
}
