import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buyer can open a seeded conversation thread', (tester) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QitakApp)),
    );
    final messaging = container.read(messagingProvider.notifier);
    await messaging.sendMessage(
      threadId: 'l1',
      senderId: 'seller-001',
      body: 'Stock confirmed for the requested part.',
    );
    await messaging.sendMessage(
      threadId: 'l1',
      senderId: 'buyer-001',
      body: 'Please share the pickup point.',
    );

    container.read(goRouterProvider).go('/messages/thread/l1');
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byKey(const Key('message-send-button')), findsOneWidget);
  });
}
