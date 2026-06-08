import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('conversation list uses flat rows with unread emphasis', (
    tester,
  ) async {
    final repository = _RecordingConversationListRepository();
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationListScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      messagingRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationListScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversation-row')), findsWidgets);
  });

  testWidgets('shows empty state when no listing conversations exist', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationListScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Listing conversations'), findsOneWidget);
    expect(
      find.textContaining('No listing-anchored conversations yet'),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsNothing);
  });

  testWidgets('opening the inbox does not clear unread messages', (
    tester,
  ) async {
    final repository = _RecordingConversationListRepository();
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationListScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      messagingRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationListScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Alternator listing'), findsOneWidget);
    expect(repository.markAllMessagesReadCalls, 0);
    expect(repository.countUnreadMessagesCalls, greaterThanOrEqualTo(1));
  });
}

class _RecordingConversationListRepository implements MessagingRepository {
  int markAllMessagesReadCalls = 0;
  int countUnreadMessagesCalls = 0;

  @override
  bool get isLocal => false;

  @override
  Future<int> countUnreadMessages(String userId) async {
    countUnreadMessagesCalls += 1;
    return 2;
  }

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
  ) async => <ConversationThreadSummary>[
    ConversationThreadSummary(
      id: 'thread-1',
      listingId: 'listing-1',
      listingTitle: 'Alternator listing',
      lastMessageBody: 'Still available?',
      lastMessageAt: DateTime(2026, 6, 4, 10),
      lastSenderId: 'seller-1',
      otherPartyLabel: 'Seller One',
    ),
  ];

  @override
  Future<void> markAllMessagesRead(String userId) async {
    markAllMessagesReadCalls += 1;
  }

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
