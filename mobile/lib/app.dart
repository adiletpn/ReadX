import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/common/splash_screen.dart';
import 'router.dart';

/// Root widget. The app is dark-only and portrait-only, so there is no theme
/// switching and no responsive branching beyond the 390 pt content column
/// AppScaffold applies.
class ReadXApp extends ConsumerWidget {
  const ReadXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ReadX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      darkTheme: AppTheme.build(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // Cold start only: the Keychain read plus GET /auth/me. Covering the
        // navigator instead of routing to a splash page keeps whatever deep
        // link the app was opened with intact. Logout sets the session to
        // null directly, so it never comes back through this branch.
        final auth = ref.watch(authControllerProvider);
        if (auth.isLoading && !auth.hasValue) return const SplashScreen();
        return child ?? const SplashScreen();
      },
    );
  }
}
