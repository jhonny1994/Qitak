import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(authResolutionProvider.notifier).resolve());
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolution = ref.watch(authResolutionProvider);
    final preferences = ref.watch(appPreferencesProvider);
    const service = AuthEntryService();

    if (preferences.isLoaded && resolution.hasValue) {
      final session = resolution.value!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        final router = GoRouter.of(context);
        final route = await _resolveRoute(session, preferences, service);
        if (mounted) {
          router.go(route);
        }
      });
    }

    ref.listen<AsyncValue<AuthSessionState>>(authResolutionProvider, (_, next) {
      next.whenData((session) async {
        if (!preferences.isLoaded) {
          return;
        }
        final router = GoRouter.of(context);
        final route = await _resolveRoute(session, preferences, service);
        if (context.mounted) {
          router.go(route);
        }
      });
    });

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
      return service.resolveLandingRoute(
        profile,
        isSellerApproved: approved,
      );
    }
    return preferences.guestBrowsingEnabled
        ? '/home'
        : preferences.hasSeenOnboarding
        ? '/guest/account'
        : '/intro/1';
  }
}
