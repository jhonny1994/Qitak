import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SecureStorageService {
  Future<void> writeRefreshToken(String token);
  Future<String?> readRefreshToken();
  Future<void> deleteRefreshToken();
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs);
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return FlutterSecureStorageService();
});

abstract interface class SecureKeyValueStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService({SecureKeyValueStore? store})
    : _store = store ?? FlutterSecureKeyValueStore();

  static const String refreshTokenKey = 'supabase_refresh_token';

  final SecureKeyValueStore _store;

  @override
  Future<void> writeRefreshToken(String token) {
    return _store.write(refreshTokenKey, token);
  }

  @override
  Future<String?> readRefreshToken() {
    return _store.read(refreshTokenKey);
  }

  @override
  Future<void> deleteRefreshToken() {
    return _store.delete(refreshTokenKey);
  }

  @override
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs) async {
    final token = prefs.getString(refreshTokenKey);
    if (token == null || token.isEmpty) {
      return;
    }

    await writeRefreshToken(token);
    await prefs.remove(refreshTokenKey);
  }
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const AndroidOptions _androidOptions = AndroidOptions.defaultOptions;
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) {
    return _storage.write(
      key: key,
      value: value,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<String?> read(String key) {
    return _storage.read(
      key: key,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(
      key: key,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }
}

class SecureSessionLocalStorage extends LocalStorage {
  SecureSessionLocalStorage({
    required this.persistSessionKey,
    SecureKeyValueStore? store,
    SharedPreferences? sharedPreferences,
  }) : _store = store ?? FlutterSecureKeyValueStore(),
       _sharedPreferences = sharedPreferences;

  final String persistSessionKey;
  final SecureKeyValueStore _store;
  final SharedPreferences? _sharedPreferences;

  late final SharedPreferences _prefs;

  @override
  Future<void> initialize() async {
    _prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    final secureValue = await _store.read(persistSessionKey);
    final legacyValue = _prefs.getString(persistSessionKey);
    if ((secureValue == null || secureValue.isEmpty) &&
        legacyValue != null &&
        legacyValue.isNotEmpty) {
      await _store.write(persistSessionKey, legacyValue);
      await _prefs.remove(persistSessionKey);
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    final value = await _store.read(persistSessionKey);
    return value != null && value.isNotEmpty;
  }

  @override
  Future<String?> accessToken() {
    return _store.read(persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() {
    return _store.delete(persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _store.write(persistSessionKey, persistSessionString);
  }
}
