import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/loading_spinner.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('the spinner is the web ring: 24 pt across and 2 pt thick', (tester) async {
    await pumpWidgetUnderTest(tester, const LoadingSpinner());

    final box = tester.widget<SizedBox>(
      find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(SizedBox)).first,
    );
    expect(box.width, 24);
    expect(box.height, 24);

    final ring = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(ring.strokeWidth, 2);
    expect(ring.color, AppColors.primary);
  });

  testWidgets('size and colour can be overridden for a button', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const LoadingSpinner(size: 16, color: AppColors.textPrimary),
    );

    final ring = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(ring.color, AppColors.textPrimary);
  });

  testWidgets('LoadingState centres one spinner', (tester) async {
    await pumpWidgetUnderTest(tester, const LoadingState());

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
  });
}
