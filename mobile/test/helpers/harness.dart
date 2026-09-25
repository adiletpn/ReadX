import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/app_theme.dart';

Future<void> pumpWidgetUnderTest(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size surface = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.build(),
        themeMode: ThemeMode.dark,
        home: Scaffold(body: child),
      ),
    ),
  );
}

Finder findTextContaining(String fragment) => find.byWidgetPredicate(
      (widget) => widget is Text && (widget.data ?? '').contains(fragment),
    );
