import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/features/notifications/data/device_token_repository.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';
import 'package:qitak_app/features/notifications/domain/app_notification.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';

class ForegroundNotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => const <AppNotification>[];

  void ingest(RemoteMessage message) {
    final next = _notificationFromMessage(message);
    state = [
      next,
      ...state.where((item) => item.id != next.id),
    ];
  }

  void markAllRead() {
    state = state
        .map((item) => _copyNotification(item, isUnread: false))
        .toList(growable: false);
  }

  void setReadState({
    required String notificationId,
    required bool isRead,
  }) {
    state = state
        .map(
          (item) => item.id == notificationId
              ? _copyNotification(item, isUnread: !isRead)
              : item,
        )
        .toList(growable: false);
  }
}

final foregroundNotificationsProvider =
    NotifierProvider<ForegroundNotificationsNotifier, List<AppNotification>>(
      ForegroundNotificationsNotifier.new,
    );

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final stored = await ref
      .watch(notificationRepositoryProvider)
      .listNotifications();
  final foreground = ref.watch(foregroundNotificationsProvider);
  return [
    ...foreground,
    ...stored.where(
      (item) =>
          foreground.every((foregroundItem) => foregroundItem.id != item.id),
    ),
  ];
});

final foregroundNotificationSubscriptionProvider = Provider<void>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final subscription = notificationService.onMessage.listen((message) async {
    ref.read(foregroundNotificationsProvider.notifier).ingest(message);
    await ref.read(unreadCountsProvider.notifier).refresh();
  });
  ref.onDispose(subscription.cancel);
});

final notificationTokenRefreshSubscriptionProvider = Provider<void>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return;
  }
  final repository = DeviceTokenRepository(client);
  final subscription = notificationService.onTokenRefresh.listen((token) async {
    final platform = notificationService.currentPlatform;
    if (token.isEmpty || platform == null) {
      return;
    }
    try {
      await repository.register(token: token, platform: platform);
    } on Object {
      // Token refresh should not interrupt the app flow.
    }
  });
  ref.onDispose(subscription.cancel);
});

AppNotification _notificationFromMessage(RemoteMessage message) {
  final data = Map<String, dynamic>.from(message.data);
  return AppNotification(
    id:
        data['notification_id'] as String? ??
        message.messageId ??
        'push-${DateTime.now().microsecondsSinceEpoch}',
    type: data['type'] as String? ?? 'system_notice',
    deepLink: data['deep_link'] as String? ?? '/notifications',
    title: message.notification?.title ?? data['title'] as String? ?? '',
    body: message.notification?.body ?? data['body'] as String? ?? '',
    data: data,
    createdAt: DateTime.now(),
    isUnread: true,
  );
}

AppNotification _copyNotification(
  AppNotification source, {
  bool? isUnread,
}) {
  return AppNotification(
    id: source.id,
    type: source.type,
    deepLink: source.deepLink,
    title: source.title,
    body: source.body,
    timestampLabel: source.timestampLabel,
    categoryLabel: source.categoryLabel,
    data: source.data,
    createdAt: source.createdAt,
    isUnread: isUnread ?? source.isUnread,
  );
}
