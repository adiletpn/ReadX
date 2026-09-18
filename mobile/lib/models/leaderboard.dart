import '../core/utils/json.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.avatarUrl,
    required this.points,
  });

  final int rank;
  final int id;
  final String username;
  final String name;
  final String surname;
  final String? avatarUrl;
  final int points;

  String get displayName {
    final full = '$name $surname'.trim();
    return full.isEmpty ? username : full;
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: asInt(json['rank']),
        id: asInt(json['id']),
        username: asString(json['username']),
        name: asString(json['name']),
        surname: asString(json['surname']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        points: asInt(json['points']),
      );
}

class LeaderboardMe {
  const LeaderboardMe({
    required this.monthlyPoints,
    required this.totalPoints,
    required this.monthlyRank,
    required this.totalRank,
  });

  final int monthlyPoints;
  final int totalPoints;
  final int monthlyRank;
  final int totalRank;

  factory LeaderboardMe.fromJson(Map<String, dynamic> json) => LeaderboardMe(
        monthlyPoints: asInt(json['monthlyPoints']),
        totalPoints: asInt(json['totalPoints']),
        monthlyRank: asInt(json['monthlyRank']),
        totalRank: asInt(json['totalRank']),
      );
}

class Leaderboard {
  const Leaderboard({
    required this.monthly,
    required this.total,
    required this.me,
  });

  final List<LeaderboardEntry> monthly;
  final List<LeaderboardEntry> total;
  final LeaderboardMe me;

  factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
        monthly: mapList(json['monthly'], LeaderboardEntry.fromJson),
        total: mapList(json['total'], LeaderboardEntry.fromJson),
        me: LeaderboardMe.fromJson(asMap(json['me'])),
      );
}
