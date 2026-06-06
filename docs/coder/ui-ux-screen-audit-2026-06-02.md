# Qitak App UI/UX Screen Audit

Date: 2026-06-02

Scope:
- Routed presentation screens in `lib/app/router.dart`
- Shared UI system in `lib/shared/widgets/qitak_components.dart`
- Theme tokens in `lib/core/theme/app_theme.dart`
- Rendered visual review captures from `test/visual_review/route_visual_review_test.dart`

Audit lens:
- Clear visual hierarchy
- Screen-specific primary action clarity
- Information density and scanability
- Consistency with shared primitives
- Role-model clarity
- System-theme and localization quality

## Rendered evidence

- A seeded local visual review pass now exists in `test/visual_review/route_visual_review_test.dart`.
- Current rendered coverage:
  - all 44 routed screens in the inventory matrix
  - 1 additional standalone auth component capture (`auth-surface-switcher`)
- Rendered artifacts:
  - `test/visual_review/goldens/auth-surface-switcher.png`
  - `test/visual_review/goldens/splash-screen.png`
  - `test/visual_review/goldens/sign-in-screen.png`
  - `test/visual_review/goldens/sign-up-screen.png`
  - `test/visual_review/goldens/onboarding-screen-step-1.png`
  - `test/visual_review/goldens/guest-account-screen.png`
  - `test/visual_review/goldens/profile-screen.png`
  - `test/visual_review/goldens/account-settings-screen.png`
  - `test/visual_review/goldens/language-selection-screen.png`
  - `test/visual_review/goldens/appearance-preferences-screen.png`
  - `test/visual_review/goldens/support-help-screen.png`
  - `test/visual_review/goldens/legal-information-screen.png`
  - `test/visual_review/goldens/unknown-route-screen.png`
  - `test/visual_review/goldens/home-screen.png`
  - `test/visual_review/goldens/search-screen.png`
  - `test/visual_review/goldens/listing-detail-screen.png`
  - `test/visual_review/goldens/listing-form-screen.png`
  - `test/visual_review/goldens/saved-listings-screen.png`
  - `test/visual_review/goldens/conversation-list-screen.png`
  - `test/visual_review/goldens/conversation-screen.png`
  - `test/visual_review/goldens/seller-onboarding-screen.png`
  - `test/visual_review/goldens/seller-dashboard-screen.png`
  - `test/visual_review/goldens/seller-listings-screen.png`
  - `test/visual_review/goldens/seller-application-status-screen.png`
  - `test/visual_review/goldens/notification-center-screen.png`
  - `test/visual_review/goldens/notification-preferences-screen.png`
  - `test/visual_review/goldens/transaction-lifecycle-screen.png`
  - `test/visual_review/goldens/transaction-detail-screen.png`
  - `test/visual_review/goldens/transaction-history-screen.png`
  - `test/visual_review/goldens/transaction-intent-screen.png`
  - `test/visual_review/goldens/dispute-create-screen.png`
  - `test/visual_review/goldens/rating-screen.png`
  - `test/visual_review/goldens/admin-dashboard-screen.png`
  - `test/visual_review/goldens/admin-queues-screen.png`
  - `test/visual_review/goldens/seller-verification-queue-screen.png`
  - `test/visual_review/goldens/verification-detail-screen.png`
  - `test/visual_review/goldens/listing-moderation-queue-screen.png`
  - `test/visual_review/goldens/listing-review-detail-screen.png`
  - `test/visual_review/goldens/disputes-queue-screen.png`
  - `test/visual_review/goldens/dispute-detail-screen.png`
  - `test/visual_review/goldens/reports-queue-screen.png`
  - `test/visual_review/goldens/report-detail-screen.png`
  - `test/visual_review/goldens/admin-team-screen.png`
  - `test/visual_review/goldens/conversation-oversight-screen.png`
- This pass is seeded and local, not Supabase-backed production runtime. It is still strong enough to validate hierarchy, spacing, weight, panel chrome, empty-state balance, step/form density, and whether operational screens stay clear or collapse into equal-weight panel stacks.

