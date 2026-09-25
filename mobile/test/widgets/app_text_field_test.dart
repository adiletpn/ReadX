import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/app_text_field.dart';

import '../helpers/harness.dart';

Border _border(WidgetTester tester) =>
    (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration)
        .border! as Border;

void main() {
  testWidgets('shows the hint until something is typed', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpWidgetUnderTest(
      tester,
      AppTextField(controller: controller, hintText: 'Email'),
    );

    expect(find.text('Email'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'reader@readx.kz');
    expect(controller.text, 'reader@readx.kz');
  });

  testWidgets('the hairline turns blue on focus', (tester) async {
    await pumpWidgetUnderTest(tester, const AppTextField(hintText: 'Email'));

    expect(_border(tester).top.color, AppColors.border);

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(_border(tester).top.color, AppColors.primary);
  });

  testWidgets('an invalid field is outlined in red even unfocused', (tester) async {
    await pumpWidgetUnderTest(tester, const AppTextField(hasError: true));

    expect(_border(tester).top.color, AppColors.danger);
    expect(_border(tester).top.width, 1.5);
  });

  testWidgets('the reveal toggle flips the password back and forth', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const AppTextField(obscureText: true, revealToggle: true),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    expect(find.byIcon(LucideIcons.eye), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.eye));
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
  });

  testWidgets('the built-in counter is hidden so screens can draw their own', (tester) async {
    await pumpWidgetUnderTest(tester, const AppTextField(maxLength: 280));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, 280);
    expect(field.decoration?.counterText, '');
  });

  testWidgets('onChanged and onSubmitted both fire', (tester) async {
    String? changed;
    String? submitted;

    await pumpWidgetUnderTest(
      tester,
      AppTextField(onChanged: (v) => changed = v, onSubmitted: (v) => submitted = v),
    );

    await tester.enterText(find.byType(TextField), 'привычка');
    expect(changed, 'привычка');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'привычка');
  });

  testWidgets('a caller-owned focus node is not disposed by the field', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await pumpWidgetUnderTest(tester, AppTextField(focusNode: node));
    await pumpWidgetUnderTest(tester, const SizedBox.shrink());

    expect(node.hasListeners, isFalse);
  });
}
