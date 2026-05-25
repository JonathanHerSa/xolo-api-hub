# Quality Gate Hardening Plan

Current CI gate in `.github/workflows/qa.yml` runs:

- `dart format --set-exit-if-changed`
- `flutter analyze --no-fatal-warnings`
- `flutter test --coverage`

## Why warnings are not fatal yet

The repository still has legacy analyzer warnings in unrelated modules.
Failing the pipeline today would block all deliveries.

## Activation criteria for strict analyze

Switch to `flutter analyze` (strict) once these are completed:

1. Remove remaining `avoid_print` warnings in `lib/core/services/*`.
2. Resolve `unused_import`, `unused_local_variable`, and `unused_element_parameter` warnings.
3. Replace deprecated APIs (`withOpacity`, deprecated share APIs, deprecated storage params) in touched screens.
4. Ensure PRs cannot introduce new warnings (baseline lock).

## Rollout

1. Sprint 1: clean core/service and provider warnings.
2. Sprint 2: clean presentation warnings in screens/widgets.
3. Flip CI to strict analyze and keep coverage gate.