## Live visual deltas

### Remediated: Auth entry no longer foregrounds role switching
- Sign-in and sign-up now lead with the account task.
- Seller entry remains available as a secondary link instead of an inline role selector.
- Evidence:
  - `test/visual_review/goldens/auth-surface-switcher.png`
  - `test/visual_review/goldens/sign-in-screen.png`

### Remediated: Home hero hierarchy is clearer
- Search is prioritized before filter actions.
- Filter now reads as secondary utility instead of competing with browse intent.
- Evidence:
  - `test/visual_review/goldens/home-screen.png`

### Remediated: Search result language is product-facing
- Result count copy now uses explicit result phrasing instead of `1 matches`.
- The remaining issue is only low-density single-result layouts, not raw debug-like copy.
- Evidence:
  - `test/visual_review/goldens/search-screen.png`

### P1: Transaction intent is still semantically underpowered
- The surface is clean, but it does not yet feel weighty enough for a meaningful transaction-start moment.
- It reads more like a generic action form than a trust-sensitive decision point.
- Evidence:
  - `test/visual_review/goldens/transaction-intent-screen.png`

### Remediated: Listing detail and form have stronger stage cues
- Listing detail now emphasizes the transaction action dock as the next decision point.
- Listing form now separates the workflow into `Basics`, `Pricing`, and `Delivery` sections.
- Evidence:
  - `test/visual_review/goldens/listing-detail-screen.png`
  - `test/visual_review/goldens/listing-form-screen.png`

### Remediated: Seller onboarding shows the verification path
- The screen now exposes the full path up front: account type, business profile, documents, policies, and review.
- Individual steps still use the existing form shell, so deeper wizard restructuring remains out of scope.
- Evidence:
  - `test/visual_review/goldens/seller-onboarding-screen.png`

### P1: Notification empty state is too stranded
- The empty panel is centered in a large void and feels disconnected from the rest of the product shell.
- Evidence:
  - `test/visual_review/goldens/notification-center-screen.png`

### P1: Notification preferences is functionally clear but still visually overweight
- The preference rows are understandable, but the single large panel and oversized bottom action still make a basic settings surface feel heavier than it should.
- Evidence:
  - `test/visual_review/goldens/notification-preferences-screen.png`

### Remediated: Profile utility rows are grouped
- `Profile` now splits account, preferences, and help/legal utilities instead of rendering one long undifferentiated stack.
- `Support` and `Legal` are structurally fine, but they also show how often the app falls back to large heavy panels for light informational content.
- Evidence:
  - `test/visual_review/goldens/profile-screen.png`
  - `test/visual_review/goldens/support-help-screen.png`
  - `test/visual_review/goldens/legal-information-screen.png`

### Stronger surfaces are consistently operational, not decorative
- `GuestAccount`, `AccountSettings`, `SavedListings`, `ConversationList`, `SellerDashboard`, `AdminDashboard`, `SellerVerificationQueue`, `TransactionDetail`, and `Rating` all confirm the same pattern: the app is strongest when it behaves like an operational tool with explicit rows, timelines, and narrow decision points.
- `SellerApplicationStatus` belongs in that stronger family too: it reads clearly and matches the product's operational tone better than discovery/auth surfaces.
- `TransactionLifecycle` also confirms a weakness inside that stronger family: it is visually clean, but too abstract and context-light because it only shows a transaction token and state chip.
- `TransactionHistory` no longer labels the timestamp as notifications; fallback listing/partner values can still be raw when enrichment is absent.
- `AdminQueues` is one of the cleanest navigation surfaces in the app.
- `VerificationDetail` and `ListingReviewDetail` confirm that admin review screens are structurally good but still too equal-weight and panel-heavy.
- `AdminTeam` remains one of the stronger operational screens, but still shows heavy panel chrome and awkward action semantics.
- Evidence:
  - `test/visual_review/goldens/guest-account-screen.png`
  - `test/visual_review/goldens/account-settings-screen.png`
  - `test/visual_review/goldens/saved-listings-screen.png`
  - `test/visual_review/goldens/conversation-list-screen.png`
  - `test/visual_review/goldens/seller-dashboard-screen.png`
  - `test/visual_review/goldens/seller-application-status-screen.png`
  - `test/visual_review/goldens/admin-dashboard-screen.png`
  - `test/visual_review/goldens/admin-queues-screen.png`
  - `test/visual_review/goldens/seller-verification-queue-screen.png`
  - `test/visual_review/goldens/verification-detail-screen.png`
  - `test/visual_review/goldens/listing-review-detail-screen.png`
  - `test/visual_review/goldens/transaction-lifecycle-screen.png`
  - `test/visual_review/goldens/transaction-detail-screen.png`
  - `test/visual_review/goldens/transaction-history-screen.png`
  - `test/visual_review/goldens/rating-screen.png`
  - `test/visual_review/goldens/admin-team-screen.png`

