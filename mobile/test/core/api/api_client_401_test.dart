import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  setUp(() => backend = FakeBackend());

  test('an expired token ends the session and clears the Keychain', () async {
    backend.on('GET', Endpoints.habits, status: 401, body: {'error': 'Invalid token'});
    final client = buildTestClient(backend, token: 'expired');

    var signedOut = 0;
    client.onUnauthorized = () => signedOut++;

    await expectLater(client.get(Endpoints.habits), throwsA(isA<ApiException>()));

    expect(signedOut, 1);
    expect(await client.tokenStorage.read(), isNull);
  });

  test('a burst of parallel 401s still counts as one expired session', () async {
    backend.on('GET', Endpoints.habits, status: 401, body: {'error': 'Invalid token'});
    backend.on('GET', Endpoints.posts, status: 401, body: {'error': 'Invalid token'});
    backend.on('GET', Endpoints.notifications, status: 401, body: {'error': 'Invalid token'});
    final client = buildTestClient(backend, token: 'expired');

    var signedOut = 0;
    client.onUnauthorized = () => signedOut++;

    await Future.wait([
      client.get(Endpoints.habits).catchError((Object _) => null),
      client.get(Endpoints.posts).catchError((Object _) => null),
      client.get(Endpoints.notifications).catchError((Object _) => null),
    ]);

    expect(signedOut, 1);
  });

  test('a wrong password does not bounce the user off the login form', () async {
    backend.on('POST', Endpoints.login, status: 401, body: {'error': 'Invalid credentials'});
    final client = buildTestClient(backend);

    var signedOut = 0;
    client.onUnauthorized = () => signedOut++;

    await expectLater(
      client.post(Endpoints.login, body: {'email': 'a@b.kz', 'password': 'wrong'}),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Invalid credentials')),
    );

    expect(signedOut, 0);
  });

  test('none of the auth endpoints trigger a sign-out', () async {
    for (final path in [
      Endpoints.login,
      Endpoints.register,
      Endpoints.forgotPassword,
      Endpoints.resetPassword,
    ]) {
      backend.on('POST', path, status: 401, body: {'error': 'nope'});
    }
    final client = buildTestClient(backend);

    var signedOut = 0;
    client.onUnauthorized = () => signedOut++;

    for (final path in [
      Endpoints.login,
      Endpoints.register,
      Endpoints.forgotPassword,
      Endpoints.resetPassword,
    ]) {
      await expectLater(client.post(path, body: const {}), throwsA(isA<ApiException>()));
    }

    expect(signedOut, 0);
  });

  test('a 403 is an error but not an expired session', () async {
    backend.on('GET', Endpoints.habits, status: 403, body: {'error': 'Forbidden'});
    final client = buildTestClient(backend, token: 'valid');

    var signedOut = 0;
    client.onUnauthorized = () => signedOut++;

    await expectLater(client.get(Endpoints.habits), throwsA(isA<ApiException>()));

    expect(signedOut, 0);
    expect(await client.tokenStorage.read(), 'valid');
  });
}
