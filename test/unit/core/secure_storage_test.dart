import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/storage/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _InMemorySecureKeyValueStore store;
  late FlutterSecureStorageService service;

  setUp(() {
    store = _InMemorySecureKeyValueStore();
    service = FlutterSecureStorageService(store: store);
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
    'migrateFromSharedPreferences moves refresh token to secure storage',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        FlutterSecureStorageService.refreshTokenKey: 'legacy-token',
      });
      final prefs = await SharedPreferences.getInstance();

      await service.migrateFromSharedPreferences(prefs);

      expect(
        await service.readRefreshToken(),
        'legacy-token',
      );
      expect(
        prefs.getString(FlutterSecureStorageService.refreshTokenKey),
        isNull,
      );
    },
  );

  test('write, read, and delete refresh token lifecycle works', () async {
    await service.writeRefreshToken('fresh-token');

    expect(await service.readRefreshToken(), 'fresh-token');

    await service.deleteRefreshToken();

    expect(await service.readRefreshToken(), isNull);
  });
}

class _InMemorySecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
