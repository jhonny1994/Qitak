import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/core/observability/sentry_config.dart';
import 'package:qitak_app/core/storage/secure_storage_service.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (_supportsFirebaseRuntime) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

bool get _supportsFirebaseRuntime {
  if (kIsWeb) {
    return false;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService notificationService = const NoopNotificationService();
  if (_supportsFirebaseRuntime) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    notificationService = FirebaseNotificationService();
    await notificationService.initialize();
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!SentryConfig.isConfigured) {
      return;
    }
    unawaited(
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (!SentryConfig.isConfigured) {
      return false;
    }
    unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    return true;
  };

  await SentryConfig.init(() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final config = AppSupabaseConfig.fromEnvironment();
    final secureStorageService = FlutterSecureStorageService();

    if (config.isConfigured) {
      await secureStorageService.migrateFromSharedPreferences(
        sharedPreferences,
      );
      await Supabase.initialize(
        url: config.runtimeUrl,
        anonKey: config.anonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureSessionLocalStorage(
            persistSessionKey: config.persistSessionKey,
            sharedPreferences: sharedPreferences,
          ),
        ),
      );
    }

    runApp(
      ProviderScope(
        observers: const [_SentryAuthScopeObserver()],
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appSupabaseConfigProvider.overrideWithValue(config),
          secureStorageServiceProvider.overrideWithValue(secureStorageService),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const QitakApp(),
      ),
    );
  });
}

final class _SentryAuthScopeObserver extends ProviderObserver {
  const _SentryAuthScopeObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (context.provider != authSessionProvider || !SentryConfig.isConfigured) {
      return;
    }

    final next = newValue;
    if (next is! AuthSessionState) {
      return;
    }

    unawaited(() async {
      await Sentry.configureScope((scope) async {
        final userId = next.profile?.id;
        await scope.setUser(userId == null ? null : SentryUser(id: userId));
      });
    }());
  }
}
