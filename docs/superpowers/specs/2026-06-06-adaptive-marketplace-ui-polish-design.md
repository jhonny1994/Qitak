# Adaptive Marketplace UI Polish Design

Date: 2026-06-06
Status: Approved for implementation planning

## Objective

Polish every routed Qitak screen into a coherent, production-grade mobile
marketplace interface in both light and dark themes. Preserve the current
features, navigation, permissions, repositories, and business behavior while
improving visible hierarchy, spacing, typography, surfaces, responsive
behavior, and state presentation.

This design intentionally addresses visible UI polish across the whole app. It
does not expand product scope or redesign backend behavior.

## Approved Direction

Use an adaptive marketplace design system:

- Preserve the Qitak identity and existing brand assets.
- Let listings, transactions, messages, and operational data lead the layout.
- Use cards only when they group a real marketplace or operational object.
- Give light and dark themes equivalent hierarchy and semantic contrast.
- Flatten utility, settings, and form layouts where panel stacking adds no
  meaning.
- Keep one dominant action per screen and visually separate secondary and
  destructive actions.

## Scope

### Included

- Theme tokens and Material component themes.
- Shared Qitak presentation components.
- Role-aware navigation shell presentation.
- All routed screens under `lib/features/**/presentation`.
- Visible empty, loading, error, content, disabled, selected, and destructive
  states already supported by those screens.
- Light and dark themes.
- Narrow-width, large-text, keyboard-open, RTL, and supported-locale layout
  resilience.
- Visual review fixtures, golden coverage, accessibility tests, and focused
  widget tests necessary to validate the redesign.

### Excluded

- Repository, API, Supabase, and database behavior changes.
- Route, role, permission, or capability model changes.
- New product features or additional workflow steps.
- Replacing the Qitak logo or creating a new brand identity.
- Refactoring unrelated data or domain code.
- Native platform redesign outside Flutter-owned presentation.

## Design Principles

### 1. Content Leads

Marketplace objects should be visually stronger than surrounding chrome.
Listing media, title, price, location, condition, and seller trust information
must read before decorative surfaces.

Operational objects should expose identity and state immediately. A transaction
row should show what the deal concerns, who is involved, its current status,
and the next required action rather than leading with an internal identifier.

### 2. Surfaces Communicate Structure

Use surface elevation and borders only when they communicate containment,
interaction, or hierarchy.

- Page backgrounds provide the base layer.
- Flat sections organize related controls and text.
- Cards represent listings, transactions, conversations, queue items, and
  other distinct objects.
- Sheets and dialogs provide temporary task contexts without adding another
  unnecessary internal card.

### 3. One Primary Task

Each screen should make its primary user intent obvious:

- Auth screens submit credentials.
- Discovery screens search or inspect listings.
- Listing detail starts the relevant marketplace action.
- Seller forms save or submit a listing.
- Transaction screens perform the next lifecycle action.
- Admin detail screens make one decision at a time.

Secondary actions should use lower-emphasis buttons, links, menus, or list
actions. Destructive actions should be separated spatially and semantically.

### 4. Adaptive, Not Inverted

Light and dark themes should be designed independently from shared semantic
tokens, not produced by mechanically inverting colors.

The same component must preserve:

- hierarchy;
- readable contrast;
- selected, disabled, pressed, focus, success, warning, and error states;
- marketplace identity;
- predictable interaction affordances.

### 5. Mobile First

All interactive controls should have usable mobile targets, clear pressed and
disabled feedback, and safe spacing. Layouts must remain usable at narrow
widths, with large text, RTL direction, and an open software keyboard.

## Design System

### Color

Light theme:

- Warm neutral page background.
- Near-black primary text.
- Muted neutral secondary text.
- White or lightly tinted object surfaces.
- Restrained green Qitak primary accent.
- Semantic success, warning, information, and error colors with readable
  foreground pairs.

Dark theme:

- Layered charcoal page and object surfaces instead of pure black.
- High-contrast off-white primary text.
- Muted cool-neutral secondary text.
- The same Qitak green semantic role, adjusted for dark contrast.
- Borders reserved for separation, selection, or focus rather than outlining
  every container.

No color may be the sole carrier of status or selection.

### Typography

Retain Inter for Latin scripts and Cairo for Arabic. Establish a small semantic
scale:

- display or page title;
- section title;
- object title;
- body;
- supporting metadata;
- label and action text.

Avoid repeated uppercase eyebrow labels where they add visual noise. Use weight,
spacing, and placement before adding extra labels.

### Spacing

Use one consistent spacing scale across shared components and screens. Page
padding must respond to available width rather than relying on disconnected
hardcoded constants.

The visual rhythm should distinguish:

- elements within one control or object;
- objects within a section;
- major page sections.

### Shape And Elevation

