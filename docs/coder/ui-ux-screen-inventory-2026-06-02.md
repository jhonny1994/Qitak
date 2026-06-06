# Qitak App Screen Inventory Matrix

Date: 2026-06-02

Verification status:
- Code-reviewed against current worktree
- Backed by a seeded local visual review for all 44 routed screens
- One additional rendered artifact covers the standalone auth role switcher component
- Not yet backed by a production-runtime screenshot sweep

Legend:
- `Good`: aligned and low-slop
- `Mostly good`: structurally solid with contained issues
- `P1`: meaningful UI/UX issue
- `P0`: foundational product-model issue
- `P2`: smaller copy/order/polish issue

Rendered visual subset now captured in `test/visual_review/goldens/`:
- Routed screens:
  - `splash-screen`, `onboarding-screen-step-1`, `sign-in-screen`, `sign-up-screen`, `reset-password-screen`
  - `guest-account-screen`, `profile-screen`, `account-settings-screen`, `language-selection-screen`, `appearance-preferences-screen`, `support-help-screen`, `legal-information-screen`, `unknown-route-screen`
  - `home-screen`, `search-screen`
  - `seller-dashboard-screen`, `admin-dashboard-screen`, `seller-listings-screen`, `listing-detail-screen`, `listing-form-screen`, `saved-listings-screen`
  - `conversation-list-screen`, `conversation-screen`
  - `notification-center-screen`, `notification-preferences-screen`
  - `seller-onboarding-screen`, `seller-application-status-screen`
  - `transaction-lifecycle-screen`, `transaction-history-screen`, `transaction-detail-screen`, `transaction-intent-screen`, `dispute-create-screen`, `rating-screen`
  - `admin-queues-screen`, `seller-verification-queue-screen`, `verification-detail-screen`, `listing-moderation-queue-screen`, `listing-review-detail-screen`, `disputes-queue-screen`, `dispute-detail-screen`, `reports-queue-screen`, `report-detail-screen`, `admin-team-screen`, `conversation-oversight-screen`
- Supporting component:
  - `auth-surface-switcher`

