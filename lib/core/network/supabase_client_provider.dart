import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/config/app_runtime_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabaseConfig {
  const AppSupabaseConfig({
    required this.url,
    required this.publishableKey,
  });

  factory AppSupabaseConfig.fromEnvironment() {
    const envUrl = String.fromEnvironment(AppRuntimeConfig.supabaseUrlEnvVar);
    const envPublishableKey = String.fromEnvironment(
      AppRuntimeConfig.supabasePublishableKeyEnvVar,
    );
    if (envUrl.isNotEmpty && envPublishableKey.isNotEmpty) {
      return const AppSupabaseConfig(
        url: envUrl,
        publishableKey: envPublishableKey,
      );
    }

    return const AppSupabaseConfig(url: '', publishableKey: '');
  }

  final String url;
  final String publishableKey;

  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  String get runtimeUrl => AppRuntimeConfig.normalizeRuntimeUrl(url);

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
