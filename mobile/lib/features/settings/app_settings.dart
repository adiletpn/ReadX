import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';

class AppSettings {
  const AppSettings({
    required this.lotteryThreshold,
    required this.habitLimit,
    required this.skipsLimit,
    required this.lotteryWinnerCount,
  });

  final int lotteryThreshold;
  final int habitLimit;
  final int skipsLimit;
  final int lotteryWinnerCount;

  static const fallback = AppSettings(
    lotteryThreshold: 400,
    habitLimit: 5,
    skipsLimit: 2,
    lotteryWinnerCount: 1,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        lotteryThreshold: asInt(json['lottery_threshold'], fallback: 400),
        habitLimit: asInt(json['habit_limit'], fallback: 5),
        skipsLimit: asInt(json['skips_limit'], fallback: 2),
        lotteryWinnerCount: asInt(json['lottery_winner_count'], fallback: 1),
      );
}

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  try {
    final data = asMap(await ref.read(apiClientProvider).get(Endpoints.settings));
    return AppSettings.fromJson(data);
  } on Object {
    return AppSettings.fallback;
  }
});
