import 'package:dio/dio.dart';

import '../../config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'endpoints.dart';

/// Thin wrapper over Dio: attaches the Bearer token, funnels every failure
/// into [ApiException], and reports an expired session exactly once.
class ApiClient {
  /// Endpoints where a 401 is an answer, not an expired session: a wrong
  /// password on `/auth/login` must surface "Invalid credentials" on the form
  /// instead of bouncing the user to the login screen they are already on.
  static const _authPaths = {
    Endpoints.login,
    Endpoints.register,
    Endpoints.forgotPassword,
    Endpoints.resetPassword,
  };

  final TokenStorage tokenStorage;
  final Dio _dio;

  /// Called once when the session dies, so the auth layer can drop its state
  /// and the router can send the user to /login. Set by the auth layer.
  void Function()? onUnauthorized;

  /// Guards against several in-flight requests each firing the logout: the
  /// feed alone can have three running when a token expires, and three
  /// redirects in a row leave the router on a blank screen.
  bool _handlingUnauthorized = false;

  ApiClient({required this.tokenStorage, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: kApiBase,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              // Errors are read from the body, so let every status through and
              // decide here rather than letting Dio throw on its own terms.
              validateStatus: (_) => true,
              headers: {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _attachToken));
  }

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query), path);

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body), path);

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put(path, data: body), path);

  Future<dynamic> delete(String path, {Object? body}) =>
      _send(() => _dio.delete(path, data: body), path);

  /// Multipart upload. [field] is `image` for posts and `avatar` for avatars —
  /// the server answers 400 "No file uploaded" to any other field name, so it
  /// always comes from [Endpoints].
  Future<dynamic> upload(
    String path, {
    required String field,
    required String filePath,
    String? filename,
  }) async {
    final form = FormData.fromMap({
      field: await MultipartFile.fromFile(filePath, filename: filename),
    });
    return _send(() => _dio.post(path, data: form), path);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() run, String path) async {
    final Response<dynamic> response;
    try {
      response = await run();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }

    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return response.data;

    if (status == 401 && !_authPaths.contains(path)) {
      _reportUnauthorized();
    }

    throw ApiException.fromDio(DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    ));
  }

  void _reportUnauthorized() {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    final handler = onUnauthorized;
    if (handler == null) {
      _handlingUnauthorized = false;
      return;
    }
    handler();
    // Re-arm only after the current frame's failures have all gone through,
    // so a burst of parallel 401s still counts as one expired session.
    Future<void>.delayed(const Duration(seconds: 1), () {
      _handlingUnauthorized = false;
    });
  }
}
