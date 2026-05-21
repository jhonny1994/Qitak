import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/notifications/domain/app_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  const NotificationRepository({
    required this.client,
    required this.currentUserId,
  });

  final SupabaseClient? client;
  final String? currentUserId;

  Future<List<AppNotification>> listNotifications() async {
    final resolvedClient = client;
    final resolvedUserId = currentUserId;
    if (resolvedClient == null || resolvedUserId == null) {
      return const <AppNotification>[];
    }
    final rows = await resolvedClient
        .from('notifications')
        .select('id, type, data, is_read, created_at')
        .eq('user_id', resolvedUserId)
        .order('created_at', ascending: false);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapRow)
        .toList(growable: false);
  }

  Future<int> countUnreadNotifications() async {
    final resolvedClient = client;
    final resolvedUserId = currentUserId;
    if (resolvedClient == null || resolvedUserId == null) {
      return 0;
    }
    final rows = await resolvedClient
        .from('notifications')
        .select('id')
        .eq('user_id', resolvedUserId)
        .eq('is_read', false);
    return rows.length;
  }

  Future<void> markAllRead() {
    final resolvedClient = client;
    if (resolvedClient == null) {
      return Future<void>.value();
    }
    return resolvedClient.rpc<dynamic>('mark_notification_read');
  }

  Future<void> markNotificationState({
    required String notificationId,
    required bool isRead,
  }) {
    final resolvedClient = client;
    if (resolvedClient == null) {
      return Future<void>.value();
    }
    return resolvedClient.rpc<dynamic>(
      'mark_notification_state',
      params: <String, dynamic>{
        'p_notification_id': notificationId,
        'p_is_read': isRead,
      },
    );
  }

  AppNotification _mapRow(Map<String, dynamic> row) {
    final data =
        (row['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AppNotification(
      id: row['id'] as String,
      type: row['type'] as String? ?? 'system_notice',
      deepLink: data['deep_link'] as String? ?? '/notifications',
      data: data,
      createdAt: DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal(),
      isUnread: !(row['is_read'] as bool? ?? false),
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(authSessionProvider).profile?.id;
  if (client == null || userId == null) {
    throw StateError(
      'Supabase client and authenticated user are required for notifications.',
    );
  }
  return NotificationRepository(
    client: client,
    currentUserId: userId,
  );
});

class LocalNotificationRepository extends NotificationRepository {
  const LocalNotificationRepository()
    : super(client: null, currentUserId: null);

  @override
  Future<List<AppNotification>> listNotifications() async {
    return const <AppNotification>[];
  }

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markNotificationState({
    required String notificationId,
    required bool isRead,
  }) async {}

  @override
  Future<int> countUnreadNotifications() async => 0;
}
