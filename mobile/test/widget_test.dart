import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/app.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/loading_spinner.dart';

void main() {
  testWidgets('boots into the dark splash while the session resolves', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReadXApp()));

    expect(find.byType(LoadingSpinner), findsOneWidget);

    final scaffold = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(scaffold.themeMode, ThemeMode.dark);
    expect(scaffold.theme?.scaffoldBackgroundColor, AppColors.bg);
  });
}
