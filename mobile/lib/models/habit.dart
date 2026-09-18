import '../core/utils/json.dart';
import 'shared_habit.dart';

class Habit {
  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.streak,
    required this.completedToday,
    required this.lastCompletedDate,
    required this.isPointEligible,
    required this.skipsUsed,
    required this.skipsRemaining,
    required this.sharedHabitId,
    required this.sharedHabit,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final int streak;
  final bool completedToday;
  final String? lastCompletedDate;
  final bool isPointEligible;
  final int skipsUsed;
  final int skipsRemaining;
  final int? sharedHabitId;
  final SharedHabitSummary? sharedHabit;

  bool get isShared => sharedHabitId != null;

  factory Habit.fromJson(Map<String, dynamic> json) {
    final shared = json['shared_habit'];
    return Habit(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      title: asString(json['title']),
      description: asString(json['description']),
      streak: asInt(json['streak']),
      completedToday: asBool(json['completed_today']),
      lastCompletedDate: asStringOrNull(json['last_completed_date']),
      isPointEligible: asBool(json['is_point_eligible']),
      skipsUsed: asInt(json['skips_used']),
      skipsRemaining: asInt(json['skips_remaining']),
      sharedHabitId: asIntOrNull(json['shared_habit_id']),
      sharedHabit: shared is Map ? SharedHabitSummary.fromJson(asMap(shared)) : null,
    );
  }

  Habit copyWith({
    bool? completedToday,
    int? streak,
    int? skipsRemaining,
    SharedHabitSummary? sharedHabit,
  }) =>
      Habit(
        id: id,
        userId: userId,
        title: title,
        description: description,
        streak: streak ?? this.streak,
        completedToday: completedToday ?? this.completedToday,
        lastCompletedDate: lastCompletedDate,
        isPointEligible: isPointEligible,
        skipsUsed: skipsUsed,
        skipsRemaining: skipsRemaining ?? this.skipsRemaining,
        sharedHabitId: sharedHabitId,
        sharedHabit: sharedHabit ?? this.sharedHabit,
      );
}

class CompleteResult {
  const CompleteResult({
    required this.deleted,
    required this.habitId,
    required this.completedToday,
    required this.monthlyStreak,
    required this.monthlyPoints,
    required this.pointsAwarded,
    required this.skipsRemaining,
  });

  final bool deleted;
  final int? habitId;
  final bool completedToday;
  final int monthlyStreak;
  final int monthlyPoints;
  final int? pointsAwarded;
  final int skipsRemaining;

  factory CompleteResult.fromJson(Map<String, dynamic> json) => CompleteResult(
        deleted: asBool(json['deleted']),
        habitId: asIntOrNull(json['habit_id']),
        completedToday: asBool(json['completed_today']),
        monthlyStreak: asInt(json['monthly_streak']),
        monthlyPoints: asInt(json['monthly_points']),
        pointsAwarded: asIntOrNull(json['points_awarded']),
        skipsRemaining: asInt(json['skips_remaining']),
      );
}

class CreateHabitResult {
  const CreateHabitResult({required this.habit, required this.eligibleLimitReached});

  final Habit habit;
  final bool eligibleLimitReached;

  factory CreateHabitResult.fromJson(Map<String, dynamic> json) => CreateHabitResult(
        habit: Habit.fromJson(json),
        eligibleLimitReached: asBool(json['eligible_limit_reached']),
      );
}
