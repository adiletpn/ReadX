import '../core/utils/json.dart';

/// Один участник группы в сводке совместной привычки.
class SharedHabitMember {
  const SharedHabitMember({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.completedToday,
  });

  final int userId;
  final String username;
  final String? avatarUrl;

  /// Есть только в `GET /habits/shared/:id`; в сводке внутри поста и привычки
  /// сервер это поле не отдаёт и оно остаётся false.
  final bool completedToday;

  factory SharedHabitMember.fromJson(Map<String, dynamic> json) => SharedHabitMember(
        userId: asInt(json['user_id']),
        username: asString(json['username']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        completedToday: asBool(json['completed_today']),
      );
}

/// Сводка группы, вложенная в пост-анонс и в личную привычку
/// (`getSharedHabitSummary` в server/routes/sharedHabitUtils.js).
///
/// The member list is capped at five here — the detail endpoint returns the
/// full roster instead.
class SharedHabitSummary {
  const SharedHabitSummary({
    required this.id,
    required this.title,
    required this.isPointEligible,
    required this.memberCount,
    required this.currentStreak,
    required this.members,
    required this.amIMember,
    required this.amICreator,
  });

  final int id;
  final String title;
  final bool isPointEligible;
  final int memberCount;
  final int currentStreak;
  final List<SharedHabitMember> members;
  final bool amIMember;
  final bool amICreator;

  factory SharedHabitSummary.fromJson(Map<String, dynamic> json) => SharedHabitSummary(
        id: asInt(json['id']),
        title: asString(json['title']),
        isPointEligible: asBool(json['is_point_eligible']),
        memberCount: asInt(json['member_count']),
        currentStreak: asInt(json['current_streak']),
        members: mapList(json['members'], SharedHabitMember.fromJson),
        amIMember: asBool(json['am_i_member']),
        amICreator: asBool(json['am_i_creator']),
      );

  SharedHabitSummary copyWith({
    int? memberCount,
    bool? amIMember,
    List<SharedHabitMember>? members,
  }) =>
      SharedHabitSummary(
        id: id,
        title: title,
        isPointEligible: isPointEligible,
        memberCount: memberCount ?? this.memberCount,
        currentStreak: currentStreak,
        members: members ?? this.members,
        amIMember: amIMember ?? this.amIMember,
        amICreator: amICreator,
      );
}
