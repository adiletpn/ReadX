import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';
import 'package:readx/core/api/endpoints.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  setUp(() => backend = FakeBackend());

  test('a stored token is attached as a Bearer header', () async {
    backend.on('GET', Endpoints.me, body: {'id': 1});
    final client = buildTestClient(backend, token: 'stored-jwt');

    await client.get(Endpoints.me);

    expect(backend.lastRequest.headers['Authorization'], 'Bearer stored-jwt');
  });

  test('no token means no Authorization header at all', () async {
    backend.on('GET', Endpoints.posts, body: const []);
    final client = buildTestClient(backend);

    await client.get(Endpoints.posts);

    expect(backend.lastRequest.headers.containsKey('Authorization'), isFalse);
  });

  test('the decoded body is returned as-is', () async {
    backend.on('GET', Endpoints.posts, body: [
      {'id': 1, 'content': 'hello'},
    ]);
    final client = buildTestClient(backend);

    final result = await client.get(Endpoints.posts);

    final rows = (result as List).cast<Map<String, dynamic>>();
    expect(rows.single['content'], 'hello');
  });

  test('query parameters are passed through', () async {
    backend.on('GET', Endpoints.posts, body: const []);
    final client = buildTestClient(backend);

    await client.get(Endpoints.posts, query: {'limit': 20, 'offset': 40});

    expect(backend.lastRequest.query, {'limit': 20, 'offset': 40});
  });

  test('post, put and delete reach the right verb', () async {
    backend
      ..on('POST', Endpoints.posts, body: {'id': 1})
      ..on('PUT', Endpoints.userProfile, body: {'id': 1})
      ..on('DELETE', Endpoints.post(1), body: {'deleted': true});
    final client = buildTestClient(backend);

    await client.post(Endpoints.posts, body: {'content': 'hi'});
    await client.put(Endpoints.userProfile, body: {'name': 'Reader'});
    await client.delete(Endpoints.post(1));

    expect(backend.requests.map((r) => r.method), ['POST', 'PUT', 'DELETE']);
  });

  test('a 4xx surfaces the server error text', () async {
    backend.on('POST', Endpoints.posts, status: 400, body: {'error': 'Content is required'});
    final client = buildTestClient(backend);

    await expectLater(
      client.post(Endpoints.posts, body: {}),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Content is required')),
    );
  });

  test('a dead connection is reported as a network failure', () async {
    backend.transportFailure = DioExceptionType.connectionError;
    final client = buildTestClient(backend);

    await expectLater(
      client.get(Endpoints.posts),
      throwsA(isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue)),
    );
  });

  test('reachability is reported from the request outcome', () async {
    backend.on('GET', Endpoints.posts, body: const []);
    final client = buildTestClient(backend);

    final reported = <bool>[];
    client.onReachabilityChanged = reported.add;

    await client.get(Endpoints.posts);
    expect(reported, [true]);

    backend.transportFailure = DioExceptionType.connectionError;
    await expectLater(client.get(Endpoints.posts), throwsA(isA<ApiException>()));
    expect(reported, [true, false]);
  });

  test('a failing status does not mark the app offline', () async {
    backend.on('GET', Endpoints.posts, status: 500, body: {'error': 'boom'});
    final client = buildTestClient(backend);

    final reported = <bool>[];
    client.onReachabilityChanged = reported.add;

    await expectLater(client.get(Endpoints.posts), throwsA(isA<ApiException>()));

    expect(reported, [true]);
  });
}
