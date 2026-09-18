import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  bool online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  try {
    yield online(await connectivity.checkConnectivity());
  } on Object {
    yield true;
  }

  yield* connectivity.onConnectivityChanged.map(online);
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).value == false;
});
