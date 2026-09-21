import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/connectivity.dart';

void main() {
  late ProviderContainer container;
  late NetworkStatus status;

  setUp(() {
    container = ProviderContainer();
    status = container.read(networkStatusProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('NetworkStatus', () {
    test('starts reachable so the banner never flashes on a cold start', () {
      expect(container.read(networkStatusProvider), isTrue);
      expect(container.read(isOfflineProvider), isFalse);
    });

    test('a failed request marks the app offline', () {
      status.reportUnreachable();

      expect(container.read(isOfflineProvider), isTrue);
    });

    test('a successful request brings the banner back down', () {
      status.reportUnreachable();
      status.reportReachable();

      expect(container.read(isOfflineProvider), isFalse);
    });

    test('repeated reports of the same state do not notify watchers', () {
      var notifications = 0;
      container.listen(networkStatusProvider, (_, _) => notifications++);

      status.reportReachable();
      status.reportReachable();
      expect(notifications, 0);

      status.reportUnreachable();
      status.reportUnreachable();
      expect(notifications, 1);
    });
  });
}