Reduce the current oversized panel radius. Use a smaller, consistent radius for
object cards and a related radius for fields, chips, sheets, and dialogs.

Elevation should be subtle:

- flat by default;
- raised for temporary or interactive surfaces;
- stronger only for navigation, sheets, dialogs, or sticky action regions.

### Motion

Keep motion short and functional. Theme changes, selected states, disclosure,
and loading transitions may animate, but no screen should add decorative motion
that delays an action.

## Shared Component Architecture

Update `lib/core/theme/app_theme.dart` to own semantic light/dark tokens and
Material component themes.

Update `lib/shared/widgets/qitak_components.dart` so shared components express
semantic roles rather than one universal panel treatment.

Required shared concepts:

- page canvas and responsive page padding;
- flat section container;
- object card;
- section header;
- listing card/surface;
- queue or settings row;
- status badge;
- signal/summary strip;
- empty, loading, and error state;
- sticky or bottom action region;
- confirmation modal;
- sheet and dialog shell.

Existing public component APIs should be preserved where practical. Add
variants only when they remove repeated screen-specific decoration. Do not
create a new component for a single use unless the behavior is independently
testable and materially complex.

## Screen Architecture

### Auth And Onboarding

Use focused, single-task layouts with minimal chrome. The form, title, helper
copy, and primary action should form one readable column. Seller and admin
entry links remain secondary. Onboarding content should use strong typography
and purposeful media or iconography without decorative panel stacking.

Screens:

- splash;
- onboarding;
- buyer, seller, and admin sign-in;
- buyer and seller sign-up;
- password reset;
- public language, appearance, support, and legal utilities;
- unknown route.

### Discovery

Make the marketplace feed the dominant surface. Search and filters remain
immediately accessible but should not consume excessive vertical space.
Listing cards prioritize media, title, price, location, condition, and relevant
deal type.

Screens:

- home;
- search and results;
- saved listings;
- listing detail aliases.

### Listing Detail

Order content by purchase decision:

1. media;
2. title and price;
3. condition, location, and key facts;
4. seller identity and trust information;
5. description and secondary details;
6. persistent primary marketplace action.

Owner preview must clearly replace buyer actions with listing-management
actions. Report and share remain discoverable secondary actions.

### Listing Forms

Keep the existing workflow and validation, but present fields as staged,
scannable sections. Progress and current section should remain visible. Media
management should not visually overwhelm basic listing details. Draft and
submit actions must have distinct intent and hierarchy.

Screens:

- listing create;
- listing edit;
- seller listing detail;
- seller inventory.

### Seller Surfaces

Use operational summaries rather than decorative dashboard panels. Seller
status and onboarding should clearly communicate current capability, missing
requirements, and the next action.

Screens:

- seller dashboard;
- seller listings;
- seller onboarding;
- seller application status;
- seller profile.

### Transactions

Transactions are trust-sensitive. Every transaction surface must prioritize:

- listing identity;
- buyer and seller roles;
- current lifecycle status;
- next required action and responsible party;
- payment or proof expectations;
- cancellation and dispute guidance where relevant.

The transaction list should not lead with internal tokens. The request screen
must clearly distinguish purchase from exchange. The detail screen should
adapt its action region to buyer/seller role and lifecycle state without
becoming a button stack.

Screens:

- transaction lifecycle aliases;
- transaction history;
- transaction request;
- transaction detail;
- dispute creation;
- rating.

### Messaging, Notifications, And Support

Use flatter rows with clear identity, timestamp, preview, and unread status.
Empty states should include a useful next action when one exists. Gesture
actions must not be the only way to perform an important operation.

Screens:

- conversation list;
- conversation;
- notification center;
- notification preferences;
- support center and existing support tasks.

### Admin

Retain operational density while strengthening hierarchy. Queue rows should
remain compact and scannable. Detail screens should separate evidence,
context, decision controls, and dangerous actions.

Admin Team should separate:

- invitation;
- member identity and status;
- member detail;
- role actions;
- suspension or other destructive actions.

Screens:

- admin dashboard;
- queue hub;
- seller verification queue/detail;
- listing moderation queue/detail;
- disputes queue/detail;
- reports queue/detail;
- conversation oversight;
- admin team;
- admin profile.

### Profile And Settings

Use grouped, native-feeling rows and controls. Reserve cards for account
identity or a genuinely grouped setting area. Sign out and account deletion
must be visually separated from normal preferences.

Screens:

- guest account;
- buyer, seller, and admin profiles;
- account settings;
- language;
- appearance;
- notification preferences;
- support;
- legal.

## State Presentation

Every screen family must use consistent presentation for:

- initial loading;
- pull-to-refresh;
- empty data;
- recoverable error with retry;
- terminal or permission-blocked state;
- disabled action;
- saving or submitting action;
- success feedback;
- destructive confirmation.

