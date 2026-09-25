import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/widgets/user_avatar.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('falls back to the first letter when there is no avatar', (tester) async {
    await pumpWidgetUnderTest(tester, const UserAvatar(avatarUrl: null, name: 'Бекзат'));

    expect(find.text('Б'), findsOneWidget);
  });

  testWidgets('an empty avatar path also draws the initial', (tester) async {
    await pumpWidgetUnderTest(tester, const UserAvatar(avatarUrl: '', name: 'reader'));

    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('a nameless account shows a question mark, never a crash', (tester) async {
    await pumpWidgetUnderTest(tester, const UserAvatar(avatarUrl: null, name: '   '));

    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('the circle honours the requested size', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const UserAvatar(avatarUrl: null, name: 'Reader', size: 64),
    );

    final box = tester.getSize(find.byType(ClipOval));
    expect(box.width, 64);
    expect(box.height, 64);
  });

  testWidgets('the initial scales with the circle', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const UserAvatar(avatarUrl: null, name: 'Reader', size: 80),
    );

    final text = tester.widget<Text>(find.text('R'));
    expect(text.style?.fontSize, 32);
  });
}
