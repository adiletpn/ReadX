import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/confirm_sheet.dart';

Future<bool?> _open(
  WidgetTester tester, {
  String confirmLabel = 'Delete',
  Color confirmColor = AppColors.danger,
}) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showConfirmSheet(
                  context,
                  title: 'Удалить привычку?',
                  message: 'Это действие нельзя отменить.',
                  confirmLabel: confirmLabel,
                  confirmColor: confirmColor,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('shows the title, the message and both buttons', (tester) async {
    await _open(tester);

    expect(find.text('Удалить привычку?'), findsOneWidget);
    expect(find.text('Это действие нельзя отменить.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('the action button resolves to true', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить привычку?'), findsNothing);
  });

  testWidgets('cancel resolves to false', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить привычку?'), findsNothing);
  });

  testWidgets('tapping the scrim dismisses it', (tester) async {
    await _open(tester);

    await tester.tapAt(const Offset(200, 60));
    await tester.pumpAndSettle();

    expect(find.text('Удалить привычку?'), findsNothing);
  });

  testWidgets('the action colour is the destructive red by default', (tester) async {
    await _open(tester);

    final container = tester.widget<Container>(
      find.ancestor(of: find.text('Delete'), matching: find.byType(Container)).first,
    );
    expect((container.decoration! as BoxDecoration).color, AppColors.danger);
  });

  testWidgets('a non-destructive action can be tinted blue', (tester) async {
    await _open(tester, confirmLabel: 'Join', confirmColor: AppColors.primary);

    final container = tester.widget<Container>(
      find.ancestor(of: find.text('Join'), matching: find.byType(Container)).first,
    );
    expect((container.decoration! as BoxDecoration).color, AppColors.primary);
  });
}
