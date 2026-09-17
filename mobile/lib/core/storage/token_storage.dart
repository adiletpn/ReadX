import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The JWT lives in the Keychain, not in shared preferences: the web keeps it
/// in localStorage, but on iOS the Keychain is the equivalent safe place.
///
/// The token is read on nearly every request, so it is cached in memory after
/// the first read and the Keychain is only touched again on login and logout.
class TokenStorage {
  /// Keychain items survive app deletion by default, which would resurrect a
  /// stale token on reinstall. `first_unlock_this_device` keeps the item off
  /// iCloud backups and tied to this device.
  static const _options = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const _key = 'readx_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String? _cached;
  bool _loaded = false;

  /// Кэш в памяти, чтобы не дёргать Keychain на каждом запросе.
  String? get cachedToken => _cached;

  Future<String?> read() async {
    if (_loaded) return _cached;
    try {
      _cached = await _storage.read(key: _key, iOptions: _options);
    } on Object {
      // A locked or unreadable Keychain must not stop the app from starting;
      // it just means the user has to log in again.
      _cached = null;
    }
    _loaded = true;
    return _cached;
  }

  Future<void> write(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: _key, value: token, iOptions: _options);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    try {
      await _storage.delete(key: _key, iOptions: _options);
    } on Object {
      // Already gone, or the Keychain refused — the in-memory cache is
      // cleared either way, so the session is over as far as the app cares.
    }
  }
}
