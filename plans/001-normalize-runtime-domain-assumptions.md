# Plan 001: Normalize runtime domain assumptions

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- lib/core/config/app_runtime_config.dart lib/core/connectivity/connectivity_service.dart lib/core/network/supabase_client_provider.dart lib/main.dart test/unit/core/supabase_config_test.dart test/unit/core/connectivity_service_test.dart`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

The app is partway through a hardcoded-domain cleanup, but two runtime behaviors still assume a Supabase-hosted domain shape. Connectivity checks always resolve `supabase.co`, and persisted auth storage keys are derived from the first hostname label only. During a custom-domain migration or local/self-hosted deployment, that can make the app report "offline" while the backend is healthy and silently rotate the session storage key, which logs users out and breaks restore flows.

## Current state

- `lib/core/connectivity/connectivity_service.dart` - online/offline provider for the whole app.
- `lib/core/network/supabase_client_provider.dart` - runtime Supabase config and persisted auth session key derivation.
- `lib/main.dart` - bootstraps Supabase with `config.runtimeUrl` and `config.persistSessionKey`.
- `test/unit/core/connectivity_service_test.dart` and `test/unit/core/supabase_config_test.dart` - existing unit-test home for these behaviors.

Current excerpts:

- `lib/core/connectivity/connectivity_service.dart:24-36`
  ```dart
  Future<bool> _resolveOnlineState(...) async {
    ...
    final response = await (lookup ?? InternetAddress.lookup)(
      'supabase.co',
    ).timeout(const Duration(seconds: 3));
    return response.isNotEmpty;
  }
  ```
- `lib/core/network/supabase_client_provider.dart:32-35`
  ```dart
  String get runtimeUrl => AppRuntimeConfig.normalizeRuntimeUrl(url);

  String get persistSessionKey =>
      'sb-${Uri.parse(url).host.split('.').first}-auth-token';
  ```
- `lib/main.dart:101-110`
  ```dart
  if (config.isConfigured) {
    ...
    await Supabase.initialize(
      url: config.runtimeUrl,
      publishableKey: config.publishableKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionLocalStorage(
          persistSessionKey: config.persistSessionKey,
  ```

Repo conventions to match:

- Runtime config logic lives under `lib/core/config/` and `lib/core/network/`.
- Unit tests for configuration/helpers are direct and table-driven; follow `test/unit/core/supabase_config_test.dart`.
- Connectivity tests inject dependencies rather than touching real network state; follow `test/unit/core/connectivity_service_test.dart`.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Targeted tests | `flutter test test/unit/core/supabase_config_test.dart test/unit/core/connectivity_service_test.dart` | all tests pass |
| Wider safety net | `flutter test test/unit/core test/unit/auth` | all tests pass |

## Scope

**In scope**:
- `lib/core/config/app_runtime_config.dart`
- `lib/core/connectivity/connectivity_service.dart`
- `lib/core/network/supabase_client_provider.dart`
- `lib/main.dart`
- `test/unit/core/supabase_config_test.dart`
- `test/unit/core/connectivity_service_test.dart`

**Out of scope**:
- Supabase backend migrations or policy changes
- UI copy for offline banners or auth screens
- Firebase configuration

## Git workflow

- Branch: `advisor/001-normalize-runtime-domain-assumptions`
- Commit style: conventional commits, matching repo history such as `fix(auth): Harden auth route redirects`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Centralize host-derived runtime metadata

Add a small, well-named runtime-config helper that parses the configured backend URL once and exposes:
- the normalized runtime URL already used for Android emulators,
- a stable host or authority string for connectivity probes,
- a persisted session namespace that does not collapse everything to the first hostname label.

Prefer deterministic normalization over ad hoc string splitting. The helper should explicitly handle localhost/127.0.0.1, multi-label custom domains, and malformed URLs without crashing the app.

**Verify**: `flutter test test/unit/core/supabase_config_test.dart` -> new and existing tests pass

### Step 2: Make connectivity checks probe the active backend host

Change the connectivity service so it no longer hardcodes `supabase.co`. Instead, use the host derived from the active runtime config, with a safe fallback only when the configured URL is empty or unparsable. Keep the current "none means offline immediately" behavior and keep dependency injection for tests.

Do not add HTTP requests here; stay with the lightweight DNS-style probe pattern already in use unless the live code shows that lookup-based probing cannot support the runtime-config injection cleanly.

**Verify**: `flutter test test/unit/core/connectivity_service_test.dart` -> includes a case proving custom backend hosts are used

### Step 3: Preserve session continuity across domain-shape changes

Update the persisted session key derivation so it is based on a stable, collision-resistant namespace from the configured backend URL instead of `host.split('.').first`. Add or update migration logic only if the change would otherwise strand existing sessions.

If you introduce a migration path, keep it scoped to storage-key continuity only; do not change token formats or Supabase auth behavior.

**Verify**: `flutter test test/unit/core/supabase_config_test.dart test/unit/core/connectivity_service_test.dart` -> all pass

### Step 4: Confirm bootstrap wiring still uses the new config surface

Ensure `main.dart` continues to initialize Supabase and session storage through the shared config object, without duplicating parsing logic at bootstrap time.

**Verify**: `flutter analyze --fatal-infos` -> exit 0

## Test plan

- Extend `test/unit/core/supabase_config_test.dart` with cases for:
  - custom backend domains,
  - localhost / Android emulator normalization,
  - stable persisted session key derivation for multi-label hosts.
- Extend `test/unit/core/connectivity_service_test.dart` with cases showing:
  - the probe uses the configured backend host rather than `supabase.co`,
  - malformed or empty config falls back safely,
  - offline behavior for `ConnectivityResult.none` remains unchanged.
- Use the existing test style in those two files as the pattern; do not introduce integration or widget tests for this plan.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/unit/core/supabase_config_test.dart test/unit/core/connectivity_service_test.dart` exits 0
- [ ] `flutter test test/unit/core test/unit/auth` exits 0
- [ ] `rg -n "supabase\\.co" lib/core test/unit/core` shows only intentional fixture/test-data mentions, not runtime assumptions
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- The runtime-config surface has already been refactored and the excerpts above no longer match.
- Fixing session continuity requires changing persisted token payloads or touching out-of-scope auth repository code.
- The connectivity provider cannot access runtime config without introducing a circular provider dependency.

## Maintenance notes

- Future backend-domain migrations should add tests in the same two core test files before changing bootstrap config.
- Reviewers should scrutinize backward compatibility of persisted session keys and any fallback behavior when config is absent.
- If the team later moves from DNS probing to an application-level health check, it should build on the host-resolution helper added here rather than reintroducing hardcoded domains.