## Global system findings

### Remediated: Shared panel chrome is lighter in light mode
- `QitakPanel` no longer applies a glow shadow in light mode by default.
- Light-mode surfaces now rely on subtle borders instead of universal card glow.
- Evidence:
  - `lib/shared/widgets/qitak_components.dart:19`
  - `lib/shared/widgets/qitak_components.dart:41`
  - `lib/shared/widgets/qitak_components.dart:48`
  - `lib/core/theme/app_theme.dart:316`
  - `lib/core/theme/app_theme.dart:321`
- UX effect:
  - Too many surfaces compete for attention.
  - Feed/list screens feel card-heavy instead of operational.

### P1: Spacing is mostly consistent but still manually repeated
- The app uses shared page padding, but most screens still hand-place many `SizedBox` gaps and local radii.
- Evidence:
  - `lib/shared/widgets/qitak_components.dart:11`
  - `lib/features/discovery/presentation/home_screen.dart:115`
  - `lib/features/listings/presentation/listing_form_screen.dart:201`
  - `lib/features/seller/presentation/seller_onboarding_screen.dart:148`
- UX effect:
  - Rhythm is good enough globally, but local density drifts screen to screen.

### Remediated: Auth no longer exposes role choice as the primary front-door control
- Buyer vs seller switching no longer appears as the main inline auth decision.
- Seller access is available through secondary links on auth screens.
- Evidence:
  - `lib/features/auth/presentation/auth_surface_switcher.dart:6`
  - `lib/features/auth/presentation/sign_in_screen.dart:79`
  - `lib/features/auth/presentation/sign_up_screen.dart:71`
- UX effect:
  - The product model still leaks internal role structure into account entry.

## Screen audit matrix

### Entry and auth

#### `SplashScreen` - Mostly OK
- Simple loading state with brand and progress.
- Evidence:
  - `lib/features/auth/presentation/splash_screen.dart:56`
- Gap:
  - Route resolution remains fairly complex for a startup surface.
  - `lib/features/auth/presentation/splash_screen.dart:99`

#### `OnboardingScreen` - P1 ornamental drift
- Good:
  - Uses a clear three-step narrative.
- Gap:
  - The scene block is visually decorative and gradient-heavy relative to the app's utilitarian marketplace positioning.
- Evidence:
  - `lib/features/auth/presentation/onboarding_screen.dart:193`
  - `lib/features/auth/presentation/onboarding_screen.dart:198`
- UX effect:
  - Feels more like a startup illustration carousel than a machine-grade marketplace intro.

#### `SignInScreen` - Mostly good after auth hierarchy cleanup
- Good:
  - Form is compact and focused.
  - Uses shared form patterns and clear password affordances.
- Evidence:
  - `lib/features/auth/presentation/sign_in_screen.dart:103`
  - `lib/features/auth/presentation/sign_in_screen.dart:159`
- Remaining gap:
  - Seller access still exists as a secondary auth path, but it no longer hijacks the form hierarchy.
- Evidence:
  - `lib/features/auth/presentation/sign_in_screen.dart:79`
  - `lib/features/auth/presentation/auth_surface_switcher.dart:20`

#### `SignUpScreen` - Mostly good after auth hierarchy cleanup
- Good:
  - Form groups are consistent and readable.
