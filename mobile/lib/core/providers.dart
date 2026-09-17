import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'storage/token_storage.dart';

/// Keychain-backed JWT storage. One instance for the whole app so the
/// in-memory token cache is shared.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// The single configured Dio client. Repositories depend on this, never on
/// Dio directly.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenStorage: ref.watch(tokenStorageProvider)),
);
