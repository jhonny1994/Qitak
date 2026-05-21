import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef AppRunner = FutureOr<void> Function();

class SentryConfig {
  SentryConfig._();

  static const String _dsn = String.fromEnvironment('SENTRY_DSN');
  static const String _release = String.fromEnvironment('SENTRY_RELEASE');

  static bool get isConfigured => _dsn.trim().isNotEmpty;

  static Future<void> init(AppRunner runner) async {
    if (!isConfigured) {
      await runner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options
          ..dsn = _dsn
          ..release = _release.isEmpty ? null : _release
          ..environment = kDebugMode ? 'debug' : 'production'
          ..tracesSampleRate = kDebugMode ? 0.0 : 0.2
          ..sendDefaultPii = false
          ..attachScreenshot = false
          // ignore: experimental_member_use, required to explicitly disable view hierarchy capture.
          ..attachViewHierarchy = false
          ..maxBreadcrumbs = 50;
      },
      appRunner: runner,
    );
  }

  static void setUserContext(String role) {
    if (!isConfigured) {
      return;
    }

    unawaited(
      Future<void>(() async {
        await Sentry.configureScope((scope) async {
          await scope.setUser(
            SentryUser(data: <String, dynamic>{'role': role}),
          );
        });
      }),
    );
  }

  static void clearUserContext() {
    if (!isConfigured) {
      return;
    }

    unawaited(
      Future<void>(() async {
        await Sentry.configureScope((scope) async {
          await scope.setUser(null);
        });
      }),
    );
  }
}
