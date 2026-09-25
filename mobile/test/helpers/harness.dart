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
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.build(),
        themeMode: ThemeMode.dark,
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: inner!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
}

Finder findTextContaining(String fragment) => find.byWidgetPredicate(
      (widget) => widget is Text && (widget.data ?? '').contains(fragment),
    );
