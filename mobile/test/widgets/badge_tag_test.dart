import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/models/badge.dart' as models;
import 'package:readx/widgets/badge_tag.dart';

import '../helpers/harness.dart';

models.Badge _badge(String name, {String bg = '#FF9F0A'}) =>
    models.Badge.fromJson({'id': 1, 'name': name, 'bg_color': bg});

Future<IconData> _iconOf(WidgetTester tester, String name) async {
  await pumpWidgetUnderTest(tester, BadgeTag(badge: _badge(name)));
  return tester.widget<Icon>(find.byType(Icon)).icon!;
}

void main() {
  testWidgets('shows the badge name', (tester) async {
    await pumpWidgetUnderTest(tester, BadgeTag(badge: _badge('Top reader')));

    expect(find.text('Top reader'), findsOneWidget);
  });

  testWidgets('picks the icon from the same keywords the web does', (tester) async {
    expect(await _iconOf(tester, 'Streak master'), LucideIcons.flame);
    expect(await _iconOf(tester, 'Top reader'), LucideIcons.star);
    expect(await _iconOf(tester, 'Pro'), LucideIcons.zap);
    expect(await _iconOf(tester, 'Moderator'), LucideIcons.shield);
    expect(await _iconOf(tester, 'Founder'), LucideIcons.crown);
    expect(await _iconOf(tester, 'VIP'), LucideIcons.gem);
  });

  testWidgets('an unknown name gets the sparkles fallback', (tester) async {
    expect(await _iconOf(tester, 'Книголюб'), LucideIcons.sparkles);
  });

  testWidgets('tints fill at 10 percent and border at 30 percent', (tester) async {
    await pumpWidgetUnderTest(tester, BadgeTag(badge: _badge('Top', bg: '#FF9F0A')));

    final decoration =
        tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
    expect(decoration.color!.a, closeTo(0.1, 0.01));
    expect((decoration.border! as Border).top.color.a, closeTo(0.3, 0.01));
  });

  testWidgets('a malformed colour falls back to the accent instead of throwing', (tester) async {
    await pumpWidgetUnderTest(tester, BadgeTag(badge: _badge('Top', bg: 'not-a-colour')));

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, const Color(0xFF0077FF));
  });

  testWidgets('the small variant shrinks the type', (tester) async {
    await pumpWidgetUnderTest(tester, BadgeTag(badge: _badge('Top'), small: true));

    expect(tester.widget<Text>(find.text('Top')).style?.fontSize, 9);
  });
}
