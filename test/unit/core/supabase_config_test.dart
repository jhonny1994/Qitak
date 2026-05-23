import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';

void main() {
  group('AppSupabaseConfig.isConfigured', () {
    test('both fields empty → false', () {
      const config = AppSupabaseConfig(url: '', anonKey: '');
      expect(config.isConfigured, isFalse);
    });

    test('both fields set → true', () {
      const config = AppSupabaseConfig(
        url: 'https://abc.supabase.co',
        anonKey: 'key',
      );
      expect(config.isConfigured, isTrue);
    });
  });

  group('AppSupabaseConfig.runtimeUrl', () {
    test('production URL is returned unchanged on any platform', () {
      const config = AppSupabaseConfig(
        url: 'https://xyz.supabase.co',
        anonKey: 'key',
      );
      expect(config.runtimeUrl, 'https://xyz.supabase.co');
    });

    test('localhost is rewritten to 10.0.2.2 on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const config = AppSupabaseConfig(
        url: 'http://localhost:54321',
        anonKey: 'key',
      );
      expect(config.runtimeUrl, 'http://10.0.2.2:54321');
    });

    test('localhost is NOT rewritten on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const config = AppSupabaseConfig(
        url: 'http://localhost:54321',
        anonKey: 'key',
      );
      expect(config.runtimeUrl, 'http://localhost:54321');
    });
  });

  group('AppSupabaseConfig.persistSessionKey', () {
    test('extracts subdomain from Supabase URL', () {
      const config = AppSupabaseConfig(
        url: 'https://abcdef.supabase.co',
        anonKey: 'key',
      );
      expect(config.persistSessionKey, 'sb-abcdef-auth-token');
    });
  });

  group('supabaseClientProvider', () {
    test('returns null when config is not configured', () {
      final container = ProviderContainer(
        overrides: [
          appSupabaseConfigProvider.overrideWithValue(
            const AppSupabaseConfig(url: '', anonKey: ''),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(supabaseClientProvider), isNull);
    });
  });
}
