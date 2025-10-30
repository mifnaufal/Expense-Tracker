# Expense Tracker

A Flutter learning project for tracking income and expenses with a lightweight
file-based persistence layer. The app now supports a local [Shelf](https://pub.dev/packages/shelf)
backend so that every CRUD operation writes to the repository's
`data/transactions.store`, even when running in the browser.

## Project layout

- `lib/` – Flutter application code.
- `data/transactions.store` – serialized transactions (Base64/pipe-delimited).
- `backend/` & `tools/backend/` – minimal Shelf servers for local storage.
- `tool/dev_launcher.dart` – helper for starting the backend and Flutter app together.

## Prerequisites

- Flutter SDK 3.19+ (with Dart 3.3+).
- Dart & Flutter CLI available on your `PATH`.

## Quick start (auto backend)

```powershell
flutter pub get
dart run tool/dev_launcher.dart
```

The launcher will:

1. Check whether the Shelf backend is already listening on `http://localhost:8080`.
2. Start it automatically if needed and wait until `/health` responds.
3. Run `flutter run -d chrome --dart-define=EXPENSE_BACKEND_URL=http://localhost:8080`.

Use common `flutter run` arguments after the launcher command. They are passed
straight through to Flutter:

```powershell
dart run tool/dev_launcher.dart -d chrome --web-renderer html
```

### Useful switches

- `--backend-port <port>` – override the port (applies to both backend and the
  generated `--dart-define`).
- `--skip-flutter` – only start/ensure the backend; useful when you want to run
  multiple Flutter commands from other terminals.

When finished, press `q` or `CTRL+C` in the Flutter terminal; the helper will
shut down the backend automatically.

## Manual backend control

You can still manage the backend yourself if you prefer:

```powershell
cd backend
dart run bin/server.dart --port 8080
```

Then launch Flutter with the matching define:

```powershell
flutter run -d chrome --dart-define=EXPENSE_BACKEND_URL=http://localhost:8080
```

## Tests

```powershell
flutter test
```

## Troubleshooting

- If the launcher reports "backend failed to start", check that port 8080 (or
  your override) is free.
- For web builds, ensure Chrome allows requests to `http://localhost:<port>`.
- The serialized store is human-readable; commit it if you want seeded data in
  version control.