- Remaining gap:
  - Seller account creation remains a distinct secondary path, which is acceptable for the current role model.
- Evidence:
  - `lib/features/auth/presentation/sign_up_screen.dart:71`
  - `lib/features/auth/presentation/sign_up_screen.dart:198`
- UX effect:
  - Account creation is framed around system roles, not user intent.

#### `GuestAccountScreen` - Good
- Strong use of shared rows and utility organization.
- Evidence:
  - `lib/features/auth/presentation/guest_account_screen.dart:26`

#### `ProfileScreen` - Mostly good after utility grouping
- Good:
  - Shared row model is consistent.
- Remaining gap:
  - Group headings improve scanability, but the screen still uses panel-based account utility rows.
- Evidence:
  - `lib/features/auth/presentation/profile_screen.dart:122`
  - `lib/features/auth/presentation/profile_screen.dart:125`
- UX effect:
  - Reads like a settings dump, not a guided account hub.

#### `AccountSettingsScreen` - Good
- Clear scope, clear destructive zone separation, and one obvious save action.
- Evidence:
  - `lib/features/auth/presentation/account_settings_screen.dart:52`
  - `lib/features/auth/presentation/account_settings_screen.dart:119`

#### `LanguageSelectionScreen` - Good
- Clear list, selection state, and feedback loop.
- Evidence:
  - `lib/features/auth/presentation/language_selection_screen.dart:19`

#### `AppearancePreferencesScreen` - Good
- Good:
  - Simple and understandable.
- Fixed:
  - Theme options now anchor on `system`, then `light`, then `dark`.
- Evidence:
  - `lib/features/auth/presentation/appearance_preferences_screen.dart:77`
- UX effect:
  - Preference order communicates a dark-first bias the product direction no longer wants.

#### `SupportHelpScreen`, `LegalInformationScreen`, `ResetPasswordScreen`, `UnknownRouteScreen` - Good
- These screens stay within the shared system and do not show meaningful UI drift.

### Discovery and marketplace

#### `HomeScreen` - Mostly good after hierarchy cleanup
- Good:
  - Search-first intent is clear.
  - Featured/latest sections are legible.
- Remaining gap:
  - The top brand block is still custom, but search now leads and filter is secondary.
- Evidence:
  - `lib/features/discovery/presentation/home_screen.dart:55`
  - `lib/features/discovery/presentation/home_screen.dart:60`
  - `lib/features/discovery/presentation/home_screen.dart:123`
  - `lib/features/discovery/presentation/home_screen.dart:136`
  - `lib/features/discovery/presentation/home_screen.dart:146`
- UX effect:
  - The hero panel feels busy and tries to be brand, navigation, and search launcher at once.

#### `SearchScreen` - Mostly good after result-copy cleanup
- Good:
  - Clear search field, filter access, history, and result list.
- Remaining gap:
  - The screen can still feel sparse with one result, but the summary copy is no longer raw count text.
- Evidence:
  - `lib/features/discovery/presentation/search_screen.dart:183`
  - `lib/features/discovery/presentation/search_screen.dart:190`
- UX effect:
  - Functional, but not polished enough for a primary product surface.

#### `DiscoveryFilterSheet` - Mostly OK
- Shared primitives are used; no major structural drift found in this pass.

#### `ListingDetailScreen` - Mostly good after action emphasis
- Good:
  - Strong use of collapsible app bar, signal strips, and segmented content blocks.
- Remaining gap:
  - The full detail page still stacks several panels, but the action dock now has stronger decision weight.
- Evidence:
  - `lib/features/listings/presentation/listing_detail_screen.dart:335`
  - `lib/features/listings/presentation/listing_detail_screen.dart:349`
  - `lib/features/listings/presentation/listing_detail_screen.dart:371`
  - `lib/features/listings/presentation/listing_detail_screen.dart:390`
- UX effect:
  - Information is present, but the page feels long and dense rather than decisive.

#### `SavedListingsScreen` - Good
- Strong empty state and list structure.
- No major design-system drift in this pass.

