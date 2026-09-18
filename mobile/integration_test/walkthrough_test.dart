import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets('walk every tab and capture it', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReadXApp()));
    await settle(tester);

    await binding.takeScreenshot('01-login');

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'demo@readx.kz');
    await tester.enterText(fields.at(1), 'secret123');
    await settle(tester);
    await tester.tap(find.text('Log In'));
    await settle(tester);
    await settle(tester);

    await binding.takeScreenshot('02-feed');

    await tester.tap(find.byIcon(LucideIcons.target));
    await settle(tester);
    await binding.takeScreenshot('03-habits');

    await tester.tap(find.byIcon(LucideIcons.trophy));
    await settle(tester);
    await binding.takeScreenshot('04-points');

    await tester.tap(find.byIcon(LucideIcons.user));
    await settle(tester);
    await binding.takeScreenshot('05-profile');
  });
}
