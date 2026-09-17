import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusySet extends Notifier<Set<Object>> {
  @override
  Set<Object> build() => const {};

  bool contains(Object key) => state.contains(key);

  bool start(Object key) {
    if (state.contains(key)) return false;
    state = {...state, key};
    return true;
  }

  void finish(Object key) {
    if (!state.contains(key)) return;
    state = state.where((e) => e != key).toSet();
  }
}

final busySetProvider = NotifierProvider<BusySet, Set<Object>>(BusySet.new);
