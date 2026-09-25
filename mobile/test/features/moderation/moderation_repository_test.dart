import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/profile/users_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late UsersRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = UsersRepository(buildTestClient(backend, token: 'jwt'));
  });

  group('reporting', () {
    test('sends the target, its id and the reason code', () async {
      backend.on('POST', Endpoints.reports, body: {'id': 1});

      await repo.report(
        target: ReportTarget.post,
        targetId: 9,
        reason: ReportReason.harassment,
      );

      expect(backend.lastRequest.body, {
        'target_type': 'post',
        'target_id': 9,
        'reason': 'harassment',
      });
    });

    test('all three target types are sent as the server names them', () async {
      backend.on('POST', Endpoints.reports, body: {'id': 1});

      for (final target in ReportTarget.values) {
        await repo.report(target: target, targetId: 1, reason: ReportReason.spam);
      }

      expect(
        backend.requests.map((r) => (r.body! as Map)['target_type']),
        ['post', 'comment', 'user'],
      );
    });

    test('free-text details are trimmed and only sent when filled in', () async {
      backend.on('POST', Endpoints.reports, body: {'id': 1});

      await repo.report(
        target: ReportTarget.user,
        targetId: 4,
        reason: ReportReason.other,
        details: '  оскорбления в комментариях  ',
      );
      expect((backend.lastRequest.body! as Map)['details'], 'оскорбления в комментариях');

      await repo.report(
        target: ReportTarget.user,
        targetId: 4,
        reason: ReportReason.other,
        details: '   ',
      );
      expect((backend.lastRequest.body! as Map).containsKey('details'), isFalse);
    });

    test('only Другое asks the user to type something', () async {
      expect(ReportReason.other.needsDetails, isTrue);

      for (final reason in ReportReason.values.where((r) => r != ReportReason.other)) {
        expect(reason.needsDetails, isFalse, reason: reason.name);
      }
    });

    test('every reason has a Russian label for the sheet', () {
      for (final reason in ReportReason.values) {
        expect(reason.label, isNotEmpty);
        expect(reason.code, isNotEmpty);
      }
    });
  });

  group('blocking', () {
    test('block posts and unblock deletes on the same path', () async {
      backend
        ..on('POST', Endpoints.userBlock(4), body: {'blocked': true})
        ..on('DELETE', Endpoints.userBlock(4), body: {'blocked': false});

      await repo.block(4);
      await repo.unblock(4);

      expect(backend.requests.map((r) => r.method), ['POST', 'DELETE']);
      expect(backend.requests.map((r) => r.path), ['/users/4/block', '/users/4/block']);
    });

    test('the blocked list parses as follow rows', () async {
      backend.on('GET', Endpoints.blockedUsers, body: [
        {'id': 4, 'username': 'troll', 'name': 'Тролль'},
      ]);

      expect((await repo.blockedUsers()).single.username, 'troll');
    });

    test('an empty blocked list is not an error', () async {
      backend.on('GET', Endpoints.blockedUsers, body: const []);

      expect(await repo.blockedUsers(), isEmpty);
    });
  });

  group('deleting the account', () {
    test('sends the confirmation password in the body', () async {
      backend.on('DELETE', Endpoints.deleteAccount, body: {'deleted': true});

      await repo.deleteAccount('secret');

      expect(backend.lastRequest.method, 'DELETE');
      expect(backend.lastRequest.path, '/users/me');
      expect(backend.lastRequest.body, {'password': 'secret'});
    });

    test('a wrong password surfaces the server message', () async {
      backend.on('DELETE', Endpoints.deleteAccount,
          status: 400, body: {'error': 'Incorrect password'});

      await expectLater(
        repo.deleteAccount('nope'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Incorrect password')),
      );
    });
  });
}
