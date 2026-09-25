import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/core/theme/spacing.dart';
import 'package:readx/widgets/app_header.dart';

import '../helpers/harness.dart';

void main() {
  group('AppHeader', () {
    testWidgets('is the 56 pt bar with a hairline under it', (tester) async {
      await pumpWidgetUnderTest(tester, const AppHeader(title: 'Настройки'));

      expect(tester.getSize(find.byType(AppHeader)).height, AppMetrics.headerHeight);

      final decoration =
          tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
      expect(decoration.color, AppColors.bg);
      expect((decoration.border! as Border).bottom.color, AppColors.border);
    });

    testWidgets('a long title is ellipsised rather than overflowing', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AppHeader(title: 'Очень длинный заголовок который точно не влезет в одну строку'),
        surface: const Size(320, 568),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('missing slots become spacers so the middle stays centred', (tester) async {
      await pumpWidgetUnderTest(tester, const AppHeader(middle: Text('ReadX')));

      final spacers = tester
          .widgetList<SizedBox>(find.descendant(of: find.byType(Row), matching: find.byType(SizedBox)))
          .where((box) => box.width == 42);
      expect(spacers.length, 2);
    });

    testWidgets('leading and trailing widgets are rendered', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        AppHeader(
          leading: HeaderIconButton(icon: LucideIcons.arrowLeft, onTap: () {}),
          title: 'Профиль',
          trailing: HeaderIconButton(icon: LucideIcons.ellipsis, onTap: () {}),
        ),
      );

      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('the status bar inset is added on top of the bar', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(top: 47)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [AppHeader(title: 'Feed')],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AppHeader)).height, AppMetrics.headerHeight + 47);
    });
  });

  group('HeaderIconButton', () {
    testWidgets('reports its tap', (tester) async {
      var taps = 0;
      await pumpWidgetUnderTest(
        tester,
        HeaderIconButton(icon: LucideIcons.bell, onTap: () => taps++),
      );

      await tester.tap(find.byType(HeaderIconButton));
      expect(taps, 1);
    });

    testWidgets('carries a semantic label for VoiceOver', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        HeaderIconButton(
          icon: LucideIcons.bell,
          semanticLabel: 'Уведомления',
          onTap: () {},
        ),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).semanticLabel, 'Уведомления');
    });
  });
}
