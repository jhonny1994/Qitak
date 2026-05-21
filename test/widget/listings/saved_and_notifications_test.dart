import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/presentation/saved_listings_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/features/notifications/presentation/notification_center_screen.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('renders saved listings from persisted shortlist', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SavedListingsScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
        'qitak.saved.listings.buyer-001': <String>['listing-1'],
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SavedListingsScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Saved listings'), findsOneWidget);
    expect(find.text('Headlight assembly'), findsOneWidget);
    expect(find.text('Lighting'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('renders conversation inbox rows when messages exist', (
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationListScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await container
        .read(messagingProvider.notifier)
        .sendMessage(
          threadId: 'thread-1',
          senderId: 'buyer-001',
          body: 'Is it still available?',
        );
    await tester.pumpAndSettle();

    expect(find.text('Listing conversations'), findsOneWidget);
    expect(find.text('Is it still available?'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets(
    'renders notification empty state when no backend notifications exist',
    (tester) async {
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(body: NotificationCenterScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(
        find.text(
          'No notifications yet. New account, message, and listing events will appear here.',
        ),
        findsOneWidget,
      );
    },
  );
}