| Screen | Route(s) | Build style | Shared primitives | Verdict | Main gap |
|---|---|---|---|---|---|
| `SplashScreen` | `/` | stateful | `QitakPanel` | Mostly good | startup routing complexity leaks into a simple surface |
| `OnboardingScreen` | `/intro/:step` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakSignalStrip` | P1 | decorative gradient scene is off-tone for utilitarian product |
| `SignInScreen` | `/auth/sign-in`, `/auth/seller/sign-in`, `/auth/admin/sign-in` | stateful | `QitakPanel`, `QitakSectionHeader` | Mostly good | account task now leads; seller access is secondary |
| `SignUpScreen` | `/auth/sign-up`, `/auth/seller/sign-up` | stateful | `QitakPanel`, `QitakSectionHeader` | Mostly good | account task now leads; seller account creation is secondary |
| `ResetPasswordScreen` | `/auth/reset-password` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage` | Good | none significant in this pass |
| `LanguageSelectionScreen` | `/auth/language`, `/profile/language`, `/seller/profile/language`, `/admin/profile/language` | stateless | `QitakPanel`, `QitakSectionHeader` | Good | none significant in this pass |
| `AppearancePreferencesScreen` | `/auth/appearance`, `/profile/appearance`, `/seller/profile/appearance`, `/admin/profile/appearance` | stateless | `QitakPanel`, `QitakSectionHeader` | Good | system-first ordering is now in place |
| `SupportHelpScreen` | `/auth/support`, `/profile/support`, `/seller/profile/support`, `/admin/profile/support` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakQueueRow` | Good | none significant in this pass |
| `LegalInformationScreen` | `/auth/legal`, `/profile/legal`, `/seller/profile/legal`, `/admin/profile/legal` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakQueueRow` | Good | none significant in this pass |
| `GuestAccountScreen` | `/guest/account` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakQueueRow`, `QitakPageCanvas` | Good | none significant in this pass |
| `ProfileScreen` | `/profile`, `/seller/profile`, `/admin/profile` | stateless | `QitakPanel`, `QitakPullToRefresh`, `QitakQueueRow` | Mostly good | account, preference, and help/legal utilities are now grouped |
| `AccountSettingsScreen` | `/profile/settings`, `/seller/profile/settings`, `/admin/profile/settings` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage` | Good | none significant in this pass |
| `UnknownRouteScreen` | router error screen | stateless | `QitakStateMessage` | Good | none significant in this pass |
| `HomeScreen` | `/home` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakPullToRefresh` | Mostly good | search now leads and filter is secondary; custom hero remains |
| `SearchScreen` | `/search`, `/search/results` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage` | Mostly good | result copy is product-facing; sparse single-result layout remains |
| `SellerDashboardScreen` | `/seller/home`, `/seller/dashboard` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Mostly good | could tighten action hierarchy further |
| `AdminDashboardScreen` | `/admin/home`, `/admin/dashboard` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakQueueRow` | Good | none significant in this pass |
| `SellerListingsScreen` | `/seller/listings` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakListingSurface` | Mostly good | overview and inventory grouping can be clearer |
| `ListingDetailScreen` | `/listing/:id`, `/home/listing/:id`, `/seller/listings/:id` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakSignalStrip`, `QitakCollapsingSliverAppBar` | Mostly good | action dock is clearer; full page still stacks several detail zones |
| `ListingFormScreen` | `/seller/listings/new`, `/seller/listings/:id/edit` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage` | Mostly good | staged sections reduce long-form fatigue; media density remains |
| `SavedListingsScreen` | `/saved` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakQueueRow` | Good | none significant in this pass |
| `ConversationListScreen` | `/messages` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakQueueRow` | Good | none significant in this pass |
| `ConversationScreen` | `/messages/:id`, `/messages/thread/:id` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakSignalStrip` | Mostly good | message surface may still feel heavier than ideal because of panel treatment |
| `NotificationCenterScreen` | `/notifications` | stateless | `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh` | Mostly good | compact notification rows replaced full panel cards and chips |
| `NotificationPreferencesScreen` | `/profile/notifications`, `/seller/profile/notifications`, `/admin/profile/notifications` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage` | Mostly good | settings card language still makes toggles feel heavier than needed |
| `SellerOnboardingScreen` | `/seller/onboarding` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip`, `QitakTimelineBlock` | Mostly good | full verification path is visible; still uses one scroll shell |
| `SellerApplicationStatusScreen` | `/seller/onboarding/status` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip`, `QitakTimelineBlock` | Good | one of the strongest surfaces in the app |
| `TransactionLifecycleScreen` | `/deals`, `/transactions` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakSignalStrip` | P1 | list is actionable but too abstract and context-light |
| `TransactionHistoryScreen` | `/transactions/history` | stateless | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakPullToRefresh`, `QitakSignalStrip` | Mostly good | timestamp label is fixed; fallback metadata can still be raw |
| `TransactionDetailScreen` | `/deals/:id` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakSignalStrip`, `QitakTimelineBlock`, `QitakListingSurface` | Mostly good | bottom action cluster can become a button pile |
| `TransactionIntentScreen` | `/transactions/listing/:id/new` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakSignalStrip` | P1 | semantically generic for a serious transaction start moment |
| `DisputeCreateScreen` | `/deals/:id/dispute` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Mostly good | evidence and reason flow is still form-heavy |
| `RatingScreen` | `/ratings/transaction/:id` | stateful | `QitakPanel`, `QitakSectionHeader`, `QitakPullToRefresh`, `QitakQueueRow`, `QitakSignalStrip`, `QitakListingSurface` | Mostly good | inherits global panel heaviness more than screen-specific slop |
| `AdminQueuesScreen` | `/admin/queues` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow` | Good | clean operational navigation |
| `SellerVerificationQueueScreen` | `/admin/verifications` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Good | none significant in this pass |
| `VerificationDetailScreen` | `/admin/verifications/:id` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Mostly good | dense detail zones still inherit panel heaviness |
| `ListingModerationQueueScreen` | `/admin/listings` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Good | none significant in this pass |
| `ListingReviewDetailScreen` | `/admin/listings/:id` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakListingSurface` | Mostly good | review sections remain visually equal-weight |
| `DisputesQueueScreen` | `/admin/disputes` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow` | Good | none significant in this pass |
| `DisputeDetailScreen` | `/admin/disputes/:id` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakSignalStrip` | Mostly good | stacked detail panels are heavier than needed |
| `ReportsQueueScreen` | `/admin/reports` | stateless | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow` | Good | report meta can get dense |
| `ReportDetailScreen` | `/admin/reports/:id` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakSignalStrip` | Mostly good | secondary information could compress further |
| `AdminTeamScreen` | `/admin/team` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow` | P1 | dense action cluster and semantically wrong detail action label |
| `ConversationOversightScreen` | `/admin/conversations/:id` | stateful | `QitakPanel`, `QitakStateMessage`, `QitakQueueRow`, `QitakSignalStrip` | Mostly good | metadata clusters still compete for attention |

## System-level consistency summary

- Strongest pattern family:
  - admin queues/details
  - seller status
  - account settings
  - trust-loop detail screens

- Weakest pattern family:
  - auth entry
  - discovery home
  - long seller forms
  - notification feed

- Cross-app slop sources:
  - remaining detail/admin surfaces can still stack too many equal-weight sections
  - transaction start and lifecycle screens are still semantically under-expressive
  - some key screens are operationally correct but semantically under-expressive
