import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('send button blocks duplicate sends while request is in flight', (
    tester,
  ) async {
    final repository = _RecordingMessagingRepository();
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationScreen(threadId: 'thread-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      messagingRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello seller');
    final sendButton = find.byKey(const Key('message-send-button'));
    await tester.tap(sendButton);
    await tester.pump();
    await tester.tap(sendButton);
    await tester.pump();

    expect(repository.sendCount, 1);

    repository.completePendingSend();
    await tester.pumpAndSettle();
  });

  testWidgets('successful send clears the input field', (tester) async {
    final repository = _RecordingMessagingRepository();
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationScreen(threadId: 'thread-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      messagingRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello seller');
    await tester.tap(find.byKey(const Key('message-send-button')));
    repository.completePendingSend();
    await tester.pumpAndSettle();

    expect(find.text('Hello seller'), findsNothing);
  });

  testWidgets('failed send keeps text and shows an error snackbar', (
    tester,
  ) async {
    final repository = _RecordingMessagingRepository(shouldThrow: true);
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationScreen(threadId: 'thread-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      messagingRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello seller');
    await tester.tap(find.byKey(const Key('message-send-button')));
    await tester.pumpAndSettle();

    expect(find.text('Hello seller'), findsOneWidget);
    expect(
      find.text("Message couldn't be sent. Please try again."),
      findsOneWidget,
    );
  });
}

class _RecordingMessagingRepository implements MessagingRepository {
  _RecordingMessagingRepository({this.shouldThrow = false});

  final bool shouldThrow;
  int sendCount = 0;
  Completer<void>? _pendingSend;

  @override
  bool get isLocal => true;

  void completePendingSend() {
    _pendingSend?.complete();
    _pendingSend = null;
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
  Future<List<ConversationThreadSummary>> listThreadsForUser(
    String userId,
  ) async => const <ConversationThreadSummary>[];

  @override
  Future<List<ConversationMessage>> listMessagesAfter({
    required String threadId,
    required String userId,
    required DateTime after,
  }) async => const <ConversationMessage>[];

  @override
  Future<int> countUnreadMessages(String userId) async => 0;

  @override
  Future<void> markThreadMessagesRead({
    required String threadId,
    required String userId,
  }) async {}

  @override
  Future<void> markAllMessagesRead(String userId) async {}

  @override
  List<RealtimeChannel> subscribeToConversationListChanges({
    required String userId,
    required void Function() onChange,
    required void Function(Object error) onError,
  }) => const <RealtimeChannel>[];

  @override
  RealtimeChannel subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) {
    throw UnsupportedError('Realtime is not used in this test.');
  }

  @override
  Future<void> removeChannel(RealtimeChannel channel) async {}

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {
    sendCount += 1;
    if (shouldThrow) {
      throw StateError('send failed');
    }
    _pendingSend = Completer<void>();
    await _pendingSend!.future;
  }
}
