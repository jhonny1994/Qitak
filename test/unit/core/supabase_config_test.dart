import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/config/app_runtime_config.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';

void main() {
  group('AppSupabaseConfig.isConfigured', () {
    test('both fields empty → false', () {
      const config = AppSupabaseConfig(url: '', publishableKey: '');
      expect(config.isConfigured, isFalse);
    });

    test('both fields set → true', () {
      const config = AppSupabaseConfig(
        url: 'https://abc.supabase.co',
        publishableKey: 'key',
      );
      expect(config.isConfigured, isTrue);
    });
  });

  group('AppRuntimeConfig.normalizeRuntimeUrl', () {
    test('returns empty url unchanged', () {
      expect(AppRuntimeConfig.normalizeRuntimeUrl(''), '');
    });

    test('returns malformed url unchanged', () {
      expect(
        AppRuntimeConfig.normalizeRuntimeUrl('not a valid uri'),
        'not a valid uri',
      );
    });

    test('127.0.0.1 is rewritten to emulator loopback on Android', () {
      expect(
        AppRuntimeConfig.normalizeRuntimeUrl(
          'http://127.0.0.1:54321',
          platform: TargetPlatform.android,
          isWeb: false,
        ),
        'http://10.0.2.2:54321',
      );
    });
  });

  group('AppSupabaseConfig.runtimeUrl', () {
    test('production URL is returned unchanged on any platform', () {
      const config = AppSupabaseConfig(
        url: 'https://xyz.supabase.co',
        publishableKey: 'key',
      );
      expect(config.runtimeUrl, 'https://xyz.supabase.co');
    });

    test('localhost is rewritten to 10.0.2.2 on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const config = AppSupabaseConfig(
        url: 'http://localhost:54321',
        publishableKey: 'key',
      );
      expect(config.runtimeUrl, 'http://10.0.2.2:54321');
    });

    test('localhost is NOT rewritten on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const config = AppSupabaseConfig(
        url: 'http://localhost:54321',
        publishableKey: 'key',
      );
      expect(config.runtimeUrl, 'http://localhost:54321');
    });
  });

  group('AppSupabaseConfig.persistSessionKey', () {
    test('extracts subdomain from Supabase URL', () {
      const config = AppSupabaseConfig(
        url: 'https://abcdef.supabase.co',
        publishableKey: 'key',
      );
      expect(config.persistSessionKey, 'sb-abcdef-auth-token');
    });
  });

  group('supabaseClientProvider', () {
    test('returns null when config is not configured', () {
      final container = ProviderContainer(
        overrides: [
          appSupabaseConfigProvider.overrideWithValue(
            const AppSupabaseConfig(url: '', publishableKey: ''),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(supabaseClientProvider), isNull);
    });
  });
}
