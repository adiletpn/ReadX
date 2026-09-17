import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/auth/auth_controller.dart';
import 'package:readx/features/auth/auth_repository.dart';
import 'package:readx/models/app_user.dart';

AppUser _user({int id = 1, bool isAdmin = false}) => AppUser.fromJson({
      'id': id,
      'username': 'reader',
      'email': 'reader@readx.kz',
      'name': 'Reader',
      'surname': 'One',
      'is_admin': isAdmin ? 1 : 0,
      'totalPoints': 50,
    });

/// Stands in for the four /auth/* calls and records what the controller did.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.meResult, this.meError});

  AppUser? meResult;
  Object? meError;

  int meCalls = 0;
  String? lastEmail;

  @override
  Future<String> login({required String email, required String password}) async {
    lastEmail = email;
    return 'jwt-token';
  }

  @override
  Future<String> register({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    return 'jwt-token';
  }

  @override
  Future<AppUser> me() async {
    meCalls++;
    if (meError != null) throw meError!;
    return meResult!;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({required String token, required String password}) async {}
}

ProviderContainer _container(_FakeAuthRepository repo) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('starts signed out when the Keychain has no token', () async {
    final repo = _FakeAuthRepository(meResult: _user());
    final container = _container(repo);

    expect(await container.read(authControllerProvider.future), isNull);
    expect(repo.meCalls, 0);
  });

  test('restores the session from a stored token via /auth/me', () async {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'stored-jwt'});
    final repo = _FakeAuthRepository(meResult: _user(id: 42));
    final container = _container(repo);

    final user = await container.read(authControllerProvider.future);

    expect(user?.id, 42);
    expect(repo.meCalls, 1);
  });

  test('throws away a token the server rejects instead of looping', () async {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'expired-jwt'});
    final repo = _FakeAuthRepository(meError: const ApiException('Invalid token', statusCode: 401));
    final container = _container(repo);

    expect(await container.read(authControllerProvider.future), isNull);
    expect(await container.read(tokenStorageProvider).read(), isNull);
  });

  test('login stores the token and fills the session from /auth/me', () async {
    final repo = _FakeAuthRepository(meResult: _user(isAdmin: true));
    final container = _container(repo);
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'reader@readx.kz', password: 'secret');

    // The login response itself carries no is_admin, so a session that knows
    // the user is an admin can only have come from /auth/me.
    expect(container.read(currentUserProvider)?.isAdmin, isTrue);
    expect(repo.meCalls, 1);
    expect(await container.read(tokenStorageProvider).read(), 'jwt-token');
  });

  test('a failed /auth/me after login leaves no half-signed-in session', () async {
    final repo = _FakeAuthRepository(meError: const ApiException('Сервер недоступен', statusCode: 500));
    final container = _container(repo);
    await container.read(authControllerProvider.future);

    await expectLater(
      container.read(authControllerProvider.notifier).login(email: 'a@b.kz', password: 'secret'),
      throwsA(isA<ApiException>()),
    );

    expect(container.read(currentUserProvider), isNull);
    expect(await container.read(tokenStorageProvider).read(), isNull);
  });

  test('logout clears both the session and the stored token', () async {
    final repo = _FakeAuthRepository(meResult: _user());
    final container = _container(repo);
    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).login(email: 'a@b.kz', password: 'secret');

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(currentUserProvider), isNull);
    expect(await container.read(tokenStorageProvider).read(), isNull);
  });
}
