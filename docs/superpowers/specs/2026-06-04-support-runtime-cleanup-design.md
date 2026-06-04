# Support Runtime Cleanup Design

Date: 2026-06-04
Branch: `codex/support-cleanup-migration`

## Summary

This cleanup removes the last production-facing leftovers from the support and messaging surfaces without replacing the current architecture.

The existing direction stays intact:

- support tickets continue to be stored in `reports`
- transaction disputes continue to use `disputes`
- abuse and moderation reports continue to use the current report pipeline

The changes in this spec only separate support semantics from moderation semantics where the current implementation is still wrong, and remove explicit unfinished runtime fallbacks that should not ship as-is.

## Problem

Three issues remain:

1. Support tickets are stored correctly, but admin resolution still uses moderation decisions and reasons.
2. Conversation oversight ships a concrete repository path with `UnimplementedError`.
3. Messaging realtime fallback still relies on `UnsupportedError` in local or non-realtime contexts.

These are not cosmetic issues. They leave production code with the wrong domain behavior and explicit unfinished runtime paths.

## Goals

- Keep the current architecture and data model unless a change is required to remove incorrect behavior.
- Make support ticket resolution operationally correct for production.
- Remove explicit unfinished runtime repository methods from live code paths.
- Make messaging realtime degradation safe and intentional instead of throwable.
- Preserve current behavior for listing and message moderation, disputes, and existing support ticket creation.

## Non-Goals

- Do not create a new `support_tickets` table or a parallel support subsystem.
- Do not redesign the admin queue architecture.
- Do not introduce a multi-stage support workflow such as `awaiting_user` unless the existing code requires it.
- Do not redesign the messaging feature beyond removing unsafe fallback behavior.

## Design

### 1. Support resolution stays inside `reports`

Support tickets remain rows in `reports` with `reported_entity_type = support`.

The required change is not storage. The required change is resolution semantics.

Support tickets need their own admin decision and reason policies instead of reusing moderation-only policies.

Recommended support resolution shape:

- decisions:
  - `resolve`
  - `close`
- ticket statuses:
  - `open`
  - `resolved`
  - `closed`

This is intentionally small. It removes the current semantic mismatch without inventing a customer-service workflow that does not exist elsewhere in the app.

### 2. Report admin UI becomes entity-type aware

The admin report detail flow should branch by `reported_entity_type`.

- For moderation entities such as listing and message:
  - keep current moderation decision and reason policies
  - keep current moderation labels and admin behavior
- For `support`:
  - load support-specific decision and reason policies
  - render support-specific labels
  - persist support-specific resolution metadata through the same report resolution path

The queue stays unified. Only the entity-type-specific resolution behavior changes.

This preserves the existing admin workflow while making support tickets first-class instead of pretending they are abuse cases.

### 3. Reuse the existing resolution path where possible

If the existing `admin_resolve_report` contract already supports storing generic resolution action and reason values, reuse it.

Only add schema or contract changes if the current report resolution surface cannot represent:

- support decision values
- support reason codes
- support final status

The preferred migration is:

- add support resolution policy catalogs
- wire app providers to those catalogs
- update admin UI and repository mapping

Only extend report row fields if current persisted fields are insufficient.

### 4. Conversation oversight becomes a proper contract

`ConversationOversightRepository` should no longer be a concrete class with throwable methods.

It should become one of these:

- an abstract repository contract with concrete local and Supabase implementations
- or a sealed pattern already used elsewhere in the repo, if one exists and fits cleanly

The important requirement is that no production repository surface should ship explicit `UnimplementedError` for public methods.

### 5. Messaging realtime degrades safely

The current fallback behavior throws in unsupported contexts. That is the wrong runtime shape for a shipped app.

The messaging layer should degrade intentionally:

- if realtime is available, keep the current subscription behavior
- if realtime is unavailable in local or offline-like contexts, return a safe inert subscription path instead of throwing

The exact mechanism should follow existing repository patterns in the repo. The preferred fix is the smallest change that removes throwable runtime fallback behavior from normal app surfaces.

Examples of acceptable outcomes:

- empty stream
- no-op subscription object
- guarded caller path that never invokes unavailable realtime

The implementation should choose the option that matches the current repository interface with the least extra abstraction.

## Data and Policy Changes

Expected additions:

- support resolution decision policy catalog
- support resolution reason policy catalog
- app providers and labels for those catalogs

Expected non-change:

- support ticket creation remains on the current support reason policy
- report storage remains the same unless existing resolution columns prove insufficient

## Testing Strategy

Use TDD for every behavior change.

Required failing tests first:

1. admin support ticket resolution uses support decisions and reasons, not moderation ones
2. moderation report resolution still behaves exactly as before
3. conversation oversight repository no longer exposes throwable unfinished public methods
4. messaging realtime fallback in unsupported contexts does not throw and degrades safely

Required verification after implementation:

- `flutter analyze --fatal-infos`
- targeted widget and unit tests for support/admin/messaging/oversight changes
- full `flutter test`
- repo sweep for remaining live `UnimplementedError` and avoidable runtime `UnsupportedError` in the affected surfaces

## Risks

### Resolution contract drift

If support resolution needs persisted values that the current report schema cannot hold cleanly, a narrow migration may still be required.

Mitigation:

- inspect current schema and RPC contract before changing storage
- only extend schema if the existing generic resolution fields are truly insufficient

### Over-correcting messaging

It would be easy to invent a large realtime abstraction just to remove the current throw path.

Mitigation:

- use the smallest repository-safe degradation that matches existing interfaces
- do not redesign messaging architecture

## Acceptance Criteria

- Support tickets no longer display or persist moderation-only resolution semantics.
- Listing and message moderation keep their current behavior.
- No public production repository method in the touched surfaces throws `UnimplementedError`.
- Messaging realtime fallback in unsupported contexts is safe and non-throwing.
- The app remains analyzer-clean and test-clean.
