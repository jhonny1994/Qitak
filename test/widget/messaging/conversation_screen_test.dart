import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';

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
}

class TestMessagingOnlineNotifier extends MessagingOnlineNotifier {
  @override
  bool build() => false;
}
