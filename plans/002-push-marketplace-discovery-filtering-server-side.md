# Plan 002: Push marketplace discovery filtering and lookup hydration server-side

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- lib/features/discovery/data/discovery_repository.dart lib/features/discovery/providers/discovery_provider.dart test/fixtures/fake_discovery_repository.dart test/widget/discovery/home_screen_test.dart`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: perf
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

The marketplace feed currently scales linearly with the total number of listings because the client paginates through the entire result set, fetches three lookup tables on every request, then applies some filters locally. That is manageable in a seed dataset, but it turns every pull-to-refresh and search into repeated full-table work as supply grows. The discovery layer also has no dedicated unit tests around the real Supabase query shape, so a refactor here needs characterization coverage first.

## Current state

- `lib/features/discovery/data/discovery_repository.dart` - real marketplace feed/search implementation.
- `lib/features/discovery/providers/discovery_provider.dart` - provider surface used by the home and search screens.
- `test/fixtures/fake_discovery_repository.dart` - test double showing expected repository semantics.
- `test/widget/discovery/home_screen_test.dart` - existing UI safety net around the home feed.

Current excerpts:

- `lib/features/discovery/data/discovery_repository.dart:43-55`
  ```dart
  Future<List<MarketplaceListing>> fetchListings(...) async {
    final lookupsFuture = _fetchLookups();
    final rowsFuture = _fetchListingRows();
    final lookups = await lookupsFuture;
    final rows = await rowsFuture;

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => _mapListingRow(row, lookups))
        .toList(growable: false);
  }
  ```
- `lib/features/discovery/data/discovery_repository.dart:71-85`
  ```dart
  return rows
      .whereType<Map<String, dynamic>>()
      .map((row) => _mapListingRow(row, lookups))
      .where((listing) => listing.rating >= minimumRating)
      .where((listing) {
        final price = listing.priceAmount;
        ...
      })
      .toList(growable: false);
  ```
- `lib/features/discovery/data/discovery_repository.dart:114-129`
  ```dart
  final rows = <dynamic>[];
  var start = 0;
  while (true) {
    final batch = await _buildListingQuery(...).order(...).range(start, start + _pageSize - 1);
    rows.addAll(batch);
    if (batch.length < _pageSize) {
      return rows;
    }
    start += _pageSize;
  }
  ```
- `lib/features/discovery/data/discovery_repository.dart:236-241`
  ```dart
  final results = await Future.wait([
    _client.from('part_categories').select('id, slug'),
    _client.from('wilayas').select('id, name'),
    _client.from('communes').select('id, name'),
  ]);
  ```

Repo conventions to match:

- Repository classes hide Supabase details behind feature-specific methods; follow this existing pattern rather than leaking raw queries into providers.
- Test doubles already encode the intended repository contract; follow `test/fixtures/fake_discovery_repository.dart` when preserving behavior.
- Widget coverage for discovery UI already exists; augment rather than replacing it.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Discovery repository tests | `flutter test test/unit/discovery/discovery_repository_test.dart` | all tests pass |
| Discovery tests | `flutter test test/widget/discovery` | all tests pass |
| Broader Flutter suite | `flutter test --exclude-tags visual-review` | all pass |

## Scope

**In scope**:
- `lib/features/discovery/data/discovery_repository.dart`
- `lib/features/discovery/providers/discovery_provider.dart` only if the repository API must change
- `test/fixtures/fake_discovery_repository.dart` only if the contract changes
- new or updated discovery-focused unit tests under `test/unit/` or widget tests under `test/widget/discovery/`

**Out of scope**:
- Schema or migration work unless the existing database surface clearly cannot support the plan
- Home/search screen redesigns
- Saved listings, messaging, or listing-detail behavior

## Git workflow

- Branch: `advisor/002-discovery-server-filtering`
- Commit style: conventional commits, e.g. `perf(discovery): reduce marketplace query fan-out`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Add characterization coverage for real discovery query behavior

Create focused tests around `SupabaseDiscoveryRepository` before refactoring. Add `test/unit/discovery/discovery_repository_test.dart` if it does not already exist. Cover pagination behavior, lookup hydration, and which filters are applied server-side versus client-side today.

Mock or fake the Supabase boundary in the smallest practical way; do not rely on live network calls.

**Verify**: `flutter test test/unit/discovery/discovery_repository_test.dart` -> all pass

### Step 2: Reduce full-table fetching and repeated lookup fan-out

Refactor the repository so the common home/search paths do not page through the full listing table on every request. Prefer pushing price/rating filters into the database query or RPC surface and caching stable lookup tables when they do not change per request.

If the existing `listings` table query cannot express the needed filters cleanly, introduce the smallest repository-level abstraction needed and keep provider call sites stable where possible.

**Verify**: `flutter test test/unit/discovery/discovery_repository_test.dart` -> includes coverage for reduced paging/lookup behavior

### Step 3: Preserve current UI contract while tightening data loading

Make sure `MarketplaceListing` mapping, ordering, and empty/error handling remain compatible with `HomeScreen` and search screens. Do not change user-visible copy or route behavior as part of the optimization.

**Verify**: `flutter test test/widget/discovery` -> all pass

### Step 4: Run the broader Flutter safety net

Once the repository refactor is in place, run the standard non-visual suite to catch any indirect discovery regressions.

**Verify**: `flutter analyze --fatal-infos && flutter test --exclude-tags visual-review` -> both succeed

## Test plan

- Add `test/unit/discovery/discovery_repository_test.dart` if it does not already exist.
- Cover:
  - listing-page aggregation behavior,
  - lookup hydration/caching behavior,
  - search filter application for price/rating/category/location,
  - stable ordering for the home feed.
- Reuse `test/fixtures/fake_discovery_repository.dart` as the semantic reference for what callers expect.
- Keep `test/widget/discovery/home_screen_test.dart` passing without rewriting it around implementation details.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/unit/discovery/discovery_repository_test.dart` exits 0
- [ ] `flutter test test/widget/discovery` exits 0
- [ ] `flutter test --exclude-tags visual-review` exits 0
- [ ] The repository no longer loops through unbounded listing pages for common feed/search requests without a deliberate reason documented in code or tests
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- The only safe optimization path requires new SQL views/RPCs or schema changes outside this plan's scope.
- Home/search UI relies on undocumented quirks of the current over-fetching behavior and characterization tests expose incompatible caller assumptions.
- Mocking the Supabase query surface proves too brittle to test meaningfully; if so, stop and propose a narrower seam first.

## Maintenance notes

- Reviewers should check that the optimization does not silently change search semantics while improving speed.
- If the team later adds pagination or infinite scroll to the UI, build on the repository contract introduced here rather than reintroducing full-table aggregation.
- Any follow-up database-side indexing should be handled in a separate migration-focused plan once query shapes are stabilized by this refactor.
