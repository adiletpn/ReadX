import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/connectivity.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/offline_banner.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('stays out of the way while requests are succeeding', (tester) async {
    await pumpWidgetUnderTest(tester, const OfflineBanner());

    expect(find.text('Нет подключения'), findsNothing);
    expect(tester.getSize(find.byType(OfflineBanner)).height, 0);
  });

  testWidgets('appears once a request reports the server unreachable', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const OfflineBanner(),
      overrides: [networkStatusProvider.overrideWith(NetworkStatus.new)],
    );

    final element = tester.element(find.byType(OfflineBanner));
    ProviderScope.containerOf(element).read(networkStatusProvider.notifier).reportUnreachable();
    await tester.pump();

    expect(find.text('Нет подключения'), findsOneWidget);
  });

  testWidgets('the banner is the danger red, full width', (tester) async {
    await pumpWidgetUnderTest(tester, const OfflineBanner());

    final element = tester.element(find.byType(OfflineBanner));
    ProviderScope.containerOf(element).read(networkStatusProvider.notifier).reportUnreachable();
    await tester.pump();

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, AppColors.danger);
    expect(tester.getSize(find.byType(Container)).width, 390);
  });

  testWidgets('it disappears again as soon as a request succeeds', (tester) async {
    await pumpWidgetUnderTest(tester, const OfflineBanner());

    final status = ProviderScope.containerOf(tester.element(find.byType(OfflineBanner)))
        .read(networkStatusProvider.notifier);

    status.reportUnreachable();
    await tester.pump();
    expect(find.text('Нет подключения'), findsOneWidget);

    status.reportReachable();
    await tester.pump();
    expect(find.text('Нет подключения'), findsNothing);
  });
}
