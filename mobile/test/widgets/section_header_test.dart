import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/section_header.dart';

import '../helpers/harness.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('shows the label next to a tinted icon chip', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SectionHeader(icon: LucideIcons.user, label: 'ACCOUNT'),
      );

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.byIcon(LucideIcons.user), findsOneWidget);
    });

    testWidgets('the chip is tinted from the colour it was given', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SectionHeader(
          icon: LucideIcons.triangleAlert,
          label: 'DANGER ZONE',
          color: AppColors.danger,
        ),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).color, AppColors.danger);

      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
      expect(decoration.color!.a, closeTo(0.14, 0.01));
    });

    testWidgets('a trailing widget sits on the right', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SectionHeader(
          icon: LucideIcons.users,
          label: 'MEMBERS',
          trailing: Text('12'),
        ),
      );

      expect(
        tester.getCenter(find.text('12')).dx,
        greaterThan(tester.getCenter(find.text('MEMBERS')).dx),
      );
    });
  });

  group('SettingsGroup', () {
    testWidgets('puts a hairline between rows but not above the first', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsGroup(
          children: [
            SettingsRow(icon: LucideIcons.shieldCheck, label: 'Privacy', onTap: () {}),
            SettingsRow(icon: LucideIcons.scrollText, label: 'Terms', onTap: () {}),
            SettingsRow(icon: LucideIcons.userX, label: 'Blocked', onTap: () {}),
          ],
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('a single row needs no divider at all', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsGroup(
          children: [
            SettingsRow(icon: LucideIcons.userX, label: 'Blocked', onTap: () {}),
          ],
        ),
      );

      expect(find.byType(Divider), findsNothing);
    });
  });

  group('SettingsRow', () {
    testWidgets('reports its tap', (tester) async {
      var taps = 0;
      await pumpWidgetUnderTest(
        tester,
        SettingsRow(icon: LucideIcons.userX, label: 'Blocked', onTap: () => taps++),
      );

      await tester.tap(find.text('Blocked'));
      expect(taps, 1);
    });

    testWidgets('an optional subtitle explains the row', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsRow(
          icon: LucideIcons.shieldCheck,
          label: 'Privacy Policy',
          subtitle: 'What we collect and how to delete it',
          onTap: () {},
        ),
      );

      expect(find.text('What we collect and how to delete it'), findsOneWidget);
    });

    testWidgets('a destructive row turns its label and chevron red', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsRow(
          icon: LucideIcons.trash2,
          label: 'Delete Account',
          tint: AppColors.danger,
          onTap: () {},
        ),
      );

      expect(tester.widget<Text>(find.text('Delete Account')).style?.color, AppColors.danger);
      expect(
        tester.widget<Icon>(find.byIcon(LucideIcons.chevronRight)).color,
        AppColors.danger,
      );
    });

    testWidgets('an ordinary row keeps a faint chevron', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsRow(icon: LucideIcons.userX, label: 'Blocked', onTap: () {}),
      );

      expect(
        tester.widget<Icon>(find.byIcon(LucideIcons.chevronRight)).color,
        AppColors.textFaint,
      );
    });
  });
}
