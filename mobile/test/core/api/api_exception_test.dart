import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/api_exception.dart';

DioException _dio(DioExceptionType type, {int? status, Object? data}) => DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: type,
      response: status == null
          ? null
          : Response<Object?>(
              requestOptions: RequestOptions(path: '/posts'),
              statusCode: status,
              data: data,
            ),
    );

void main() {
  group('ApiException.fromDio', () {
    test('every transport failure is marked as a network error', () {
      const types = [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ];

      for (final type in types) {
        final failure = ApiException.fromDio(_dio(type));
        expect(failure.isNetwork, isTrue, reason: '$type');
        expect(failure.message, 'Нет подключения к интернету');
      }
    });

    test('a cancelled request is not a network error', () {
      final failure = ApiException.fromDio(_dio(DioExceptionType.cancel));

      expect(failure.isNetwork, isFalse);
      expect(failure.message, 'Запрос отменён');
    });

    test('prefers the error text the backend sent', () {
      final failure = ApiException.fromDio(_dio(
        DioExceptionType.badResponse,
        status: 400,
        data: {'error': 'Invalid credentials'},
      ));

      expect(failure.message, 'Invalid credentials');
      expect(failure.statusCode, 400);
      expect(failure.isUnauthorized, isFalse);
    });

    test('401 is flagged as unauthorized', () {
      final failure = ApiException.fromDio(_dio(DioExceptionType.badResponse, status: 401));

      expect(failure.isUnauthorized, isTrue);
      expect(failure.message, 'Сессия истекла');
    });

    test('429 keeps the rate-limit text the server chose', () {
      final failure = ApiException.fromDio(_dio(
        DioExceptionType.badResponse,
        status: 429,
        data: {'error': 'Too many login attempts'},
      ));

      expect(failure.statusCode, 429);
      expect(failure.message, 'Too many login attempts');
    });

    test('a 5xx never leaks the server body to the user', () {
      final failure = ApiException.fromDio(_dio(
        DioExceptionType.badResponse,
        status: 500,
        data: {'error': 'SQLITE_CONSTRAINT: habits.user_id'},
      ));

      expect(failure.message, 'Сервер недоступен. Попробуйте позже');
    });

    test('an HTML error page falls back to the generic message', () {
      final failure = ApiException.fromDio(_dio(
        DioExceptionType.badResponse,
        status: 404,
        data: '<html>Not Found</html>',
      ));

      expect(failure.message, 'Что-то пошло не так');
      expect(failure.statusCode, 404);
    });
  });
}