### Seller workspace

#### `SellerDashboardScreen` - Mostly good
- Uses signal strip + queue rows well.
- The workspace reads operationally and fits the product better than the discovery hero surfaces.

#### `SellerListingsScreen` - Mostly good
- Consistent with seller workspace primitives.

#### `ListingFormScreen` - Mostly good after section staging
- Good:
  - Uses shared form groups and sections.
- Remaining gap:
  - Media and selector density still make the form substantial, but the flow now has explicit staged sections.
- Evidence:
  - `lib/features/listings/presentation/listing_form_screen.dart:176`
  - `lib/features/listings/presentation/listing_form_screen.dart:186`
  - `lib/features/listings/presentation/listing_form_screen.dart:461`
- UX effect:
  - Correct but tiring; the flow wants stronger step framing or chunk collapse.

#### `SellerOnboardingScreen` - Mostly good after path framing
- Good:
  - Step logic exists.
  - Status-aware branches are integrated.
- Remaining gap:
  - The screen still uses one scroll flow, but the full verification path is now visible up front.
- Evidence:
  - `lib/features/seller/presentation/seller_onboarding_screen.dart:117`
  - `lib/features/seller/presentation/seller_onboarding_screen.dart:148`
  - `lib/features/seller/presentation/seller_onboarding_screen.dart:491`
- UX effect:
  - Operationally valid, but cognitively heavy.

#### `SellerApplicationStatusScreen` - Good
- One of the best screens in the app.
- Timeline + status + requirements work together cleanly.

### Messaging and notifications

#### `ConversationListScreen` - Good
- Queue-row model fits inbox behavior well.

#### `ConversationScreen` - Mostly good
- Shared primitives keep it coherent.
- No major slop found in this pass.

#### `NotificationCenterScreen` - Mostly good after compact feed treatment
- Good:
  - Dismiss + read/unread actions are clear.
- Fixed:
  - Notification rows no longer use full `QitakPanel` cards or metadata chips.
- Evidence:
  - `lib/features/notifications/presentation/notification_center_screen.dart:65`
  - `lib/features/notifications/presentation/notification_center_screen.dart:108`
  - `lib/features/notifications/presentation/notification_center_screen.dart:144`
- UX effect:
  - Feels like stacked cards, not a fast-scanning notification center.

#### `NotificationPreferencesScreen` - Mostly good
- No major structural drift found in this pass.

### Transactions and trust loop

#### `TransactionIntentScreen` - P1 semantically generic
- Good:
  - Uses shared context strips and a direct primary action.
- Gap:
  - The CTA label is generic for both buy and exchange intent.
  - The flow feels technically correct, but light on negotiation context.
- Evidence:
  - `lib/features/transactions/presentation/transaction_intent_screen.dart:95`
  - `lib/features/transactions/presentation/transaction_intent_screen.dart:131`
  - `lib/features/transactions/presentation/transaction_intent_screen.dart:155`
- UX effect:
  - Functional, but undersells the seriousness of starting a deal.

#### `TransactionLifecycleScreen` - P1 list is too abstract
- Good:
  - Clear state-driven actions.
- Gap:
  - Each row mostly shows reference + state, but lacks richer contextual anchors.
- Evidence:
  - `lib/features/transactions/presentation/transaction_lifecycle_screen.dart:54`
  - `lib/features/transactions/presentation/transaction_lifecycle_screen.dart:74`
  - `lib/features/transactions/presentation/transaction_lifecycle_screen.dart:115`
- UX effect:
  - Users can act, but scanning active deals is more abstract than it should be.

#### `TransactionHistoryScreen` - Mostly good after copy fix
- Good:
  - Structurally clean.
- Fixed:
  - Date metadata is labeled `Updated`.
- Evidence:
  - `lib/features/transactions/presentation/transaction_history_screen.dart:135`
- UX effect:
  - Small but obvious copy slop.

#### `TransactionDetailScreen`, `DisputeCreateScreen`, `RatingScreen` - Mostly good
- These screens fit the shared trust-loop language better than discovery/auth.
- Main remaining issue is overall panel density, not screen-specific slop.

