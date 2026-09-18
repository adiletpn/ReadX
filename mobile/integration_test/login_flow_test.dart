import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:readx/app.dart';
import 'package:readx/features/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('a signed-out launch lands on login and surfaces the real 401',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReadXApp()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'nobody@example.invalid');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
