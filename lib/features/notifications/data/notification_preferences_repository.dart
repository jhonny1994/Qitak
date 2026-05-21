import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.pushMessagesEnabled,
    required this.pushDealUpdatesEnabled,
    required this.pushSavedListingUpdatesEnabled,
    required this.emailAccountUpdatesEnabled,
    required this.emailDealUpdatesEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool pushMessagesEnabled;
  final bool pushDealUpdatesEnabled;
  final bool pushSavedListingUpdatesEnabled;
  final bool emailAccountUpdatesEnabled;
  final bool emailDealUpdatesEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
}

class NotificationPreferencesRepository {
  const NotificationPreferencesRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  Future<NotificationPreferences> fetch() async {
    final row = await _client
        .from('notification_preferences')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return _mapRow(row);
  }

  Future<void> save(NotificationPreferences value) async {
    await _client.from('notification_preferences').upsert(<String, dynamic>{
      'user_id': _userId,
      'push_messages_enabled': value.pushMessagesEnabled,
      'push_deal_updates_enabled': value.pushDealUpdatesEnabled,
      'push_saved_listing_updates_enabled':
          value.pushSavedListingUpdatesEnabled,
      'email_account_updates_enabled': value.emailAccountUpdatesEnabled,
      'email_deal_updates_enabled': value.emailDealUpdatesEnabled,
      'quiet_hours_start': value.quietHoursStart,
      'quiet_hours_end': value.quietHoursEnd,
    });
  }

  NotificationPreferences _mapRow(Map<String, dynamic>? row) {
    return NotificationPreferences(
      pushMessagesEnabled: row?['push_messages_enabled'] as bool? ?? true,
      pushDealUpdatesEnabled:
          row?['push_deal_updates_enabled'] as bool? ?? true,
      pushSavedListingUpdatesEnabled:
          row?['push_saved_listing_updates_enabled'] as bool? ?? true,
      emailAccountUpdatesEnabled:
          row?['email_account_updates_enabled'] as bool? ?? true,
      emailDealUpdatesEnabled:
          row?['email_deal_updates_enabled'] as bool? ?? true,
      quietHoursStart: row?['quiet_hours_start'] as String?,
      quietHoursEnd: row?['quiet_hours_end'] as String?,
    );
  }
}

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      final userId = ref.watch(authSessionProvider).profile?.id;
      if (client == null || userId == null) {
        throw StateError(
          'Supabase client and authenticated user are required for notification preferences.',
        );
      }
      return NotificationPreferencesRepository(client, userId);
    });

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) {
    return ref.read(notificationPreferencesRepositoryProvider).fetch();
  },
);