### Admin operations

#### `AdminDashboardScreen`, queue screens, and detail screens - Good
- These screens are the most aligned with the app's utilitarian direction.
- They rely on rows, strips, and queue semantics rather than decorative hero layouts.

#### `AdminTeamScreen` - P1 action-label mismatch and dense action cluster
- Good:
  - Operational structure is coherent.
- Gap:
  - The detail action uses `sellerListingsPreviewAction` copy for team-member detail, which is semantically off.
  - Each member card exposes too many sibling actions at once.
- Evidence:
  - `lib/features/admin/presentation/admin_team_screen.dart:88`
  - `lib/features/admin/presentation/admin_team_screen.dart:93`
  - `lib/features/admin/presentation/admin_team_screen.dart:101`
- UX effect:
  - Feels workable for internal tooling, but not clean or deliberate.

## Remaining routed screens

This section closes the audit gap for the routed screens that were not expanded in the first pass.

### Admin routed surfaces

#### `AdminDashboardScreen` - Good
- Strong operational fit.
- Queue-row layout matches admin use better than card-heavy discovery surfaces.
- Evidence:
  - `lib/features/auth/presentation/admin_dashboard_screen.dart:24`

#### `AdminQueuesScreen` - Good
- Tight navigation hub with three high-signal routes and little noise.
- Evidence:
  - `lib/features/admin/presentation/admin_queues_screen.dart:17`

#### `SellerVerificationQueueScreen` - Good
- Empty-state signal strip plus list rows work well for internal triage.
- Evidence:
  - `lib/features/admin/presentation/seller_verification_queue_screen.dart:17`
  - `lib/features/admin/presentation/seller_verification_queue_screen.dart:24`

#### `ListingModerationQueueScreen` - Good
- Operationally clear and consistent with queue semantics.
- Evidence:
  - `lib/features/admin/presentation/listing_moderation_queue_screen.dart:17`

#### `DisputesQueueScreen` - Good
- Clean list of cases with direct drill-down.
- Evidence:
  - `lib/features/admin/presentation/disputes_queue_screen.dart:17`

#### `ReportsQueueScreen` - Good
- Good queue fit, though multi-line meta can get dense.
- Evidence:
  - `lib/features/admin/presentation/reports_queue_screen.dart:17`

#### `ListingReviewDetailScreen` - Mostly good
- Strong review checklist and listing summary.
- Minor gap:
  - Still uses stacked panels with equal visual weight.
- Evidence:
  - `lib/features/admin/presentation/listing_review_detail_screen.dart:90`
  - `lib/features/admin/presentation/listing_review_detail_screen.dart:105`

#### `VerificationDetailScreen` - Mostly good
- Uses rows and strips well for audit-like work.
- Minor gap:
  - Dense detail zones still inherit global panel heaviness.

#### `ReportDetailScreen` - Mostly good
- Operational and scan-friendly.
- Minor gap:
  - Can likely compress secondary information further.

#### `DisputeDetailScreen` - Mostly good
- Fits the trust/ops tone better than public surfaces.
- Minor gap:
  - Same stacked-panel heaviness as other detail views.

#### `ConversationOversightScreen` - Mostly good
- Strong fit for moderation work.
- Minor gap:
  - Review and metadata clusters still compete for attention because of full panel treatment.

### Auth utility routed surfaces

#### `AdminSignIn` surface - Good
- Clear separation from user auth, and admin branch remains isolated.

#### `ResetPasswordScreen` - Good
- Focused single-task surface.
- No major slop found.

#### `SupportHelpScreen` - Good
- Utility-row pattern fits the content well.

#### `LegalInformationScreen` - Good
- Simple utility navigation, no major drift.

### Listings and seller routed surfaces

#### `SellerListingsScreen` - Mostly good
- Workspace-oriented and coherent.
- Minor gap:
  - Could use stronger grouping between status overview and actual inventory rows.

#### `SellerOwned ListingDetailScreen` - Mostly good
- Seller-owned preview is better behaved than the public detail view because the action set is simpler.

