import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/busy_set.dart';

void main() {
  late ProviderContainer container;
  late BusySet busy;

  setUp(() {
    container = ProviderContainer();
    busy = container.read(busySetProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('BusySet', () {
    test('the first start wins and the second is refused', () {
      expect(busy.start('like:4'), isTrue);
      expect(busy.start('like:4'), isFalse);
      expect(busy.contains('like:4'), isTrue);
    });

    test('a key can be started again once it finished', () {
      busy.start('follow:2');
      busy.finish('follow:2');

      expect(busy.contains('follow:2'), isFalse);
      expect(busy.start('follow:2'), isTrue);
    });

    test('different keys do not block each other', () {
      expect(busy.start('like:1'), isTrue);
      expect(busy.start('like:2'), isTrue);

      busy.finish('like:1');

      expect(busy.contains('like:1'), isFalse);
      expect(busy.contains('like:2'), isTrue);
    });

    test('finishing a key that never started changes nothing', () {
      busy.finish('complete:9');

      expect(container.read(busySetProvider), isEmpty);
    });

    test('watchers see a new set on every change', () {
      final seen = <Set<Object>>[];
      container.listen(busySetProvider, (_, next) => seen.add(next), fireImmediately: false);

      busy.start('join:3');
      busy.finish('join:3');

      expect(seen.length, 2);
      expect(seen.first, {'join:3'});
      expect(seen.last, isEmpty);
    });
  });
}
