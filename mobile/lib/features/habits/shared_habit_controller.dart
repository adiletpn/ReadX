import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../models/shared_habit.dart';
import '../feed/feed_controller.dart';
import 'habits_controller.dart';
import 'habits_repository.dart';
import 'shared_habits_repository.dart';

class SharedHabitController extends AsyncNotifier<SharedHabitDetail> {
  SharedHabitController(this.sharedHabitId);

  final int sharedHabitId;

  @override
  Future<SharedHabitDetail> build() {
    return ref.read(sharedHabitsRepositoryProvider).detail(sharedHabitId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<String?> complete() async {
    final detail = state.value;
    final habitId = detail?.myHabitId;
    if (habitId == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'complete-$habitId';
    if (!busy.start(key)) return null;

    try {
      await ref.read(habitsRepositoryProvider).complete(habitId);
      await ref.read(habitsProvider.notifier).refresh();
      state = AsyncData(await build());
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      busy.finish(key);
    }
  }

  Future<String?> join() async {
    final busy = ref.read(busySetProvider.notifier);
    final key = 'join-$sharedHabitId';
    if (!busy.start(key)) return null;

    try {
      await ref.read(sharedHabitsRepositoryProvider).join(sharedHabitId);
      ref.read(feedProvider.notifier).invalidateCache();
      await ref.read(habitsProvider.notifier).refresh();
      state = AsyncData(await build());
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      busy.finish(key);
    }
  }

  Future<String?> leave() async {
    final busy = ref.read(busySetProvider.notifier);
    final key = 'leave-$sharedHabitId';
    if (!busy.start(key)) return null;

    try {
      await ref.read(sharedHabitsRepositoryProvider).leave(sharedHabitId);
      ref.read(feedProvider.notifier).invalidateCache();
      await ref.read(habitsProvider.notifier).refresh();
      state = AsyncData(await build());
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      busy.finish(key);
    }
  }
}

final sharedHabitProvider =
    AsyncNotifierProvider.family<SharedHabitController, SharedHabitDetail, int>(
  SharedHabitController.new,
);
