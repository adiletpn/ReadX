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
      expect((decoration.border! as Border).bottom.color, AppColors.border);
    });

    testWidgets('has no fill, so the ambient gradient runs unbroken behind it', (tester) async {
      await pumpWidgetUnderTest(tester, const AppHeader(title: 'Настройки'));

      final decoration =
          tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.gradient, isNull);
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

    testWidgets('the middle sits on the bar centre line whatever flanks it', (tester) async {
      Future<double> middleCentre(AppHeader header) async {
        await pumpWidgetUnderTest(tester, header);
        return tester.getCenter(find.text('ReadX')).dx;
      }

      // The three shapes the tabs actually use: bare, one trailing button, and
      // a leading button with two trailing ones.
      final bare = await middleCentre(const AppHeader(middle: Text('ReadX')));
      final oneTrailing = await middleCentre(
        AppHeader(
          middle: const Text('ReadX'),
          trailing: HeaderIconButton(icon: LucideIcons.ellipsis, onTap: () {}),
        ),
      );
      final crowded = await middleCentre(
        AppHeader(
          middle: const Text('ReadX'),
          leading: HeaderIconButton(icon: LucideIcons.menu, onTap: () {}),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeaderIconButton(icon: LucideIcons.bell, onTap: () {}),
              HeaderIconButton(icon: LucideIcons.search, onTap: () {}),
            ],
          ),
        ),
      );

      expect(bare, closeTo(195, 0.5));
      expect(oneTrailing, closeTo(bare, 0.5));
      expect(crowded, closeTo(bare, 0.5));
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
