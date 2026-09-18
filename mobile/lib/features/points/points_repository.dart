import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/leaderboard.dart';

final leaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final data = asMap(await ref.read(apiClientProvider).get(Endpoints.leaderboard));
  return Leaderboard.fromJson(data);
});
