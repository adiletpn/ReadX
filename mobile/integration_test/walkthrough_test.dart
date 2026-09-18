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

  Future<void> settle(WidgetTester tester, [int frames = 12]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.byIcon(LucideIcons.arrowLeft).first);
    await settle(tester);
  }

  testWidgets('walk the app and capture every screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReadXApp()));
    await settle(tester);
    await binding.takeScreenshot('01-login');

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'demo@readx.kz');
    await tester.enterText(fields.at(1), 'secret123');
    await settle(tester, 4);
    await tester.tap(find.text('Log In'));
    await settle(tester, 20);
    await binding.takeScreenshot('02-feed');

    await tester.tap(find.byIcon(LucideIcons.search));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'бек');
    await settle(tester, 15);
    await binding.takeScreenshot('03-search');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.bell));
    await settle(tester, 15);
    await binding.takeScreenshot('04-notifications');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await settle(tester, 20);
    await binding.takeScreenshot('05-post-detail');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.target));
    await settle(tester, 15);
    await binding.takeScreenshot('06-habits');

    await tester.tap(find.text('Create'));
    await settle(tester);
    await binding.takeScreenshot('07-create-habit');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.trophy));
    await settle(tester, 15);
    await binding.takeScreenshot('08-points');

    await tester.tap(find.text('Lottery Rules'));
    await settle(tester);
    await binding.takeScreenshot('09-lottery-rules');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.info));
    await settle(tester);
    await binding.takeScreenshot('10-how-points-work');
    await tapBack(tester);

    await tester.tap(find.byIcon(LucideIcons.user));
    await settle(tester, 15);
    await binding.takeScreenshot('11-profile');

    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await settle(tester);
    await tester.tap(find.text('Settings'));
    await settle(tester, 15);
    await binding.takeScreenshot('12-settings');

    await tester.dragUntilVisible(
      find.text('Delete Account'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await settle(tester, 4);
    await binding.takeScreenshot('13-settings-bottom');

    await tester.tap(find.text('Delete Account'));
    await settle(tester);
    await binding.takeScreenshot('14-delete-account');
  });
}
