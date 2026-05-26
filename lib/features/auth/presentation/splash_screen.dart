import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_entry_service.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/presentation/auth_resolution_error_view.dart';
import 'package:qitak_app/features/auth/providers/auth_resolution_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _service = AuthEntryService();

  ProviderSubscription<AsyncValue<AuthSessionState>>? _resolutionSubscription;
  ProviderSubscription<AppPreferencesState>? _preferencesSubscription;
  var _navigated = false;

  @override
  void initState() {
    super.initState();

    _resolutionSubscription = ref.listenManual<AsyncValue<AuthSessionState>>(
      authResolutionProvider,
      (_, _) => unawaited(_attemptNavigate()),
    );
    _preferencesSubscription = ref.listenManual<AppPreferencesState>(
      appPreferencesProvider,
      (_, _) => unawaited(_attemptNavigate()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(authResolutionProvider.notifier).resolve());
      unawaited(_attemptNavigate());
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolution = ref.watch(authResolutionProvider);

    return resolution.when(
      loading: () => Center(
        child: QitakPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/brand/qitak-logo.png', width: 220),
              const SizedBox(height: 24),
              Text(
                context.l10n.splashSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => const AuthResolutionErrorView(),
      data: (_) => Center(child: Text(context.l10n.loading)),
    );
  }

  Future<void> _attemptNavigate() async {
    if (!mounted || _navigated) return;

    final preferences = ref.read(appPreferencesProvider);
    final resolution = ref.read(authResolutionProvider);
    if (!preferences.isLoaded || resolution.isLoading || !resolution.hasValue) {
      return;
    }

    final route = await _resolveRoute(
      resolution.value!,
      preferences,
      _service,
    );
    if (!mounted || _navigated) return;

    _navigated = true;
    GoRouter.of(context).go(route);
  }

  Future<String> _resolveRoute(
    AuthSessionState session,
    AppPreferencesState preferences,
    AuthEntryService service,
  ) async {
    if (session.isAuthenticated && session.profile != null) {
      final profile = session.profile!;
      var approved = false;
      if (profile.role == AccountRole.seller) {
        try {
          approved =
              (await ref
                      .read(sellerApplicationRepositoryProvider)
                      .fetchCurrentForUser(profile.id))
                  ?.isApproved ==
              true;
        } on Object {
          approved = false;
        }
      }
      // If the app was launched by tapping a notification from the terminated
      // state, honour that intent — provided the authenticated user has access.
      final pendingNotificationRoute = ref.read(
        initialNotificationRouteProvider,
      );
      if (pendingNotificationRoute != null) {
        final canAccess = _service.canAccessRoleRoute(
          profile.role,
          pendingNotificationRoute,
          isSellerApproved: approved,
        );
        if (canAccess) {
          return pendingNotificationRoute;
        }
      }

      return service.resolveLandingRoute(
        profile,
        isSellerApproved: approved,
      );
    }

    final route = preferences.guestBrowsingEnabled
        ? '/home'
        : preferences.hasSeenOnboarding
        ? '/guest/account'
        : '/intro/1';
    if (kDebugMode) {
      debugPrint(
        '[QitakDebug][splash] unauthDecision '
        'guest=${preferences.guestBrowsingEnabled} '
        'seen=${preferences.hasSeenOnboarding} '
        'route=$route',
      );
    }
    return route;
  }

  @override
  void dispose() {
    _resolutionSubscription?.close();
    _preferencesSubscription?.close();
    super.dispose();
  }
}
