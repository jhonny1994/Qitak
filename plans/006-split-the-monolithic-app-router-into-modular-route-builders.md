# Plan 006: Split the monolithic app router into modular route builders

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report - do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 6e228df..HEAD -- lib/app/router.dart lib/features/auth/providers/auth_route_resolution_provider.dart test/widget/auth test/widget/admin test/widget/discovery test/widget/notifications test/widget/transactions`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding; on a mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: L
- **Risk**: HIGH
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `6e228df`, 2026-06-11

## Why this matters

`lib/app/router.dart` is currently 1,332 lines and combines route declarations, redirect policy, auth aliasing, UI shell construction, profile utility route generation, and helper widgets in a single file. That is already large enough to be a merge-conflict hotspot, and the current worktree shows it is actively changing. This is not a behavior bug today, but it is a strong delivery bottleneck: any navigation change forces engineers to edit a massive, cross-cutting file with little local isolation.

## Current state

- `lib/app/router.dart` - monolithic route registry and helper UI.
- `lib/features/auth/providers/auth_route_resolution_provider.dart` - extracted auth/seller landing helpers already exist, showing the repo is beginning to move logic out of the router.
- Multiple widget suites exercise route behavior indirectly across auth, admin, discovery, notifications, and transactions.

Current excerpts:

- `lib/app/router.dart:65-884` contains the entire `GoRouter` construction with every route family in one provider.
- `lib/app/router.dart:1106-1279` defines utility shell builders plus profile utility route generation in the same file as top-level routing.
- `lib/app/router.dart:1282-1332` embeds the `_RouteWayfindingBar` widget and `GoRouterRefreshNotifier`.
- The file length is 1,332 lines.

Repo conventions to match:

- Route guards already live as dedicated widgets under auth presentation; keep that boundary.
- The newly introduced `lib/features/auth/providers/auth_route_resolution_provider.dart` shows that focused helper extraction is acceptable in this repo.
- Behavior is protected mostly by widget tests, so refactors must preserve paths and redirect semantics exactly.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Analyze | `flutter analyze --fatal-infos` | exit 0, no issues |
| Auth/admin/discovery/notification/transaction widget suites | `flutter test test/widget/auth test/widget/admin test/widget/discovery test/widget/notifications test/widget/transactions` | all pass |
| Full non-visual suite | `flutter test --exclude-tags visual-review` | all pass |

## Scope

**In scope**:
- `lib/app/router.dart`
- new router-support files under `lib/app/` if needed
- `lib/features/auth/providers/auth_route_resolution_provider.dart` only if signatures must shift slightly
- routing-related widget tests only where necessary to preserve confidence

**Out of scope**:
- Changing route paths, query-parameter names, or auth semantics
- Reworking navigation shell UI
- Adding new product features while refactoring

## Git workflow

- Branch: `advisor/006-router-modularization`
- Commit style: conventional commits, e.g. `ref(router): split route builders by domain`
- Do not push or open a PR unless the operator explicitly asks

## Steps

### Step 1: Add characterization coverage around route-critical flows if needed

Before moving code, confirm the existing widget suites cover:
- auth entry redirects,
- seller/admin guarded destinations,
- profile utility routes,
- transactions/notifications deep links that are likely to break during refactor.

Only add tests where the current suite leaves a clear gap.

**Verify**: `flutter test test/widget/auth test/widget/admin test/widget/discovery test/widget/notifications test/widget/transactions` -> all pass

### Step 2: Define a route module structure without changing paths

Split the router into focused builders such as:
- auth and onboarding routes,
- shell branches,
- profile utility routes,
- transaction/admin detail routes,
- shared shell widgets/helpers.

Keep the public `goRouterProvider` surface stable. Prefer pure helper functions or small route-builder files over introducing a complex new abstraction.

**Verify**: `flutter analyze --fatal-infos` -> exit 0

### Step 3: Extract helper widgets and route factories incrementally

Move `_RouteWayfindingBar`, utility-shell builders, and repeated route-construction helpers out of the monolith first. Then extract route groups in small, reviewable steps while keeping the app compiling after each step.

Do not mix path renames or redirect rewrites into the extraction.

**Verify**: `flutter test test/widget/auth test/widget/admin test/widget/discovery test/widget/notifications test/widget/transactions` -> all pass after each major extraction chunk

### Step 4: Re-run the full navigation safety net

Once the router is modularized, run the broad non-visual suite and inspect for path regressions, redirect loops, and guard failures.

**Verify**: `flutter test --exclude-tags visual-review` -> all pass

## Test plan

- Use the existing widget suites as the main regression harness.
- Add only narrow missing tests that pin down route behavior before moving code.
- Do not add visual/golden tests for this refactor.

## Done criteria

- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] `flutter test test/widget/auth test/widget/admin test/widget/discovery test/widget/notifications test/widget/transactions` exits 0
- [ ] `flutter test --exclude-tags visual-review` exits 0
- [ ] `rg -n "class _RouteWayfindingBar|Widget _buildStandaloneUtilityShell|Widget _buildBranchUtilityScreen|List<RouteBase> _buildProfileUtilityRoutes" lib/app/router.dart` returns no matches
- [ ] All public route paths and redirect semantics remain unchanged
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

- In-flight user changes to `lib/app/router.dart` make the file too unstable to refactor safely right now.
- Extracting modules reveals hidden cycles between `lib/app/` and feature-layer widgets/providers.
- The current widget coverage is insufficient to prove route semantics stayed stable, and adding that coverage would substantially expand scope.

## Maintenance notes

- Reviewers should compare route path strings and guard semantics carefully; modularization must not smuggle behavior changes.
- Keep route modules organized by user-facing domain, not by arbitrary chunk size.
- Future route additions should go into the new module structure directly; otherwise the monolith will regrow immediately.
