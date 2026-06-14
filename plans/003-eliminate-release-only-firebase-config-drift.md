# Plan 003: Eliminate release-only Firebase config drift

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- .github/workflows/ci.yml lib/main.dart lib/firebase_options.dart pubspec.yaml`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: dx
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

The code analyzed and tested in CI is not guaranteed to be the same Firebase config shipped in release artifacts. The release workflow overwrites `lib/firebase_options.dart` from a secret blob just before building, while `main.dart` always imports the checked-in file for normal development and test builds. That creates hidden drift: local testing and pull-request CI can pass against one Firebase project/config shape while tagged releases ship another.

## Current state

- `.github/workflows/ci.yml` - release pipeline injects Firebase config into source files.
- `lib/main.dart` - app bootstrap imports `package:qitak_app/firebase_options.dart` directly.
- `lib/firebase_options.dart` - checked-in generated config file currently present in the repo.

Current excerpts:

- `.github/workflows/ci.yml:111-124`
  ```yaml
  - name: Inject Firebase options (lib/firebase_options.dart)
    env:
      FIREBASE_OPTIONS_DART_BASE64: ${{ secrets.FIREBASE_OPTIONS_DART_BASE64 }}
    run: |
      ...
      Path('lib/firebase_options.dart').write_bytes(base64.b64decode(data))
  ```
- `lib/main.dart:51-57`
  ```dart
  if (_supportsFirebaseRuntime) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  ```
- `lib/main.dart:16`
  ```dart
  import 'package:qitak_app/firebase_options.dart';
  ```

Repo conventions to match:

- Runtime configuration already prefers build-time injection via `--dart-define` for Supabase and Sentry; follow that style if practical.
- CI is GitHub Actions based and already uses explicit verification steps before release.
- Avoid introducing secrets into tracked files; keep sensitive material in CI secrets or platform-native config stores.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Firebase drift test | `flutter test test/unit/core/firebase_config_drift_test.dart` | all tests pass |
| Core tests | `flutter test test/unit/core` | all pass |
| Full non-visual suite | `flutter test --exclude-tags visual-review` | all pass |

## Scope

**In scope**:
- `.github/workflows/ci.yml`
- `lib/main.dart`
- `lib/firebase_options.dart` if the chosen fix requires deleting, regenerating, or replacing it
- any small bootstrap/config helper files needed to remove the drift
- targeted tests or docs updates tied directly to the new config flow

**Out of scope**:
- Android keystore handling
- Supabase runtime config
- Notification UX or routing behavior

## Git workflow

- Branch: `advisor/003-firebase-config-drift`
- Commit style: conventional commits, e.g. `build(firebase): align release and checked-in options`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Choose one authoritative Firebase config path

Replace the current split-brain setup with a single source of truth for Firebase options. Acceptable end states include:
- checked-in generated options used by every environment, with CI validating they are current, or
- runtime/platform-specific config sourcing that removes the need to overwrite a tracked Dart file in release.

Pick the smallest option that keeps analyzed code and shipped code identical. Document the decision in code comments or a short repo note if the path is non-obvious.

**Verify**: `flutter analyze --fatal-infos` -> exit 0

### Step 2: Remove release-time source overwrites

Update `.github/workflows/ci.yml` so the release job no longer rewrites `lib/firebase_options.dart` in place. If CI still needs validation, make it a comparison/fail-fast step rather than a mutation step.

Do not weaken the release pipeline by silently skipping Firebase validation.

**Verify**: `rg -n "firebase_options\\.dart|Path\\('lib/firebase_options\\.dart'\\)|write_bytes" .github/workflows/ci.yml` -> returns no release-step mutation of `lib/firebase_options.dart`

### Step 3: Add verification that catches future drift

Add a lightweight automated check so PRs fail if Firebase config falls out of sync with the chosen source of truth. Prefer a deterministic test named `test/unit/core/firebase_config_drift_test.dart` or an equivalently specific validation wired into `flutter test`.

**Verify**: `flutter test test/unit/core/firebase_config_drift_test.dart` -> passes locally

### Step 4: Re-run the normal Flutter safety net

Confirm bootstrap still initializes Firebase and messaging cleanly with the new source-of-truth approach.

**Verify**: `flutter test --exclude-tags visual-review` -> all pass

## Test plan

- Add `test/unit/core/firebase_config_drift_test.dart` to validate that the chosen source of truth matches what the app bootstraps against.
- If the final solution is workflow-only, keep the test or equivalent validation deterministic and runnable through `flutter test`.
- Keep existing core tests passing; they are the minimum regression net for bootstrap behavior.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/unit/core/firebase_config_drift_test.dart` exits 0
- [ ] `flutter test test/unit/core` exits 0
- [ ] `flutter test --exclude-tags visual-review` exits 0
- [ ] Release CI no longer overwrites `lib/firebase_options.dart`
- [ ] The Firebase config used in normal development/test builds is the same config path used for release artifacts, or drift is automatically detected before release
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- The app intentionally targets different Firebase projects per environment and there is no existing environment-selection design to reuse.
- Removing the overwrite would require introducing secrets into tracked files.
- The only viable fix depends on tooling not present in the repo and would need a broader build-system redesign.

## Maintenance notes

- Reviewers should verify that the chosen source of truth is explicit enough that future operators do not reintroduce workflow-time mutation.
- If separate staging/production Firebase projects are later needed, handle that as an intentional environment matrix, not an implicit file overwrite.
- Keep any generated-file instructions close to the workflow or script that validates them; drift problems usually return when the generation path is tribal knowledge.
