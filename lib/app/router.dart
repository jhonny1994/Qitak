import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/presentation/admin_queues_screen.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/admin/presentation/conversation_oversight_screen.dart';
import 'package:qitak_app/features/admin/presentation/dispute_detail_screen.dart';
import 'package:qitak_app/features/admin/presentation/disputes_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/listing_moderation_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/listing_review_detail_screen.dart';
import 'package:qitak_app/features/admin/presentation/report_detail_screen.dart';
import 'package:qitak_app/features/admin/presentation/reports_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/seller_verification_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/verification_detail_screen.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/account_settings_screen.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/presentation/appearance_preferences_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/language_selection_screen.dart';
import 'package:qitak_app/features/auth/presentation/legal_information_screen.dart';
import 'package:qitak_app/features/auth/presentation/onboarding_screen.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/presentation/reset_password_screen.dart';
import 'package:qitak_app/features/auth/presentation/route_guards.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_up_screen.dart';
import 'package:qitak_app/features/auth/presentation/splash_screen.dart';
import 'package:qitak_app/features/auth/presentation/support_help_screen.dart';
import 'package:qitak_app/features/auth/presentation/unknown_route_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/discovery/presentation/search_screen.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/listings/presentation/saved_listings_screen.dart';
import 'package:qitak_app/features/listings/presentation/seller_listings_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';
import 'package:qitak_app/features/notifications/presentation/notification_center_screen.dart';
import 'package:qitak_app/features/notifications/presentation/notification_preferences_screen.dart';
import 'package:qitak_app/features/ratings/presentation/rating_screen.dart';
import 'package:qitak_app/features/release/presentation/cutover_rollback_screen.dart';
import 'package:qitak_app/features/release/presentation/launch_operations_screen.dart';
import 'package:qitak_app/features/release/presentation/release_observability_screen.dart';
import 'package:qitak_app/features/release/presentation/release_readiness_screen.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/features/seller/presentation/seller_onboarding_screen.dart';
import 'package:qitak_app/features/transactions/presentation/dispute_create_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_history_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_intent_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_lifecycle_screen.dart';
import 'package:qitak_app/shared/widgets/app_entry_shell.dart';
import 'package:qitak_app/shared/widgets/qitak_navigation_shell.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final appRootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = GoRouterRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    observers: [SentryNavigatorObserver()],
    redirect: (context, state) {
      final preferences = ref.read(appPreferencesProvider);
      final path = state.uri.path;
      final isSplash = path == '/';
      final isIntro = path.startsWith('/intro');
      if (preferences.isLoaded &&
          !preferences.hasSeenOnboarding &&
          !isSplash &&
          !isIntro) {
        return '/intro/1';
      }
      return null;
    },
    errorBuilder: (context, state) => AppEntryShell(
      child: UnknownRouteScreen(
        requestedPath: state.uri.toString(),
      ),
    ),
    routes: [
      // Splash (no shell)
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: const AppEntryShell(child: SplashScreen()),
        ),
      ),
      GoRoute(
        path: '/intro/:step',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: AppEntryShell(
            child: OnboardingScreen(
              step: int.tryParse(state.pathParameters['step'] ?? '1') ?? 1,
            ),
          ),
        ),
      ),

      // Auth routes (no bottom nav)
      GoRoute(
        path: '/auth/sign-in',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.signIn,
            fallbackPath: _publicAccountFallbackPath(state),
            child: SignInScreen(
              redirectPath: state.uri.queryParameters['redirect'],
              redirectArguments: state.uri.queryParameters['intentArgs'],
              redirectType: _intentTypeFromQuery(
                state.uri.queryParameters['intentType'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/sign-up',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.createAccount,
            fallbackPath: _publicAccountFallbackPath(state),
            child: SignUpScreen(
              redirectPath: state.uri.queryParameters['redirect'],
              redirectArguments: state.uri.queryParameters['intentArgs'],
              redirectType: _intentTypeFromQuery(
                state.uri.queryParameters['intentType'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/seller/sign-in',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.sellerSignIn,
            fallbackPath: '/guest/account',
            child: SignInScreen(
              variant: SignInVariant.seller,
              redirectPath: state.uri.queryParameters['redirect'],
              redirectArguments: state.uri.queryParameters['intentArgs'],
              redirectType: _intentTypeFromQuery(
                state.uri.queryParameters['intentType'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/seller/sign-up',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.sellerCreateAccount,
            fallbackPath: '/auth/seller/sign-in',
            child: SignUpScreen(
              variant: SignUpVariant.seller,
              redirectPath: state.uri.queryParameters['redirect'],
              redirectArguments: state.uri.queryParameters['intentArgs'],
              redirectType: _intentTypeFromQuery(
                state.uri.queryParameters['intentType'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/admin/sign-in',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.adminSignIn,
            fallbackPath: '/guest/account',
            child: SignInScreen(
              variant: SignInVariant.admin,
              redirectPath: state.uri.queryParameters['redirect'],
              redirectArguments: state.uri.queryParameters['intentArgs'],
              redirectType: _intentTypeFromQuery(
                state.uri.queryParameters['intentType'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/reset-password',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.resetPassword,
            fallbackPath: '/auth/sign-in',
            child: const ResetPasswordScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/language',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.languageSelectionTitle,
            fallbackPath: _authUtilityFallbackPath(
              ref.read(authSessionProvider),
              ref.read(appPreferencesProvider),
            ),
            child: const LanguageSelectionScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/appearance',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.appearanceSettingsTitle,
            fallbackPath: _authUtilityFallbackPath(
              ref.read(authSessionProvider),
              ref.read(appPreferencesProvider),
            ),
            child: const AppearancePreferencesScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/support',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.supportHelpTitle,
            fallbackPath: _authUtilityFallbackPath(
              ref.read(authSessionProvider),
              ref.read(appPreferencesProvider),
            ),
            child: const SupportHelpScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/auth/legal',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: _buildStandaloneUtilityShell(
            title: context.l10n.legalInformationTitle,
            fallbackPath: _authUtilityFallbackPath(
              ref.read(authSessionProvider),
              ref.read(appPreferencesProvider),
            ),
            child: const LegalInformationScreen(),
          ),
        ),
      ),

      // Section
      //
      // All main screens live inside a StatefulShellRoute that
      // provides persistent bottom navigation. The branches
      // map to the shell visibility matrix per actor role:
      //
      //   Guest:   Home | Account
      //   Buyer:   Home | Search | Saved | Messages | Account
      //   Seller:  Dashboard | Listings | Messages | Account
      //   Admin:   Dashboard | Queues | Reports | Account
      //   S.Admin: Dashboard | Queues | Reports | Team | Account
      //
      // The QitakNavigationShell widget reads the current
      // authSessionProvider to show role-appropriate destinations
      // and clamps the current index to valid bounds when the
      // role changes (e.g. after sign-in/sign-out).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            QitakNavigationShell(navigationShell: navigationShell),
        branches: [
          // Marketplace routes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: const HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'listing/:id',
                    pageBuilder: (context, state) => _buildTransitionPage(
                      state: state,
                      child: ListingDetailScreen(
                        listingId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/seller/home',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [AccountRole.seller],
                    intent: PostAuthRedirectIntent.route('/seller/home'),
                    requireApprovedSeller: true,
                    child: const SellerDashboardScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/seller/dashboard',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [AccountRole.seller],
                    intent: PostAuthRedirectIntent.route('/seller/dashboard'),
                    requireApprovedSeller: true,
                    child: const SellerDashboardScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/home',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/home'),
                    child: const AdminDashboardScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/dashboard',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/dashboard'),
                    child: const AdminDashboardScreen(),
                  ),
                ),
              ),
            ],
          ),

          // Seller routes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: SearchScreen(
                    initialQuery: state.uri.queryParameters['q'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: '/search/results',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: SearchScreen(
                    initialQuery: state.uri.queryParameters['q'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: '/seller/listings',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [AccountRole.seller],
                    intent: PostAuthRedirectIntent.route('/seller/listings'),
                    requireApprovedSeller: true,
                    child: const SellerListingsScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/queues',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/queues'),
                    child: const AdminQueuesScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/verifications',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route(
                      '/admin/verifications',
                    ),
                    child: const SellerVerificationQueueScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/listings',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/listings'),
                    child: const ListingModerationQueueScreen(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _buildTransitionPage(
                      state: state,
                      child: ProtectedRouteGuard(
                        requiredRoles: const [
                          AccountRole.admin,
                          AccountRole.superAdmin,
                        ],
                        intent: PostAuthRedirectIntent.route(
                          '/admin/listings/${state.pathParameters['id'] ?? ''}',
                        ),
                        child: ListingReviewDetailScreen(
                          listingId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/admin/disputes',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/disputes'),
                    child: const DisputesQueueScreen(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _buildTransitionPage(
                      state: state,
                      child: ProtectedRouteGuard(
                        requiredRoles: const [
                          AccountRole.admin,
                          AccountRole.superAdmin,
                        ],
                        intent: PostAuthRedirectIntent.route(
                          '/admin/disputes/${state.pathParameters['id'] ?? ''}',
                        ),
                        child: DisputeDetailScreen(
                          disputeId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Admin routes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [AccountRole.buyer],
                    intent: PostAuthRedirectIntent.route('/saved'),
                    child: const SavedListingsScreen(),
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/reports',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.admin,
                      AccountRole.superAdmin,
                    ],
                    intent: PostAuthRedirectIntent.route('/admin/reports'),
                    child: const ReportsQueueScreen(),
                  ),
                ),
              ),
            ],
          ),

          // Section
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [
                      AccountRole.buyer,
                      AccountRole.seller,
                    ],
                    intent: PostAuthRedirectIntent.route('/messages'),
                    child: const ConversationListScreen(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'thread/:id',
                    pageBuilder: (context, state) => _buildTransitionPage(
                      state: state,
                      child: ProtectedRouteGuard(
                        requiredRoles: const [
                          AccountRole.buyer,
                          AccountRole.seller,
                        ],
                        intent: PostAuthRedirectIntent.route(
                          '/messages/thread/${state.pathParameters['id'] ?? ''}',
                        ),
                        child: ConversationScreen(
                          threadId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _buildTransitionPage(
                      state: state,
                      child: ProtectedRouteGuard(
                        requiredRoles: const [
                          AccountRole.buyer,
                          AccountRole.seller,
                        ],
                        intent: PostAuthRedirectIntent.route(
                          '/messages/${state.pathParameters['id'] ?? ''}',
                        ),
                        child: ConversationScreen(
                          threadId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/admin/team',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: ProtectedRouteGuard(
                    requiredRoles: const [AccountRole.superAdmin],
                    intent: PostAuthRedirectIntent.route('/admin/team'),
                    child: const AdminTeamScreen(),
                  ),
                ),
              ),
            ],
          ),

          // Section
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/guest/account',
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: GuestAccountScreen(
                    redirectPath: state.uri.queryParameters['redirect'],
                    redirectArguments: state.uri.queryParameters['intentArgs'],
                    redirectType: _intentTypeFromQuery(
                      state.uri.queryParameters['intentType'],
                    ),
                  ),
                ),
              ),
              _buildProfileRoute(
                rootPath: '/profile',
                requiredRoles: const [AccountRole.buyer],
              ),
              _buildProfileRoute(
                rootPath: '/seller/profile',
                requiredRoles: const [AccountRole.seller],
              ),
              _buildProfileRoute(
                rootPath: '/admin/profile',
                requiredRoles: const [
                  AccountRole.admin,
                  AccountRole.superAdmin,
                ],
              ),
            ],
          ),
        ],
      ),

      // Section
      GoRoute(
        path: '/listing/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: AppEntryShell(
            child: ListingDetailScreen(
              listingId: state.pathParameters['id'] ?? '',
            ),
          ),
        ),
      ),

      // Section
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [
              AccountRole.buyer,
              AccountRole.seller,
              AccountRole.admin,
              AccountRole.superAdmin,
            ],
            intent: PostAuthRedirectIntent.route('/notifications'),
            child: _buildStandaloneUtilityShell(
              title: context.l10n.notificationsTitle,
              fallbackPath: _homePathForSession(ref.read(authSessionProvider)),
              child: const NotificationCenterScreen(),
            ),
          ),
        ),
      ),

      // Seller routes
      GoRoute(
        path: '/seller/onboarding',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/seller/onboarding'),
            child: _buildStandaloneUtilityShell(
              title: context.l10n.sellerOnboardingTitle,
              fallbackPath: _sellerApplicationFallbackPath(
                ref.read(authSessionProvider),
              ),
              child: const SellerOnboardingScreen(),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/seller/onboarding/status',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/seller/onboarding/status'),
            child: _buildStandaloneUtilityShell(
              title: context.l10n.sellerStatusTitle,
              fallbackPath: _sellerApplicationFallbackPath(
                ref.read(authSessionProvider),
              ),
              child: const SellerApplicationStatusScreen(),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/seller/listings/new',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/seller/listings/new'),
            requireApprovedSeller: true,
            child: const AppEntryShell(child: ListingFormScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/seller/listings/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.seller],
            intent: PostAuthRedirectIntent.route(
              '/seller/listings/${state.pathParameters['id'] ?? ''}',
            ),
            requireApprovedSeller: true,
            child: AppEntryShell(
              child: ListingDetailScreen(
                listingId: state.pathParameters['id'] ?? '',
                sellerOwnedPreview: true,
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/seller/listings/:id/edit',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.seller],
            intent: PostAuthRedirectIntent.route(
              '/seller/listings/${state.pathParameters['id'] ?? ''}/edit',
            ),
            requireApprovedSeller: true,
            child: AppEntryShell(
              child: ListingFormScreen(
                listingId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),

      // Section
      GoRoute(
        path: '/deals',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/deals'),
            child: const AppEntryShell(child: TransactionLifecycleScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/transactions',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/transactions'),
            child: const AppEntryShell(child: TransactionLifecycleScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/transactions/history',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route('/transactions/history'),
            child: const AppEntryShell(child: TransactionHistoryScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/deals/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route(
              '/deals/${state.pathParameters['id'] ?? ''}',
            ),
            child: AppEntryShell(
              child: TransactionDetailScreen(
                transactionId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/deals/:id/dispute',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route(
              '/deals/${state.pathParameters['id'] ?? ''}/dispute',
            ),
            child: AppEntryShell(
              child: DisputeCreateScreen(
                transactionId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/transactions/listing/:id/new',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer],
            intent: PostAuthRedirectIntent.route(
              '/transactions/listing/${state.pathParameters['id'] ?? ''}/new',
            ),
            child: AppEntryShell(
              child: TransactionIntentScreen(
                listingId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),

      // Admin routes
      GoRoute(
        path: '/admin/verifications/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route(
              '/admin/verifications/${state.pathParameters['id'] ?? ''}',
            ),
            child: AppEntryShell(
              child: VerificationDetailScreen(
                verificationId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/reports/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route(
              '/admin/reports/${state.pathParameters['id'] ?? ''}',
            ),
            child: AppEntryShell(
              child: ReportDetailScreen(
                reportId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/conversations/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route(
              '/admin/conversations/${state.pathParameters['id'] ?? ''}',
            ),
            child: AppEntryShell(
              child: ConversationOversightScreen(
                conversationId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),

      // Section
      GoRoute(
        path: '/release/readiness',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route('/release/readiness'),
            child: const AppEntryShell(child: ReleaseReadinessScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/release/operations',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route('/release/operations'),
            child: const AppEntryShell(child: LaunchOperationsScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/release/cutover',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route('/release/cutover'),
            child: const AppEntryShell(child: CutoverRollbackScreen()),
          ),
        ),
      ),
      GoRoute(
        path: '/release/observability',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.admin, AccountRole.superAdmin],
            intent: PostAuthRedirectIntent.route('/release/observability'),
            child: const AppEntryShell(child: ReleaseObservabilityScreen()),
          ),
        ),
      ),

      // Section
      GoRoute(
        path: '/ratings/transaction/:id',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: ProtectedRouteGuard(
            requiredRoles: const [AccountRole.buyer, AccountRole.seller],
            intent: PostAuthRedirectIntent.route(
              '/ratings/transaction/${state.pathParameters['id'] ?? ''}',
            ),
            child: AppEntryShell(
              child: RatingScreen(
                transactionId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ),
      ),
    ],
  );
});

IntentTargetType _intentTypeFromQuery(String? value) {
  return value == 'action' ? IntentTargetType.action : IntentTargetType.route;
}

String _homePathForSession(AuthSessionState session) {
  return session.profile?.role.route ?? '/home';
}

String _authUtilityFallbackPath(
  AuthSessionState session,
  AppPreferencesState preferences,
) {
  final profile = session.profile;
  if (profile != null) {
    switch (profile.role) {
      case AccountRole.seller:
        return '/seller/profile';
      case AccountRole.admin:
      case AccountRole.superAdmin:
        return '/admin/profile';
      case AccountRole.buyer:
      case AccountRole.anonymous:
        return '/profile';
    }
  }

  if (preferences.guestBrowsingEnabled) {
    return '/guest/account';
  }

  return '/guest/account';
}

String _sellerApplicationFallbackPath(AuthSessionState session) {
  final profile = session.profile;
  if (profile == null) {
    return '/guest/account';
  }
  return profile.role == AccountRole.seller ? '/seller/profile' : '/profile';
}

String _publicAccountFallbackPath(GoRouterState state) {
  final params = <String, String>{};
  final redirect = state.uri.queryParameters['redirect'];
  final intentType = state.uri.queryParameters['intentType'];
  final intentArgs = state.uri.queryParameters['intentArgs'];

  if (redirect != null && redirect.isNotEmpty) {
    params['redirect'] = redirect;
  }
  if (intentType != null && intentType.isNotEmpty) {
    params['intentType'] = intentType;
  }
  if (intentArgs != null && intentArgs.isNotEmpty) {
    params['intentArgs'] = intentArgs;
  }
  if (params.isEmpty) {
    return '/guest/account';
  }
  return '/guest/account?${Uri(queryParameters: params).query}';
}

CustomTransitionPage<void> _buildTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.018),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

Widget _buildStandaloneUtilityShell({
  required String title,
  required String fallbackPath,
  required Widget child,
}) {
  return AppEntryShell(
    child: LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: [
            _RouteWayfindingBar(
              title: title,
              fallbackPath: fallbackPath,
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBranchUtilityScreen({
  required String title,
  required String fallbackPath,
  required Widget child,
}) {
  return LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      height: constraints.maxHeight,
      child: Column(
        children: [
          _RouteWayfindingBar(
            title: title,
            fallbackPath: fallbackPath,
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

GoRoute _buildProfileRoute({
  required String rootPath,
  required List<AccountRole> requiredRoles,
}) {
  return GoRoute(
    path: rootPath,
    pageBuilder: (context, state) => _buildTransitionPage(
      state: state,
      child: ProtectedRouteGuard(
        requiredRoles: requiredRoles,
        intent: PostAuthRedirectIntent.route(rootPath),
        child: const ProfileScreen(),
      ),
    ),
    routes: _buildProfileUtilityRoutes(
      rootPath: rootPath,
      requiredRoles: requiredRoles,
    ),
  );
}

List<RouteBase> _buildProfileUtilityRoutes({
  required String rootPath,
  required List<AccountRole> requiredRoles,
}) {
  return [
    GoRoute(
      path: 'settings',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/settings'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.accountSettingsTitle,
            fallbackPath: rootPath,
            child: const AccountSettingsScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: 'language',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/language'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.languageSelectionTitle,
            fallbackPath: rootPath,
            child: const LanguageSelectionScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: 'appearance',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/appearance'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.appearanceSettingsTitle,
            fallbackPath: rootPath,
            child: const AppearancePreferencesScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: 'notifications',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/notifications'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.notificationPreferencesTitle,
            fallbackPath: rootPath,
            child: const NotificationPreferencesScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: 'support',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/support'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.supportHelpTitle,
            fallbackPath: rootPath,
            child: const SupportHelpScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: 'legal',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: ProtectedRouteGuard(
          requiredRoles: requiredRoles,
          intent: PostAuthRedirectIntent.route('$rootPath/legal'),
          child: _buildBranchUtilityScreen(
            title: context.l10n.legalInformationTitle,
            fallbackPath: rootPath,
            child: const LegalInformationScreen(),
          ),
        ),
      ),
    ),
  ];
}

class _RouteWayfindingBar extends StatelessWidget {
  const _RouteWayfindingBar({
    required this.title,
    required this.fallbackPath,
  });

  final String title;
  final String fallbackPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          color: colorScheme.onSurface,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(fallbackPath);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen<AuthSessionState>(
      authSessionProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref ref;
}
