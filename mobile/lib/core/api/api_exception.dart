import 'package:dio/dio.dart';

/// The single error type screens ever see.
///
/// [message] is always ready to put in front of a user: the backend answers
/// every failure with `{ "error": "..." }`, so that text is preferred, and the
/// fallbacks cover the cases where there is no body to read (timeouts, 5xx,
/// a dead connection). No screen shows `e.toString()`.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  /// Нет интернета или таймаут — экран может предложить «Повторить».
  final bool isNetwork;

  const ApiException(this.message, {this.statusCode, this.isNetwork = false});

  /// True when the session is gone. The interceptor has already cleared the
  /// token by the time a screen sees this.
  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Нет подключения к интернету', isNetwork: true);
    }
    if (e.type == DioExceptionType.cancel) {
      return const ApiException('Запрос отменён');
    }

    final code = e.response?.statusCode;
    final data = e.response?.data;
    final serverMsg = data is Map && data['error'] is String ? data['error'] as String : null;

    if (code == 429) {
      return ApiException(
        serverMsg ?? 'Слишком много запросов. Попробуйте позже',
        statusCode: 429,
      );
    }
    if (code == 401) {
      return ApiException(serverMsg ?? 'Сессия истекла', statusCode: 401);
    }
    if (code != null && code >= 500) {
      return ApiException('Сервер недоступен. Попробуйте позже', statusCode: code);
    }
    return ApiException(serverMsg ?? 'Что-то пошло не так', statusCode: code);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
