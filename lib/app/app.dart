import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/core/deep_links/app_links_prompt_service.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/notifications/providers/notification_provider.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';
import 'package:qitak_app/shared/widgets/offline_banner.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class QitakApp extends ConsumerWidget {
  const QitakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final config = ref.watch(appSupabaseConfigProvider);
    if (!config.isConfigured) {
      return MaterialApp(
        title: kAppBrandName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: preferences.themeMode,
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: QitakStateMessage(
                title: S.current.appConfigurationRequiredTitle,
                message: S.current.appConfigurationRequiredBody,
              ),
            ),
          ),
        ),
      );
    }

    final router = ref.watch(goRouterProvider);
    final session = ref.watch(authSessionProvider);
    final rawLocale = session.profile?.language ?? preferences.guestLanguage;
    final supportedLanguageCodes = S.delegate.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    final localeCode = supportedLanguageCodes.contains(rawLocale)
        ? rawLocale
        : S.delegate.supportedLocales.first.languageCode;
    final appLocale = Locale(localeCode);

    return MaterialApp.router(
      title: kAppBrandName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale: appLocale),
      darkTheme: AppTheme.dark(locale: appLocale),
      themeMode: preferences.themeMode,
      routerConfig: router,
      builder: (context, child) => _NotificationRuntimeBindings(
        router: router,
        dialogContextProvider: () => appRootNavigatorKey.currentContext,
        child: OfflineBanner(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      locale: appLocale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class _NotificationRuntimeBindings extends ConsumerStatefulWidget {
  const _NotificationRuntimeBindings({
    required this.router,
    required this.dialogContextProvider,
    required this.child,
  });

  final GoRouter router;
  final BuildContext? Function() dialogContextProvider;
  final Widget child;

  @override
  ConsumerState<_NotificationRuntimeBindings> createState() =>
      _NotificationRuntimeBindingsState();
}

class _NotificationRuntimeBindingsState
    extends ConsumerState<_NotificationRuntimeBindings>
    with WidgetsBindingObserver {
  ProviderSubscription<AuthSessionState>? _authSessionSubscription;
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSessionSubscription = ref.listenManual<AuthSessionState>(
      authSessionProvider,
      (previous, next) {
        final previousUserId = previous?.profile?.id;
        final nextUserId = next.profile?.id;
        if (previousUserId == nextUserId) {
          return;
        }
        ref.invalidate(unreadCountsProvider);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _bindNotificationRuntime();
      unawaited(_maybeShowAppLinksPrompt());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    ref.invalidate(unreadCountsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _bindNotificationRuntime() {
    final notificationService = ref.read(notificationServiceProvider)
      ..bindRouter(widget.router);
    _notificationService = notificationService;
    ref
      ..read(foregroundNotificationSubscriptionProvider)
      ..read(notificationTokenRefreshSubscriptionProvider)
      ..invalidate(unreadCountsProvider);
    final preferences = ref.read(appPreferencesProvider);
    if (preferences.isLoaded && preferences.hasSeenOnboarding) {
      unawaited(notificationService.handleInitialMessage());
    }
  }

  Future<void> _maybeShowAppLinksPrompt() async {
    final preferences = ref.read(appPreferencesProvider);

    // Chain of command: onboarding owns the first-run user experience.
    // Global runtime prompts may initialize at boot, but they must not
    // display UI until onboarding has been completed.
    if (!preferences.isLoaded || !preferences.hasSeenOnboarding) {
      return;
    }

    final shouldPrompt = await AppLinksPromptService.shouldPrompt();
    if (!shouldPrompt || !mounted) return;

    final dialogContext = widget.dialogContextProvider();
    if (dialogContext == null || !dialogContext.mounted) return;

    await AppLinksPromptService.markPrompted();
    if (!mounted || !dialogContext.mounted) return;

    await showDialog<void>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.appLinksPromptTitle),
        content: Text(ctx.l10n.appLinksPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.appLinksPromptDismiss),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppLinksPromptService.openSettings().ignore();
            },
            child: Text(ctx.l10n.appLinksPromptAction),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSessionSubscription?.close();
    _notificationService?.dispose();
    super.dispose();
  }
}
