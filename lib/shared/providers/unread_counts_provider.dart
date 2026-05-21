import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';

typedef UnreadCounts = ({int messages, int notifications});

class UnreadCountsNotifier extends AsyncNotifier<UnreadCounts> {
  @override
  Future<UnreadCounts> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<UnreadCounts> _load() async {
    final userId = ref.watch(authSessionProvider).profile?.id;
    if (userId == null) {
      return (messages: 0, notifications: 0);
    }

    final results = await Future.wait<int>([
      ref.read(messagingRepositoryProvider).countUnreadMessages(userId),
      ref.read(notificationRepositoryProvider).countUnreadNotifications(),
    ]);

    return (messages: results[0], notifications: results[1]);
  }
}

final AsyncNotifierProvider<UnreadCountsNotifier, UnreadCounts>
unreadCountsProvider =
    AsyncNotifierProvider.autoDispose<UnreadCountsNotifier, UnreadCounts>(
      UnreadCountsNotifier.new,
    );
