import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/app_user.dart';

/// Wraps the four `/auth/*` endpoints.
///
/// `login` and `register` answer with a trimmed-down user object — no
/// `is_admin`, no badges — so both return only the token and the caller
/// follows up with [me].
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  /// Возвращает JWT. Токен живёт 7 дней, refresh на сервере нет.
  Future<String> login({required String email, required String password}) async {
    final data = asMap(await _api.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
    ));
    return asString(data['token']);
  }

  Future<String> register({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
  }) async {
    final data = asMap(await _api.post(
      Endpoints.register,
      body: {
        'name': name,
        'surname': surname,
        'username': username,
        'email': email,
        'password': password,
      },
    ));
    return asString(data['token']);
  }

  Future<AppUser> me() async {
    return AppUser.fromJson(asMap(await _api.get(Endpoints.me)));
  }

  /// The server answers identically whether or not the address exists, so the
  /// screen must not treat success as "this email is registered".
  Future<void> forgotPassword(String email) async {
    await _api.post(Endpoints.forgotPassword, body: {'email': email});
  }

  Future<void> resetPassword({required String token, required String password}) async {
    await _api.post(
      Endpoints.resetPassword,
      body: {'token': token, 'password': password},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
