import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/habit.dart';

class CreateSharedHabitResult {
  const CreateSharedHabitResult({
    required this.postId,
    required this.sharedHabitId,
    required this.habitId,
    required this.eligibleLimitReached,
  });

  final int postId;
  final int sharedHabitId;
  final int habitId;
  final bool eligibleLimitReached;

  factory CreateSharedHabitResult.fromJson(Map<String, dynamic> json) =>
      CreateSharedHabitResult(
        postId: asInt(json['post_id']),
        sharedHabitId: asInt(json['shared_habit_id']),
        habitId: asInt(json['habit_id']),
        eligibleLimitReached: asBool(json['eligible_limit_reached']),
      );
}

class HabitsRepository {
  HabitsRepository(this._api);

  final ApiClient _api;

  Future<List<Habit>> list() async {
    return mapList(await _api.get(Endpoints.habits), Habit.fromJson);
  }

  Future<CreateHabitResult> create({
    required String title,
    required bool isPointEligible,
  }) async {
    final data = asMap(await _api.post(
      Endpoints.habits,
      body: {'title': title, 'is_point_eligible': isPointEligible},
    ));
    return CreateHabitResult.fromJson(data);
  }

  Future<CreateSharedHabitResult> createShared({
    required String title,
    required bool isPointEligible,
    String? caption,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'is_point_eligible': isPointEligible,
    };
    if (caption != null && caption.isNotEmpty) body['caption'] = caption;

    return CreateSharedHabitResult.fromJson(
      asMap(await _api.post(Endpoints.sharedHabits, body: body)),
    );
  }

  Future<CompleteResult> complete(int habitId) async {
    return CompleteResult.fromJson(
      asMap(await _api.post(Endpoints.habitComplete(habitId))),
    );
  }

  Future<void> delete(int habitId) async {
    await _api.delete(Endpoints.habit(habitId));
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>(
  (ref) => HabitsRepository(ref.watch(apiClientProvider)),
);
