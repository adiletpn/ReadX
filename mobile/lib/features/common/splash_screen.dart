import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../widgets/loading_spinner.dart';

/// What is on screen while the app resolves the session at cold start: the
/// Keychain read followed by `GET /auth/me`. The web shows exactly this — a
/// blue ring on the dark background — from `ProtectedRoute` in
/// src/lib/auth.tsx.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.bg,
      child: Center(child: LoadingSpinner()),
    );
  }
}
