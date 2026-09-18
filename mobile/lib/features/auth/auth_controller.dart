import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/app_user.dart';
import 'auth_repository.dart';

class SessionExpired extends Notifier<bool> {
  @override
  bool build() => false;

  void raise() => state = true;

  void clear() => state = false;
}

final sessionExpiredProvider = NotifierProvider<SessionExpired, bool>(SessionExpired.new);

/// The session. `null` means signed out; the value is the current user.
///
/// It mirrors `AuthProvider` in src/lib/auth.tsx: on start it looks for a
/// stored token and, if there is one, resolves it through `/auth/me`. A token
/// the server rejects is thrown away rather than retried — there is no refresh
/// endpoint, the JWT simply expires after seven days.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final storage = ref.read(tokenStorageProvider);

    // Any 401 from anywhere in the app ends the session exactly once; the
    // client has already dropped the token by the time this runs.
    ref.read(apiClientProvider).onUnauthorized = () {
      if (state.value != null) ref.read(sessionExpiredProvider.notifier).raise();
      state = const AsyncData(null);
    };

    final token = await storage.read();
    if (token == null || token.isEmpty) return null;

    try {
      return await ref.read(authRepositoryProvider).me();
    } on Object {
      await storage.clear();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    final token = await repo.login(email: email, password: password);
    await storage.write(token);
    state = AsyncData(await _loadUserOrSignOut(repo));
  }

  Future<void> register({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    final token = await repo.register(
      name: name,
      surname: surname,
      username: username,
      email: email,
      password: password,
    );
    await storage.write(token);
    state = AsyncData(await _loadUserOrSignOut(repo));
  }

  /// Re-reads `/auth/me`. Called after anything that changes the numbers the
  /// profile shows — saving settings, completing a habit, posting.
  Future<void> refresh() async {
    if (state.value == null) return;
    try {
      state = AsyncData(await ref.read(authRepositoryProvider).me());
    } on Object {
      // A failed refresh keeps the previous user on screen: the session is
      // still valid (a 401 would have been handled by the interceptor), the
      // numbers are just a little stale.
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  /// The login response is incomplete, so the real user always comes from
  /// `/auth/me`. If that call fails the token is dropped again — being signed
  /// in with half a user is worse than asking for the password once more.
  Future<AppUser> _loadUserOrSignOut(AuthRepository repo) async {
    try {
      return await repo.me();
    } on Object {
      await ref.read(tokenStorageProvider).clear();
      rethrow;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Текущий пользователь или null — то, что нужно почти всем экранам.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authControllerProvider).value,
);
