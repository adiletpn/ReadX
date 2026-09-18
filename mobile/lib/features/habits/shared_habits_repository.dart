import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';

class JoinResult {
  const JoinResult({required this.habitId, required this.eligibleLimitReached});

  final int habitId;
  final bool eligibleLimitReached;

  factory JoinResult.fromJson(Map<String, dynamic> json) => JoinResult(
        habitId: asInt(json['habit_id']),
        eligibleLimitReached: asBool(json['eligible_limit_reached']),
      );
}

class SharedHabitsRepository {
  SharedHabitsRepository(this._api);

  final ApiClient _api;

  Future<JoinResult> join(int sharedHabitId) async {
    return JoinResult.fromJson(
      asMap(await _api.post(Endpoints.sharedHabitJoin(sharedHabitId))),
    );
  }

  Future<void> leave(int sharedHabitId) async {
    await _api.post(Endpoints.sharedHabitLeave(sharedHabitId));
  }
}

final sharedHabitsRepositoryProvider = Provider<SharedHabitsRepository>(
  (ref) => SharedHabitsRepository(ref.watch(apiClientProvider)),
);
