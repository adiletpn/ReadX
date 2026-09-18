import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/providers.dart';
import '../../core/utils/json.dart';
import '../../models/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> list() async {
    return mapList(await _api.get(Endpoints.notifications), AppNotification.fromJson);
  }

  Future<int> unreadCount() async {
    final data = asMap(await _api.get(Endpoints.notificationsUnread));
    return asInt(data['unread']);
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

class UnreadCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    try {
      return await ref.read(notificationsRepositoryProvider).unreadCount();
    } on Object {
      return 0;
    }
  }

  Future<void> refresh() async {
    final value = await build();
    state = AsyncData(value);
  }

  void clear() => state = const AsyncData(0);
}

final unreadCountProvider =
    AsyncNotifierProvider<UnreadCountController, int>(UnreadCountController.new);

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final items = await ref.read(notificationsRepositoryProvider).list();
    ref.read(unreadCountProvider.notifier).clear();
    return items;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(build);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    await refresh();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
  NotificationsController.new,
);
