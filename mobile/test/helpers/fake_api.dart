import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readx/core/api/api_client.dart';
import 'package:readx/core/storage/token_storage.dart';

class RecordedRequest {
  RecordedRequest(this.method, this.path, this.body, this.query, this.headers);

  final String method;
  final String path;
  final Object? body;
  final Map<String, dynamic> query;
  final Map<String, dynamic> headers;
}

class FakeRoute {
  FakeRoute({required this.status, required this.body});

  final int status;
  final Object? body;
}

class FakeBackend {
  final List<RecordedRequest> requests = [];
  final Map<String, FakeRoute> _routes = {};
  DioExceptionType? transportFailure;

  static String key(String method, String path) => '$method $path';

  void on(String method, String path, {int status = 200, Object? body}) {
    _routes[key(method, path)] = FakeRoute(status: status, body: body);
  }

  RecordedRequest get lastRequest => requests.last;

  Dio buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://readx.test/api',
      validateStatus: (_) => true,
      headers: {'Accept': 'application/json'},
    ));

    dio.httpClientAdapter = _FakeAdapter(this);
    return dio;
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.backend);

  final FakeBackend backend;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    backend.requests.add(RecordedRequest(
      options.method,
      options.path,
      options.data,
      options.queryParameters,
      options.headers,
    ));

    if (backend.transportFailure != null) {
      throw DioException(requestOptions: options, type: backend.transportFailure!);
    }

    final route = backend._routes[FakeBackend.key(options.method, options.path)];
    if (route == null) {
      return ResponseBody.fromString(
        '{"error":"no stub for ${options.method} ${options.path}"}',
        501,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      route.body == null ? '' : _encode(route.body!),
      route.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  String _encode(Object body) => body is String ? body : jsonEncode(body);
}

ApiClient buildTestClient(FakeBackend backend, {String? token}) {
  FlutterSecureStorage.setMockInitialValues(
    token == null ? {} : {'readx_token': token},
  );
  return ApiClient(tokenStorage: TokenStorage(), dio: backend.buildDio());
}
