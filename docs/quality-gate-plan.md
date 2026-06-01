# Quality Gate

CI in `.github/workflows/qa.yml` enforces:

- `dart format --set-exit-if-changed`
- `flutter analyze` (strict, zero issues)
- `flutter test --coverage` with a **100% minimum** line coverage gate

Coverage exclusions (see workflow):

- `**/*.g.dart` — generated code
- `lib/data/local/tables.dart` — Drift schema definitions
- `lib/l10n/*` — localization ARB / generated strings

## Completed hardening

- **Repository layer**: `XoloRepository` / `DriftXoloRepository` between presentation and Drift
- **Domain entities**: `*Entity` types + mappers in `lib/data/mappers/entity_mappers.dart`
- **Modular files**: split `request_tabs`, `auth_tab`, and `database.dart` into focused modules
- **Internationalization**: full UI coverage via `app_en.arb` / `app_es.arb` and `AppLocalizations`
- **Tests**: 221+ unit tests covering core services, providers, DB queries, import/sync, and code generators
- **Logging**: `AppLogger` replaces ad-hoc `print` in core services
- **Navigation**: `go_router` with `HomeShell`
- **CI**: release workflow depends on QA; Flutter pinned to `3.32.0`

## Optional next steps

- Widget / golden tests for composer, settings, and import flows (UI files are not in the lcov gate today)
- Integration tests for sync and Postman/OpenAPI import end-to-end
- Extract remaining Drift usage from sync/import into repository methods
