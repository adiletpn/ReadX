import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/app_toast.dart';

const _shown = Duration(milliseconds: 100);

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          captured = context;
          return const Scaffold(body: SizedBox.expand());
        },
      ),
    ),
  );
  return captured;
}

Future<void> _settleIn(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _drain(WidgetTester tester) async {
  AppToast.dismiss();
  await tester.pump();
  await tester.pump(_shown + const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

Color _lastFill(WidgetTester tester) =>
    (tester.widget<Container>(find.byType(Container).last).decoration! as BoxDecoration).color!;

void main() {
  testWidgets('shows the message over the page', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, '🎉 Привычка создана', duration: _shown);
    await _settleIn(tester);

    expect(find.text('🎉 Привычка создана'), findsOneWidget);

    await _drain(tester);
  });

  testWidgets('an error toast is red, a normal one is blue', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, 'Готово', duration: _shown);
    await _settleIn(tester);
    expect(_lastFill(tester), AppColors.primary);

    AppToast.show(context, 'Не удалось', isError: true, duration: _shown);
    await _settleIn(tester);
    expect(_lastFill(tester), AppColors.danger);

    await _drain(tester);
  });

  testWidgets('only one toast is on screen at a time', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, 'Первый', duration: _shown);
    await tester.pump();
    AppToast.show(context, 'Второй', duration: _shown);
    await _settleIn(tester);

    expect(find.text('Первый'), findsNothing);
    expect(find.text('Второй'), findsOneWidget);

    await _drain(tester);
  });

  testWidgets('it removes itself once the duration is up', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, 'Готово', duration: _shown);
    await _settleIn(tester);
    expect(find.text('Готово'), findsOneWidget);

    await tester.pump(_shown);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('Готово'), findsNothing);

    await _drain(tester);
  });

  testWidgets('an empty message shows nothing', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, '', duration: _shown);
    await tester.pump();

    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('dismiss removes it before the duration is up', (tester) async {
    final context = await _pumpHost(tester);

    AppToast.show(context, 'Готово', duration: _shown);
    await _settleIn(tester);

    AppToast.dismiss();
    await tester.pump();

    expect(find.text('Готово'), findsNothing);

    await _drain(tester);
  });
}
