import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a fresh install has no token', () async {
    expect(await TokenStorage().read(), isNull);
  });

  test('a token written on login is read back', () async {
    final storage = TokenStorage();

    await storage.write('jwt-token');

    expect(await storage.read(), 'jwt-token');
    expect(await TokenStorage().read(), 'jwt-token');
  });

  test('an existing Keychain token is picked up on launch', () async {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'stored-jwt'});

    expect(await TokenStorage().read(), 'stored-jwt');
  });

  test('the Keychain is only touched once, then the cache answers', () async {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'stored-jwt'});
    final storage = TokenStorage();

    expect(storage.cachedToken, isNull);
    await storage.read();

    expect(storage.cachedToken, 'stored-jwt');
    expect(await storage.read(), 'stored-jwt');
  });

  test('writing fills the cache without a read', () async {
    final storage = TokenStorage();

    await storage.write('jwt-token');

    expect(storage.cachedToken, 'jwt-token');
  });

  test('logout clears both the cache and the Keychain', () async {
    FlutterSecureStorage.setMockInitialValues({'readx_token': 'stored-jwt'});
    final storage = TokenStorage();
    await storage.read();

    await storage.clear();

    expect(storage.cachedToken, isNull);
    expect(await storage.read(), isNull);
    expect(await TokenStorage().read(), isNull);
  });

  test('clearing an already empty storage is not an error', () async {
    final storage = TokenStorage();

    await storage.clear();

    expect(await storage.read(), isNull);
  });

  test('a token replaced on re-login overwrites the old one', () async {
    final storage = TokenStorage();
    await storage.write('first');

    await storage.write('second');

    expect(await storage.read(), 'second');
    expect(await TokenStorage().read(), 'second');
  });
}
