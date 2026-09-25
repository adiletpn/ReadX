# Architecture

The app is a 1:1 port of the ReadX web client onto the same Node/Express/SQLite
backend. No endpoint is mobile-only except the ones App Store review requires
(report, block, delete account).

## Layers

```
screen  ──watches──▶  controller  ──calls──▶  repository  ──▶  ApiClient  ──▶  /api
   │                      │                        │
   │                      │                        └── models, parsed through
   │                      │                            the tolerant JSON readers
   │                      └── optimistic state, rollback, busy guards
   └── loading / empty / error / success, always all four
```

A screen never builds a URL, never calls Dio, and never parses JSON. A
repository never holds state. A controller never knows about widgets.

## Why each piece is shaped that way

**`ApiClient`** lets every status through (`validateStatus: (_) => true`) and
decides itself, because the backend puts its error text in the body. It funnels
every failure into one `ApiException` whose `message` is always safe to show —
no screen ever renders `e.toString()`.

A 401 means the session died, so the client clears the token and notifies the
auth layer exactly once, even when several requests fail together. `/auth/*` is
excluded: a wrong password there is an answer, not an expired session. The web
build gets this wrong and bounces the user off the login form.

**Tolerant JSON readers** (`core/utils/json.dart`) exist because SQLite is
inconsistent about types — some endpoints convert `0/1` to booleans and others
hand the integer through. Parsing with raw casts crashes on the rows that were
not converted, so every model reads through `asBool`, `asInt`, `asString`.
`mapList` drops a malformed row instead of blanking the screen.

**`parseServerDate`** appends the `Z` SQLite omits. Without it every timestamp
is read as local time and shifts by the device's offset.

**Busy guards** (`core/busy_set.dart`) back every toggle. Like, follow, complete
and join are all toggles server-side, so a double tap silently undoes the first
tap. The guard is a shared keyed set, so two profiles open at once do not block
each other.

**Optimistic updates** apply the change before the request and restore the
previous value on failure, so the UI never sits waiting on a like.

## State

Riverpod 3, keep-alive by default. `AsyncNotifier` for anything that loads,
plain `Notifier` for tab selection and the busy set. Family notifiers take their
argument in the constructor.

Riverpod 3 retries a provider that throws, which means a transient failure heals
itself, but also that a test asserting an error path has to switch retry off.

## Routing

One `GoRouter` with a single `redirect` guard and a `refreshListenable` bridged
from the auth state. Paths mirror `src/app/routes.tsx` so a universal link from
readx.kz and a push payload's `url` both open the matching screen unchanged.

Unknown paths land on the 404 screen rather than go_router's debug page.

## Configuration

`kApiBase` and `kMediaBase` come from `--dart-define`, defaulting to production.
No URL is written anywhere else. Uploaded files arrive as root-relative paths,
so every image goes through `mediaUrl()` — on the web that resolved for free
because the page and the API share a host.

## Design system

`core/theme/` holds the palette, the type scale, the layout metrics and the
surface recipes. Screens compose those; none of them hardcodes a colour or a
radius, and Material defaults are not used — ink effects are off so taps feel
like the web's `active:opacity-60`.
