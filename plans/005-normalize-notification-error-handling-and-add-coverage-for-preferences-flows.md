# Plan 005: Normalize notification error handling and add coverage for preferences flows

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- lib/features/notifications/data/notification_repository.dart lib/features/notifications/data/notification_preferences_repository.dart lib/features/notifications/presentation/notification_center_screen.dart lib/features/notifications/presentation/notification_preferences_screen.dart test/widget/notifications test/unit/notifications supabase/tests/database`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

Most data repositories in this app map backend failures into typed `AppException` values, but the notifications subsystem still lets raw Supabase errors bubble through. On the preferences screen, `_save()` does not catch failures at all, so a rejected upsert or transport error can escape the button handler and leave the user with no localized feedback. Coverage is also thin here: there is one widget test for the notification center, but no unit or widget tests for notification preferences fetch/save success and failure paths.

## Current state

- `lib/features/notifications/data/notification_repository.dart` - notification list/read-state repository with direct RPC calls and no typed error mapping.
- `lib/features/notifications/data/notification_preferences_repository.dart` - preferences fetch/save repository with direct Supabase calls and no typed error mapping.
- `lib/features/notifications/presentation/notification_preferences_screen.dart` - save button path that assumes repository success.
- `test/widget/notifications/notification_center_screen_test.dart` - the only notification-specific test file present today.

Current excerpts:

- `lib/features/notifications/data/notification_repository.dart:22-69`
  ```dart
  final rows = await resolvedClient.from('notifications').select(...);
  ...
  return resolvedClient.rpc<dynamic>('mark_notification_read');
  ...
  return resolvedClient.rpc<dynamic>(
    'mark_notification_state',
    params: <String, dynamic>{ ... },
  );
  ```
- `lib/features/notifications/data/notification_preferences_repository.dart:32-52`
  ```dart
  Future<NotificationPreferences> fetch() async {
    final row = await _client
        .from('notification_preferences')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return _mapRow(row);
  }

  Future<void> save(NotificationPreferences value) async {
    await _client.from('notification_preferences').upsert(<String, dynamic>{ ... });
  }
  ```
- `lib/features/notifications/presentation/notification_preferences_screen.dart:179-198`
  ```dart
  Future<void> _save() async {
    ...
    try {
      await ref.read(notificationPreferencesRepositoryProvider).save(draft);
      ref.invalidate(notificationPreferencesProvider);
      ...
      ScaffoldMessenger.of(context).showSnackBar(...saved...);
    } finally {
      ...
    }
  }
  ```
- Test evidence: `test/widget/notifications/notification_center_screen_test.dart` exists, but there is no `test/unit/notifications/` coverage and no preferences-specific widget test file.

Repo conventions to match:

- Repository error mapping usually happens near the Supabase boundary; follow examples such as `lib/features/support/data/support_repository.dart` and `lib/features/transactions/data/transaction_repository.dart`.
- UI layers usually catch `AppException` and convert them to localized copy; follow existing patterns in auth/listing/support screens.
- Widget tests use local fakes/overrides rather than live Supabase.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Notification unit tests | `flutter test test/unit/notifications/notification_repository_test.dart` | all pass |
| Notification widget tests | `flutter test test/widget/notifications/notification_center_screen_test.dart test/widget/notifications/notification_preferences_screen_test.dart` | all pass |
| Notification tests | `flutter test test/widget/notifications test/unit/notifications` | all pass |
| Full non-visual suite | `flutter test --exclude-tags visual-review` | all pass |

## Scope

**In scope**:
- `lib/features/notifications/data/notification_repository.dart`
- `lib/features/notifications/data/notification_preferences_repository.dart`
- `lib/features/notifications/presentation/notification_center_screen.dart`
- `lib/features/notifications/presentation/notification_preferences_screen.dart`
- new tests under `test/unit/notifications/`
- new or updated widget tests under `test/widget/notifications/`

**Out of scope**:
- Firebase token refresh plumbing
- Notification copy/localization changes unless needed for existing error tokens
- Backend schema redesign

## Git workflow

- Branch: `advisor/005-notification-error-handling`
- Commit style: conventional commits, e.g. `fix(notifications): map backend failures into app errors`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Add tests for notification preferences success and failure paths

Create focused tests in `test/unit/notifications/notification_repository_test.dart` and `test/widget/notifications/notification_preferences_screen_test.dart` for:
- preferences fetch defaulting,
- successful save with UI confirmation,
- failed save with stable UI state and localized feedback,
- notification center read-state actions when the repository throws.

Prefer small local fakes over broad end-to-end setup.

**Verify**: `flutter test test/unit/notifications/notification_repository_test.dart test/widget/notifications/notification_preferences_screen_test.dart` -> new tests pass

### Step 2: Normalize repository error mapping

Update notification repositories so backend failures are mapped into the app’s typed error surface rather than exposing raw Supabase exceptions. Match the existing repo pattern: classify PostgREST and network failures near the data boundary, and only use `StateError` for programmer/configuration misuse.

**Verify**: `flutter test test/unit/notifications/notification_repository_test.dart test/widget/notifications/notification_preferences_screen_test.dart` -> failure-path assertions pass

### Step 3: Harden notification screens against repository failures

Update `NotificationPreferencesScreen` and any notification-center write actions so:
- save/read-state failures do not escape the UI event handler,
- the screen resets loading state correctly,
- users get the same style of localized failure feedback used elsewhere in the app.

Do not redesign the screen or add new preference fields.

**Verify**: `flutter test test/widget/notifications/notification_center_screen_test.dart test/widget/notifications/notification_preferences_screen_test.dart` -> all pass

### Step 4: Consider adding backend-proof coverage if the client path exposes an untested contract gap

If the refactor reveals missing guarantees around `notification_preferences` or notification read-state RPCs, add the smallest pgTAP coverage necessary under `supabase/tests/database/`. Only do this if the contract gap is real and directly relevant to the client behavior under change.

**Verify**: `flutter test test/widget/notifications test/unit/notifications` -> all targeted client tests still pass; if a pgTAP file is added, also run and record the exact `supabase test db --local <new-file-or-dir>` command

## Test plan

- Add `test/unit/notifications/notification_repository_test.dart`.
- Add `test/widget/notifications/notification_preferences_screen_test.dart`.
- Keep `test/widget/notifications/notification_center_screen_test.dart` passing and extend it if notification-center failure coverage belongs there.
- Cover both repository success and repository failure.
- Preserve the existing notification center widget test behavior.
- If backend tests are added, keep them narrowly focused on preferences/read-state guarantees.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/unit/notifications/notification_repository_test.dart` exits 0
- [ ] `flutter test test/widget/notifications/notification_center_screen_test.dart test/widget/notifications/notification_preferences_screen_test.dart` exits 0
- [ ] `flutter test test/widget/notifications test/unit/notifications` exits 0
- [ ] `flutter test --exclude-tags visual-review` exits 0
- [ ] Notification repository methods no longer leak raw Supabase exceptions into UI event handlers
- [ ] Preferences save failure leaves the screen interactive and shows user-facing feedback
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- Existing localization/error-token infrastructure cannot represent notification failure states without a broader cross-app change.
- Fixing the write paths requires changing unrelated unread-count or Firebase subscription flows outside the scoped files.
- The notification center/provider contract is more tightly coupled to raw exception types than the current code suggests.

## Maintenance notes

- Reviewers should pay close attention to failure-state UX, not just the happy path.
- Once this lands, new notification screens should follow the same repository error-mapping pattern instead of reintroducing raw Supabase exceptions.
- The absence of notification-preferences tests is part of the problem; do not treat tests as optional cleanup in this plan.
