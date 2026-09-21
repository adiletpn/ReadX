# ReadX iOS

Native iOS client for ReadX, written in Flutter. It talks to the same
Node/Express/SQLite backend as the web app and mirrors its screens one to one.

## Requirements

- Flutter 3.44+ / Dart 3.12+
- Xcode 16+ with an iOS 15 or newer simulator
- CocoaPods (`sudo gem install cocoapods`)

## Running

```sh
flutter pub get
flutter run
```

The app defaults to the production API. To point it at a local server, pass the
two compile-time variables instead of editing any source file:

```sh
flutter run \
  --dart-define=READX_API_BASE=http://localhost:3000/api \
  --dart-define=READX_MEDIA_BASE=http://localhost:3000
```

## Checks

```sh
flutter analyze
flutter test
```

Visual walkthroughs run on a booted simulator and write screenshots to `shots/`:

```sh
flutter drive \
  --driver integration_test/driver.dart \
  --target integration_test/walkthrough_test.dart
```

## Layout

| Path | Contents |
| --- | --- |
| `lib/core/api` | Dio client, endpoints, the single `ApiException` |
| `lib/core/theme` | colours, typography, spacing, surfaces |
| `lib/core/utils` | tolerant JSON readers, media urls, `timeAgo` |
| `lib/models` | response models, parsed only through the JSON readers |
| `lib/features` | one folder per screen group, with its repository and controller |
| `lib/widgets` | shared UI — cards, buttons, state views, skeletons |
| `lib/router.dart` | go_router routes and the auth redirect guard |
