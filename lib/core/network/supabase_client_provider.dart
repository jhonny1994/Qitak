import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabaseConfig {
  const AppSupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory AppSupabaseConfig.fromEnvironment() {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envUrl.isNotEmpty && envAnonKey.isNotEmpty) {
      return const AppSupabaseConfig(url: envUrl, anonKey: envAnonKey);
    }

    return const AppSupabaseConfig(url: '', anonKey: '');
  }

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  String get runtimeUrl {
    if (!isConfigured || kIsWeb) {
      return url;
    }

    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return url;
    }

    final host = parsed.host.toLowerCase();
    final shouldUseEmulatorLoopback =
        defaultTargetPlatform == TargetPlatform.android &&
        (host == '127.0.0.1' || host == 'localhost');
    if (!shouldUseEmulatorLoopback) {
      return url;
    }

    return parsed.replace(host: '10.0.2.2').toString();
  }

  String get persistSessionKey =>
      'sb-${Uri.parse(url).host.split('.').first}-auth-token';
}

final appSupabaseConfigProvider = Provider<AppSupabaseConfig>((ref) {
  return AppSupabaseConfig.fromEnvironment();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden at bootstrap.');
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final config = ref.watch(appSupabaseConfigProvider);
  if (!config.isConfigured) {
    return null;
  }
  return Supabase.instance.client;
});
