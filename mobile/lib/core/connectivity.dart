import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkStatus extends Notifier<bool> {
  @override
  bool build() => true;

  void reportReachable() {
    if (!state) state = true;
  }

  void reportUnreachable() {
    if (state) state = false;
  }
}

final networkStatusProvider = NotifierProvider<NetworkStatus, bool>(NetworkStatus.new);

final isOfflineProvider = Provider<bool>((ref) => !ref.watch(networkStatusProvider));
