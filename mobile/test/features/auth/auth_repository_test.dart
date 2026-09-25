import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/auth/auth_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late AuthRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = AuthRepository(buildTestClient(backend));
  });

  group('login', () {
    test('sends the credentials and returns the token', () async {
      backend.on('POST', Endpoints.login, body: {
        'token': 'jwt-token',
        'user': {'id': 1, 'username': 'reader'},
      });

      final token = await repo.login(email: 'reader@readx.kz', password: 'secret');

      expect(backend.lastRequest.body, {'email': 'reader@readx.kz', 'password': 'secret'});
      expect(token, 'jwt-token');
    });

    test('a wrong password surfaces the server message, not a redirect', () async {
      backend.on('POST', Endpoints.login, status: 401, body: {'error': 'Invalid credentials'});

      await expectLater(
        repo.login(email: 'reader@readx.kz', password: 'wrong'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Invalid credentials')),
      );
    });

    test('a rate-limited login keeps the server wording', () async {
      backend.on('POST', Endpoints.login,
          status: 429, body: {'error': 'Too many login attempts, try again later'});

      await expectLater(
        repo.login(email: 'a@b.kz', password: 'x'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 429)),
      );
    });
  });

  group('register', () {
    test('sends all five fields', () async {
      backend.on('POST', Endpoints.register, body: {'token': 'jwt'});

      await repo.register(
        name: 'Бекзат',
        surname: 'Ким',
        username: 'reader',
        email: 'reader@readx.kz',
        password: 'secret',
      );

      expect(backend.lastRequest.body, {
        'name': 'Бекзат',
        'surname': 'Ким',
        'username': 'reader',
        'email': 'reader@readx.kz',
        'password': 'secret',
      });
    });

    test('a taken username surfaces the server message', () async {
      backend.on('POST', Endpoints.register,
          status: 400, body: {'error': 'Username already taken'});

      await expectLater(
        repo.register(
          name: 'a',
          surname: 'b',
          username: 'reader',
          email: 'a@b.kz',
          password: 'secret',
        ),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Username already taken')),
      );
    });
  });

  group('me', () {
    test('is where the admin flag and the badges come from', () async {
      backend.on('GET', Endpoints.me, body: {
        'id': 1,
        'username': 'reader',
        'email': 'reader@readx.kz',
        'is_admin': 1,
        'totalPoints': 310,
      });

      final user = await repo.me();

      expect(user.isAdmin, isTrue);
      expect(user.totalPoints, 310);
    });
  });

  group('password recovery', () {
    test('forgot-password sends just the address', () async {
      backend.on('POST', Endpoints.forgotPassword, body: {'ok': true});

      await repo.forgotPassword('reader@readx.kz');

      expect(backend.lastRequest.body, {'email': 'reader@readx.kz'});
    });

    test('reset sends the token together with the new password', () async {
      backend.on('POST', Endpoints.resetPassword, body: {'ok': true});

      await repo.resetPassword(token: 'reset-token', password: 'new-secret');

      final body = backend.lastRequest.body! as Map;
      expect(body['token'], 'reset-token');
      expect(body['password'], 'new-secret');
    });

    test('an expired reset link surfaces the server message', () async {
      backend.on('POST', Endpoints.resetPassword,
          status: 400, body: {'error': 'Invalid or expired token'});

      await expectLater(
        repo.resetPassword(token: 'old', password: 'x'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Invalid or expired token')),
      );
    });
  });
}
