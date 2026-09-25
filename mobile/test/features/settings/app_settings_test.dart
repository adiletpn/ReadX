import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/settings/app_settings.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(buildTestClient(backend, token: 'jwt'))],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => backend = FakeBackend());

  test('reads the four numbers the admin can change', () async {
    backend.on('GET', Endpoints.settings, body: {
      'lottery_threshold': 500,
      'habit_limit': 7,
      'skips_limit': 3,
      'lottery_winner_count': 2,
    });

    final settings = await container().read(appSettingsProvider.future);

    expect(settings.lotteryThreshold, 500);
    expect(settings.habitLimit, 7);
    expect(settings.skipsLimit, 3);
    expect(settings.lotteryWinnerCount, 2);
  });

  test('a missing field falls back to the documented default', () async {
    backend.on('GET', Endpoints.settings, body: {'lottery_threshold': 500});

    final settings = await container().read(appSettingsProvider.future);

    expect(settings.lotteryThreshold, 500);
    expect(settings.habitLimit, 5);
    expect(settings.skipsLimit, 2);
    expect(settings.lotteryWinnerCount, 1);
  });

  test('a failed request never breaks a screen, it uses the fallback', () async {
    backend.on('GET', Endpoints.settings, status: 500, body: {'error': 'boom'});

    final settings = await container().read(appSettingsProvider.future);

    expect(settings.lotteryThreshold, AppSettings.fallback.lotteryThreshold);
    expect(settings.habitLimit, AppSettings.fallback.habitLimit);
  });

  test('the fallback matches the numbers the copy quotes', () {
    expect(AppSettings.fallback.lotteryThreshold, 400);
    expect(AppSettings.fallback.habitLimit, 5);
    expect(AppSettings.fallback.skipsLimit, 2);
    expect(AppSettings.fallback.lotteryWinnerCount, 1);
  });

  test('numbers arriving as strings are still read', () async {
    backend.on('GET', Endpoints.settings, body: {
      'lottery_threshold': '450',
      'habit_limit': '6',
    });

    final settings = await container().read(appSettingsProvider.future);

    expect(settings.lotteryThreshold, 450);
    expect(settings.habitLimit, 6);
  });
}