Loading placeholders should resemble the final content shape. Empty states
should explain the state and provide a useful next action when possible. Error
states should preserve entered user data and avoid replacing the entire screen
when a local inline error is sufficient.

## Accessibility And Responsive Behavior

The redesign must:

- maintain minimum mobile target sizing;
- expose visible focus, pressed, selected, and disabled states;
- retain semantics for icons and non-text actions;
- provide a visible alternative to important gesture-only actions;
- preserve logical focus and reading order in sheets and dialogs;
- support large text without clipping primary actions;
- remain usable with the keyboard open;
- support RTL layout and localized text expansion;
- avoid relying on color alone for status;
- respect reduced-motion platform behavior where animation is added.

## Data And Behavior Boundaries

Presentation may consume the same providers, repositories, route state, and
models differently for layout, but must not alter their contracts.

The implementation must not:

- add or remove routes;
- change guard or permission decisions;
- change transaction state transitions;
- change listing validation or submission rules;
- change seller verification requirements;
- change admin authorization;
- write new backend data solely for visual presentation.

If a screen lacks enough existing data to achieve the proposed hierarchy, the
implementation should use the best available fields and document the
limitation rather than expanding backend scope.

## Testing And Verification

### Theme And Shared Components

Add focused tests for:

- light and dark semantic tokens;
- text and surface contrast-sensitive states;
- button enabled, pressed, disabled, and destructive hierarchy;
- panel/section/object-card variants;
- responsive padding and narrow layouts;
- state messages and confirmation modals.

### Representative Screen Tests

Cover at least:

- auth form;
- home feed and search;
- listing card, detail, and form;
- seller dashboard/status;
- transaction list/request/detail;
- conversation or notification row;
- admin queue/detail/team;
- profile/settings;
- empty, loading, and error examples.

### Visual Review

Every routed screen must have current visual evidence in both themes. Role
aliases may share fixture construction, but seller/admin variants need separate
captures when content or navigation context differs.

Golden review must use deterministic fixtures and a stable viewport. Add narrow
and large-text coverage for representative high-risk screens rather than
duplicating every screen at every size.

### Completion Commands

The implementation is complete only after:

```powershell
flutter pub run intl_utils:generate
dart format lib test
flutter analyze --fatal-infos
flutter test
```

Any repository-specific visual review or integration commands identified in
the implementation plan must also pass.

## Delivery Strategy

Implement in coherent vertical slices so the app remains reviewable:

1. semantic theme and shared primitives;
2. auth, onboarding, profile, and settings;
3. discovery and saved listings;
4. listing detail, forms, and seller inventory;
5. seller dashboard, onboarding, and status;
6. transactions, disputes, and ratings;
7. messaging, notifications, and support;
8. admin queues, details, and team;
9. complete light/dark visual review and accessibility hardening.

Each slice should update its focused tests and visual evidence before moving to
the next slice. Commits should remain scoped to one stable visual family.

## Acceptance Criteria

- All routed screens use the adaptive marketplace system.
- Light and dark themes have equivalent semantic hierarchy.
- Marketplace and operational content lead over decorative containers.
- Utility and form screens no longer rely on unnecessary nested panel stacks.
- Every screen has one clear primary action where an action exists.
- Secondary and destructive actions are visually differentiated.
- Listing detail follows the approved purchase-decision hierarchy.
- Transaction surfaces expose identity, status, responsible party, and next
  action without leading with internal identifiers.
- Admin Team separates invitation, identity, role actions, and destructive
  actions.
- Empty states use available space intentionally and provide useful next steps.
- Narrow width, large text, keyboard-open, RTL, and supported locales remain
  usable.
- Existing routes, permissions, business rules, and repositories are unchanged.
- Current visual evidence exists for every routed screen in both themes.
- `flutter analyze --fatal-infos` and the required Flutter test suites pass.

## Risks And Controls

### Broad Visual Churn

Risk: shared component changes can unintentionally alter every screen.

Control: lock semantic component variants first, add focused shared tests, and
update screens in vertical slices with visual review after each slice.

### Golden Noise

Risk: a full redesign creates large expected golden changes that can obscure
real regressions.

Control: regenerate and review by screen family, keep deterministic fixtures,
and do not approve the entire golden suite as one unreviewed update.

### Behavior Regression

Risk: layout edits can accidentally change callbacks, guards, or state handling.

Control: preserve provider and callback wiring, use focused widget tests for
primary actions, and avoid changes outside presentation unless required to fix
an existing testability boundary.

### Theme Drift

Risk: one theme receives more attention and the other becomes an afterthought.

Control: implement semantic tokens and capture both themes within each vertical
slice.

## Implementation Plan Boundary

The following plan should decompose this design into test-driven, independently
reviewable tasks. It should identify exact shared component and screen files,
focused tests, visual review updates, validation commands, and commit points.
It must not include backend or product-model changes.
