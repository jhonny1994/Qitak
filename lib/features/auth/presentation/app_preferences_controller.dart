import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';

class AppPreferencesState {
  const AppPreferencesState({
    required this.themeMode,
    required this.guestLanguage,
    required this.guestBrowsingEnabled,
    required this.hasSeenOnboarding,
    required this.isLoaded,
  });

  const AppPreferencesState.initial()
    : themeMode = ThemeMode.system,
      guestLanguage = 'ar',
      guestBrowsingEnabled = false,
      hasSeenOnboarding = false,
      isLoaded = false;

  final ThemeMode themeMode;
  final String guestLanguage;
  final bool guestBrowsingEnabled;
  final bool hasSeenOnboarding;
  final bool isLoaded;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    String? guestLanguage,
    bool? guestBrowsingEnabled,
    bool? hasSeenOnboarding,
    bool? isLoaded,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      guestLanguage: guestLanguage ?? this.guestLanguage,
      guestBrowsingEnabled: guestBrowsingEnabled ?? this.guestBrowsingEnabled,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class AppPreferencesNotifier extends Notifier<AppPreferencesState> {
  static const _themeModeKey = 'qitak.ui.theme_mode';
  static const _guestLanguageKey = 'qitak.ui.guest_language';
  static const _guestBrowsingEnabledKey = 'qitak.ui.guest_browsing_enabled';
  static const _hasSeenOnboardingKey = 'qitak.ui.onboarding_seen';

  @override
  AppPreferencesState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return const AppPreferencesState.initial().copyWith(
      themeMode: _themeModeFromString(prefs.getString(_themeModeKey)),
      guestLanguage: prefs.getString(_guestLanguageKey) ?? 'ar',
      guestBrowsingEnabled: prefs.getBool(_guestBrowsingEnabledKey) ?? false,
      hasSeenOnboarding: prefs.getBool(_hasSeenOnboardingKey) ?? false,
      isLoaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeModeKey, _themeModeToString(themeMode));
    state = state.copyWith(themeMode: themeMode, isLoaded: true);
  }

  Future<void> setGuestLanguage(String languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_guestLanguageKey, languageCode);
    state = state.copyWith(guestLanguage: languageCode, isLoaded: true);
  }

  Future<void> setGuestBrowsingEnabled({required bool enabled}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_guestBrowsingEnabledKey, enabled);
    state = state.copyWith(
      guestBrowsingEnabled: enabled,
      isLoaded: true,
    );
  }

  Future<void> markOnboardingSeen() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_hasSeenOnboardingKey, true);
    state = state.copyWith(hasSeenOnboarding: true, isLoaded: true);
  }

  Future<void> resetOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_hasSeenOnboardingKey);
    state = state.copyWith(hasSeenOnboarding: false, isLoaded: true);
  }

  ThemeMode _themeModeFromString(String? rawValue) {
    switch (rawValue) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferencesState>(
      AppPreferencesNotifier.new,
    );
