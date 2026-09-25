import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/primary_button.dart';

import '../helpers/harness.dart';

BoxDecoration _decoration(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;

void main() {
  testWidgets('an active button paints the brand gradient', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      PrimaryButton(label: 'Войти', onPressed: () {}),
    );

    final gradient = _decoration(tester).gradient! as LinearGradient;
    expect(gradient.colors, AppColors.brandGradient);
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('a disabled button goes flat grey and swallows taps', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      PrimaryButton(label: 'Войти', enabled: false, onPressed: () => taps++),
    );

    expect(_decoration(tester).gradient, isNull);
    expect(_decoration(tester).color, AppColors.surfaceHi);

    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 0);
  });

  testWidgets('a loading button shows the ring and cannot be tapped again', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      PrimaryButton(label: 'Войти', loading: true, onPressed: () => taps++),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('an icon replaces nothing but sits before the label', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      PrimaryButton(label: 'Создать', icon: LucideIcons.plus, onPressed: () {}),
    );

    expect(find.byIcon(LucideIcons.plus), findsOneWidget);
    expect(find.text('Создать'), findsOneWidget);
  });

  testWidgets('SecondaryButton is the bordered surface variant', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      SecondaryButton(label: 'Отмена', onPressed: () => taps++),
    );

    final decoration =
        tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
    expect(decoration.color, AppColors.surfaceHi);
    expect((decoration.border! as Border).top.color, AppColors.borderBright);

    await tester.tap(find.byType(SecondaryButton));
    expect(taps, 1);
  });
}
