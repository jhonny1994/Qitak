import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('renders only the selected thread messages', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationScreen(threadId: 'thread-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await container
        .read(messagingProvider.notifier)
        .sendMessage(
          threadId: 'thread-1',
          senderId: 'buyer-001',
          body: 'Thread one message',
        );
    await container
        .read(messagingProvider.notifier)
        .sendMessage(
          threadId: 'thread-2',
          senderId: 'buyer-001',
          body: 'Thread two message',
        );
    await tester.pumpAndSettle();

    expect(find.text('Thread one message'), findsOneWidget);
    expect(find.text('Thread two message'), findsNothing);
  });

  testWidgets('shows online-only message when offline', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationScreen(threadId: 'thread-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        messagingOnlineProvider.overrideWith(TestMessagingOnlineNotifier.new),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.ensureVisible(find.byKey(const Key('message-send-button')));
    await tester.tap(find.byKey(const Key('message-send-button')));
    await tester.pumpAndSettle();

    expect(find.text('Messages are online-only right now.'), findsWidgets);
  });

  testWidgets('conversation header shows shared counterparty identity', (
    tester,
  ) async {
    final repository = _ConversationIdentityRepository();
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

    expect(find.text('Seller One'), findsOneWidget);
    expect(find.text('Alternator listing'), findsOneWidget);
  });

  testWidgets(
    'local conversation screen does not attempt thread realtime subscription',
    (tester) async {
      final repository = _ThrowingLocalRealtimeMessagingRepository();
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
      await container
          .read(messagingProvider.notifier)
          .sendMessage(
            threadId: 'thread-1',
            senderId: 'buyer-001',
            body: 'Local message',
          );
      await tester.pumpAndSettle();

      expect(repository.subscribeCalled, isFalse);
      expect(find.text('Local message'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class TestMessagingOnlineNotifier extends MessagingOnlineNotifier {
  @override
  bool build() => false;
}

class _ThrowingLocalRealtimeMessagingRepository
    extends LocalMessagingRepository {
  bool subscribeCalled = false;

  @override
  RealtimeChannel? subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) {
    subscribeCalled = true;
    throw UnsupportedError(
      'Local mode should not subscribe to thread realtime',
    );
  }
}

class _ConversationIdentityRepository extends LocalMessagingRepository {
  @override
  Future<List<ConversationThreadSummary>> listThreadsForUser(
    String userId,
  ) async => <ConversationThreadSummary>[
    ConversationThreadSummary(
      id: 'thread-1',
      listingId: 'listing-1',
      otherPartyUserId: 'seller-1',
      listingTitle: 'Alternator listing',
      lastMessageBody: 'Still available?',
      lastMessageAt: DateTime(2026, 6, 4, 10),
      lastSenderId: 'seller-1',
      otherPartyLabel: 'Seller One',
    ),
  ];
}
