# Plan 004: Collapse dispute admin queue N+1 hydration

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- lib/features/transactions/data/dispute_repository.dart lib/features/admin/presentation/disputes_queue_screen.dart lib/features/admin/presentation/dispute_detail_screen.dart test/unit/transactions test/widget/admin`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: perf
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

The admin dispute queue currently hydrates each dispute by re-querying multiple related tables and creating signed URLs one item at a time. That means queue load cost grows with both the number of open disputes and the amount of attached evidence. This is a classic N+1 path in an operational screen, so it will feel worse precisely when trust-and-safety workload increases.

## Current state

- `lib/features/transactions/data/dispute_repository.dart` - shared dispute repository used by both admin queue and dispute detail screens.
- `lib/features/admin/presentation/disputes_queue_screen.dart` - queue consumer that loads the open dispute list.
- `lib/features/admin/presentation/dispute_detail_screen.dart` - detail consumer that needs richer hydration.
- `test/unit/transactions/` and `test/widget/admin/` - existing test homes for dispute behavior and admin surfaces.

Current excerpts:

- `lib/features/transactions/data/dispute_repository.dart:94-179`
  ```dart
  Future<TransactionDispute?> fetchById(String disputeId) async {
    final row = await _client.from('disputes').select().eq('id', disputeId).maybeSingle();
    ...
    final deal = ... from('deals') ...
    final profiles = ... from('profiles') ...
    final listing = ... from('listings') ...
    final conversation = ... from('conversations') ...
    final evidenceRows = ... from('dispute_evidence') ...
    for (final item in evidenceRows ...) {
      final previewUrl = await _client.storage.from(_bucket).createSignedUrl(storagePath, 600);
    }
  }
  ```
- `lib/features/transactions/data/dispute_repository.dart:183-194`
  ```dart
  Future<List<TransactionDispute>> listOpenDisputes() async {
    final rows = await _client
        .from('disputes')
        .select()
        .inFilter('status', queueStatuses)
        .order('created_at', ascending: false);
    final disputes = <TransactionDispute>[];
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      disputes.add(await fetchById(row['id'] as String) ?? _mapRow(row));
    }
    return disputes;
  }
  ```

Repo conventions to match:

- Repository methods should keep Supabase concerns encapsulated and return domain objects, not raw maps.
- Transaction/dispute tests already exist under `test/unit/transactions/`; follow their direct, behavior-first style.
- Admin widget tests already exercise queue/detail screens; keep the public screen contract stable.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Dispute repository tests | `flutter test test/unit/transactions/dispute_repository_test.dart` | all pass |
| Transaction unit tests | `flutter test test/unit/transactions` | all pass |
| Admin widget tests | `flutter test test/widget/admin` | all pass |
| Full non-visual suite | `flutter test --exclude-tags visual-review` | all pass |

## Scope

**In scope**:
- `lib/features/transactions/data/dispute_repository.dart`
- tests in `test/unit/transactions/`
- admin widget tests in `test/widget/admin/` only if queue/detail assertions must change

**Out of scope**:
- Supabase schema or RPC changes unless the current backend surface makes the optimization impossible
- UI redesign of dispute queue or detail screens
- Notification delivery changes triggered by dispute resolution

## Git workflow

- Branch: `advisor/004-dispute-queue-hydration`
- Commit style: conventional commits, e.g. `perf(disputes): collapse admin queue hydration fan-out`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Add characterization coverage for queue vs. detail hydration

Create or extend `test/unit/transactions/dispute_repository_test.dart` so it captures the current semantics separately for:
- `listOpenDisputes()` queue items,
- `fetchById()` detail items with listing/buyer/seller/evidence enrichment.

The goal is to protect the screen contract while allowing the queue path to become cheaper than the detail path.

**Verify**: `flutter test test/unit/transactions/dispute_repository_test.dart` -> new characterization tests pass

### Step 2: Separate lightweight queue hydration from heavy detail hydration

Refactor the repository so `listOpenDisputes()` does not call `fetchById()` for every row. Prefer one of these patterns:
- map queue rows directly when the queue needs only summary fields, or
- batch related lookups once per queue load rather than per dispute.

Keep `fetchById()` available for the detail screen, but ensure the queue path no longer performs per-item signed URL creation or repeated deal/profile/listing/conversation fetches.

**Verify**: `flutter test test/unit/transactions/dispute_repository_test.dart` -> includes coverage proving queue loading avoids detail hydration

### Step 3: Preserve rich detail hydration only where it is needed

Keep evidence preview URLs, conversation links, and participant naming available for the dispute detail screen. If the detail path still needs several lookups, make them explicit and isolated to `fetchById()`.

**Verify**: `flutter test test/widget/admin` -> dispute queue and detail screens still pass

### Step 4: Run the full safety net

Confirm the refactor stays behaviorally neutral across the broader app.

**Verify**: `flutter analyze --fatal-infos && flutter test --exclude-tags visual-review` -> both succeed

## Test plan

- Add or extend `test/unit/transactions/dispute_repository_test.dart` for:
  - open-dispute queue mapping,
  - detailed dispute fetch with evidence,
  - queue path not depending on per-item detail hydration.
- Re-run admin widget tests covering dispute queue and detail screens.
- Do not add networked integration tests for this plan.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/unit/transactions/dispute_repository_test.dart` exits 0
- [ ] `flutter test test/unit/transactions` exits 0
- [ ] `flutter test test/widget/admin` exits 0
- [ ] `flutter test --exclude-tags visual-review` exits 0
- [ ] `listOpenDisputes()` no longer loops through `fetchById()` for every row
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- The queue screen actually depends on evidence preview URLs or other detail-only fields for its current rendering.
- Eliminating the N+1 requires a new backend view/RPC that falls outside the allowed scope.
- Existing tests reveal undocumented coupling between queue and detail object shapes that cannot be preserved cleanly.

## Maintenance notes

- Reviewers should specifically check that queue responsiveness improves without degrading the detail screen.
- If a backend summary view is introduced later, it should replace the queue path only; keep detail hydration explicit.
- Similar hydration patterns exist in some admin repositories, but do not broaden this plan into a generic admin-data refactor.
