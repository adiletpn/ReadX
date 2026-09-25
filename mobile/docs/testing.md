# Testing

```sh
flutter analyze   # must be clean
flutter test      # unit and widget tests
```

## What is covered

| Layer | Files | What the tests hold in place |
| --- | --- | --- |
| JSON readers | `test/core/json*`, `server_date_test`, `media_url_test` | the tolerant parsing every model depends on: `0/1` booleans, numeric strings, `null` vs `""`, UTC timestamps, relative media paths |
| Models | `test/models/` | one test per response shape, including the rows the API omits fields from |
| API client | `test/core/api/` | the Bearer header, the verb each call uses, reachability reporting, and the single-flight 401 that must not fire on `/auth/*` |
| Repositories | `test/features/*/\*_repository_test.dart` | the exact request body sent for every write, asserted against `server/routes/` |
| Controllers | `test/features/*/\*_controller_test.dart` | optimistic updates, rollback on failure, and the double-tap guard on like, follow, complete and join |
| Widgets | `test/widgets/` | the states each component can be in, and the geometry the design depends on |
| Theme | `test/core/theme/` | the palette, the type scale and the layout metrics |
| Routes | `test/routes_test.dart` | the path table and which screens are reachable signed out |

## The stubbed backend

`test/helpers/fake_api.dart` replaces Dio's HTTP adapter, so no test touches
the network. A test declares the responses it needs and then reads back what
the app actually sent:

```dart
backend.on('POST', Endpoints.habits, body: {'id': 3, 'title': 'Читать'});

await repo.create(title: 'Читать', isPointEligible: true);

expect(backend.lastRequest.body, {'title': 'Читать', 'is_point_eligible': true});
```

`buildTestClient(backend, token: 'jwt')` wires that adapter into a real
`ApiClient` with a mocked Keychain, so the token interceptor runs as it does in
the app.

## Widget tests

`test/helpers/harness.dart` mounts a widget inside `ProviderScope` and the real
dark theme, at a 390 × 844 surface by default:

```dart
await pumpWidgetUnderTest(tester, const AppSwitch(value: true, onChanged: null));
```

Pass `surface:` to check a layout on the 4.7" screen, where overflows show up
first.

## Riverpod in tests

Providers are read through a `ProviderContainer` disposed in `addTearDown`.
Riverpod 3 retries a provider that throws, so a test asserting a failure path
builds its container with `retry: (_, _) => null` — otherwise `.future` never
completes and the test times out.

## Walkthroughs on a simulator

```sh
flutter drive \
  --driver integration_test/driver.dart \
  --target integration_test/walkthrough_test.dart
```

This runs against a booted simulator, writes screenshots to `shots/`, and
reports layout overflows and frame exceptions — the three bugs it has caught so
far were all invisible to `flutter analyze` and to the unit tests.
