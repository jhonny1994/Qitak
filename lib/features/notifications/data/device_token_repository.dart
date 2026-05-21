import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/features/notifications/data/device_token_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenRepository {
  const DeviceTokenRepository(this._client);

  final SupabaseClient _client;

  Future<DeviceTokenModel> register({
    required String token,
    required DevicePlatform platform,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'Authenticated user required for device token registration.',
      );
    }

    final row = await _client
        .from('device_tokens')
        .upsert(
          <String, dynamic>{
            'user_id': user.id,
            'token': token,
            'platform': platform.name,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,platform',
        )
        .select()
        .single();

    return DeviceTokenModel.fromJson(row);
  }

  Future<void> deleteForCurrentPlatform(DevicePlatform platform) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client
        .from('device_tokens')
        .delete()
        .eq('user_id', user.id)
        .eq('platform', platform.name);
  }
}

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for device tokens.');
  }
  return DeviceTokenRepository(client);
});
