import 'package:flutter/foundation.dart';

/// Centralizes runtime and build-time app configuration defaults.
final class AppRuntimeConfig {
  const AppRuntimeConfig._();

  static const String supabaseUrlEnvVar = 'SUPABASE_URL';
  static const String supabasePublishableKeyEnvVar = 'SUPABASE_PUBLISHABLE_KEY';

  /// Android emulators access host-loopback services through 10.0.2.2.
  static const String androidEmulatorLoopbackHost = '10.0.2.2';

  static String normalizeRuntimeUrl(
    String url, {
    TargetPlatform? platform,
    bool isWeb = kIsWeb,
  }) {
    if (url.isEmpty || isWeb) {
      return url;
    }

    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return url;
    }

    final host = parsed.host.toLowerCase();
    final activePlatform = platform ?? defaultTargetPlatform;
    final shouldUseEmulatorLoopback =
        activePlatform == TargetPlatform.android &&
        (host == '127.0.0.1' || host == 'localhost');
    if (!shouldUseEmulatorLoopback) {
      return url;
    }

    return parsed.replace(host: androidEmulatorLoopbackHost).toString();
  }
}
