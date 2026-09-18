import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../models/habit.dart';
import '../auth/auth_controller.dart';
import 'habits_repository.dart';

sealed class CompleteOutcome {
  const CompleteOutcome();
}

class CompleteOk extends CompleteOutcome {
  const CompleteOk({required this.completed, required this.pointsAwarded});

  final bool completed;
  final int? pointsAwarded;
}

class CompleteAutoDeleted extends CompleteOutcome {
  const CompleteAutoDeleted();
}

class CompleteFailed extends CompleteOutcome {
  const CompleteFailed(this.message);

  final String message;
}

class HabitsController extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() {
    return ref.read(habitsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(habitsRepositoryProvider).list());
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    await refresh();
  }

  Future<CompleteOutcome> complete(int habitId) async {
    final habits = state.value;
    if (habits == null) return const CompleteFailed('Привычки ещё не загружены');

    final busy = ref.read(busySetProvider.notifier);
    final key = 'complete-$habitId';
    if (!busy.start(key)) return const CompleteFailed('');

    try {
      final result = await ref.read(habitsRepositoryProvider).complete(habitId);

      if (result.deleted) {
        state = AsyncData(habits.where((h) => h.id != habitId).toList());
        await ref.read(authControllerProvider.notifier).refresh();
        return const CompleteAutoDeleted();
      }

      final index = habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final next = [...habits];
        next[index] = habits[index].copyWith(
          completedToday: result.completedToday,
          skipsRemaining: result.skipsRemaining,
        );
        state = AsyncData(next);
      }

      await ref.read(authControllerProvider.notifier).refresh();
      return CompleteOk(
        completed: result.completedToday,
        pointsAwarded: result.pointsAwarded,
      );
    } on ApiException catch (e) {
      return CompleteFailed(e.message);
    } finally {
      busy.finish(key);
    }
  }

  Future<String?> delete(int habitId) async {
    final habits = state.value;
    if (habits == null) return null;

    try {
      await ref.read(habitsRepositoryProvider).delete(habitId);
      state = AsyncData(habits.where((h) => h.id != habitId).toList());
      await ref.read(authControllerProvider.notifier).refresh();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  void prepend(Habit habit) {
    final habits = state.value;
    state = AsyncData([habit, ...?habits]);
  }

  void updateSharedHabit(int habitId, Habit updated) {
    final habits = state.value;
    if (habits == null) return;
    final index = habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final next = [...habits];
    next[index] = updated;
    state = AsyncData(next);
  }
}

final habitsProvider = AsyncNotifierProvider<HabitsController, List<Habit>>(
  HabitsController.new,
);