### Messaging routed surfaces

#### `ConversationListScreen` - Good
- Queue-row inbox pattern is appropriate and efficient.
- Evidence:
  - `lib/features/messaging/presentation/conversation_list_screen.dart:17`

#### `ConversationScreen` - Mostly good
- Shared primitives keep it coherent.
- Minor gap:
  - Depending on message volume, the panel treatment may still feel heavier than a messaging UI should.

### Notification surfaces

#### `NotificationPreferencesScreen` - Mostly good
- Structurally clear and aligned with settings patterns.
- Minor gap:
  - Uses the same panel-heavy settings card language as all other account utilities, so it does not visually prioritize toggles.

### Transaction and trust routed surfaces

#### `TransactionHistoryScreen` - Mostly good after copy fix
- Structurally solid.
- The mislabeled date row is fixed; fallback enrichment remains the main polish gap.
- Evidence:
  - `lib/features/transactions/presentation/transaction_history_screen.dart:135`

#### `TransactionDetailScreen` - Mostly good
- Good use of timeline and listing context.
- Minor gap:
  - Action cluster can still feel like a button pile near the bottom.
- Evidence:
  - `lib/features/transactions/presentation/transaction_detail_screen.dart:142`

#### `TransactionLifecycleScreen` - P1 abstract list
- Actionable but context-light.
- Main issue is insufficient deal identity at scan time.
- Evidence:
  - `lib/features/transactions/presentation/transaction_lifecycle_screen.dart:67`
  - `lib/features/transactions/presentation/transaction_lifecycle_screen.dart:74`

#### `TransactionIntentScreen` - P1 semantically generic
- Functional but under-expressive for a serious trust/transaction step.

#### `DisputeCreateScreen` - Mostly good
- Evidence capture and reason framing are good.
- Minor gap:
  - Still form-heavy; evidence list and reason selection could be chunked more strongly.
- Evidence:
  - `lib/features/transactions/presentation/dispute_create_screen.dart:77`
  - `lib/features/transactions/presentation/dispute_create_screen.dart:121`

#### `RatingScreen` - Mostly good
- Shared primitives align the trust loop well.
- Minor gap:
  - Likely inherits the same full-panel heaviness as adjacent trust-loop surfaces.

### Seller verification/status surfaces

#### `SellerApplicationStatusScreen` - Good
- Still one of the strongest screens in the app.
- Timeline, requirements, and action clarity are all strong.

#### `SellerOnboardingScreen` - Mostly good after path framing
- The logic is stepped and the full verification path is now visible, though the screen still uses a single scroll shell.

## Route coverage checklist

Covered routed screens from `lib/app/router.dart`:
- Splash
- Onboarding
- Sign in / sign up / seller sign in / seller sign up / admin sign in
- Reset password
- Language / appearance / support / legal
- Home
- Search / search results
- Seller dashboard
- Admin dashboard
- Seller listings
- Admin queues / verifications / listings / disputes / reports / team
- Saved listings
- Messages list / thread
- Guest account
- Profile + branch utilities
- Notification center / notification preferences
- Seller onboarding / seller status
- Listing form / listing detail / seller-owned listing detail
- Deals / transactions / transaction history / transaction detail / transaction intent
- Dispute create
- Rating
- Unknown route

## Priority summary

### Remediated in this pass
- Removed buyer/seller mode switching from the primary entry UX.
- Reduced default panel glow in light mode.
- Clarified discovery hierarchy and search result copy.
- Staged listing form sections and emphasized listing detail actions.
- Added seller verification path framing.
- Fixed transaction history timestamp labeling.
- Grouped profile utilities, simplified notification rows, and made appearance system-first.

### P1
- Remaining: transaction intent is still semantically underpowered.
- Remaining: transaction lifecycle list is still abstract and context-light.
- Remaining: admin-team action semantics and action density still need a pass.
- Remaining: onboarding intro remains visually more ornamental than the marketplace tone.

### P2
- Remaining: localized/pluralized search copy should eventually move into generated localization files instead of local helper copy.
