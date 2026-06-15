import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets(
    'unread counts keep message and account badge ownership separate',
    (
      tester,
    ) async {
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(body: SizedBox.shrink()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
        messagingRepositoryOverride: _UnreadMessagingRepository(),
        notificationRepositoryOverride: _UnreadNotificationRepository(),
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );
      await container.read(authSessionProvider.notifier).restore();
      final counts = await container.read(unreadCountsProvider.future);

      expect(counts.messages, 2);
      expect(counts.notifications, 1);
    },
  );
}

class _UnreadMessagingRepository implements MessagingRepository {
  @override
  bool get isLocal => false;

  @override
  Future<int> countUnreadMessages(String userId) async => 2;

  @override
  Future<String> ensureThread({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
  }) async => 'thread-1';

  @override
  Future<List<ConversationMessage>> listMessages({
    required String threadId,
    required String userId,
  }) async => const <ConversationMessage>[];

  @override
  Future<List<ConversationMessage>> listMessagesAfter({
    required String threadId,
    required String userId,
    required DateTime after,
  }) async => const <ConversationMessage>[];

  @override
  Future<List<ConversationThreadSummary>> listThreadsForUser(
    String userId,
  ) async => const <ConversationThreadSummary>[];

  @override
  Future<void> markAllMessagesRead(String userId) async {}

  @override
  Future<void> markThreadMessagesRead({
    required String threadId,
    required String userId,
  }) async {}

  @override
  Future<void> removeChannel(RealtimeChannel channel) async {}

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {}

  @override
  List<RealtimeChannel> subscribeToConversationListChanges({
    required String userId,
    required void Function() onChange,
    required void Function(Object error) onError,
  }) => const <RealtimeChannel>[];

  @override
  RealtimeChannel? subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) => null;
}

class _UnreadNotificationRepository extends NotificationRepository {
  _UnreadNotificationRepository() : super(client: null, currentUserId: null);

  @override
  Future<int> countUnreadNotifications() async => 1;
}
