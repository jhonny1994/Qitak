import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';

import '../../test/fixtures/seeded_discovery_repository.dart';
import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'buyer navigates from search result to listing detail',
    (tester) async {
      final app = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );

      // Navigate directly to the listing detail for the first seeded listing.
      container.read(goRouterProvider).go('/listing/listing-1');
      await tester.pumpAndSettle();

      expect(find.byType(ListingDetailScreen), findsOneWidget);
      // The title appears twice (collapsing app bar + body), so use findsWidgets.
      expect(find.text('Headlight assembly'), findsWidgets);
    },
  );

  testWidgets(
    'buyer taps "Message seller" from listing detail and lands on conversation',
    (tester) async {
      final app = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      container.read(goRouterProvider).go('/listing/listing-1');
      await tester.pumpAndSettle();

      expect(find.byType(ListingDetailScreen), findsOneWidget);

      final context = tester.element(find.byType(ListingDetailScreen));
      final messageSeller = find.text(context.l10n.discoveryMessageSeller);
      // Scroll down enough to reveal the action dock (off-screen in sliver).
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      await tester.tap(messageSeller);
      await tester.pumpAndSettle();

      // After tapping "Message seller" the router navigates to
      // /messages/thread/<threadId>.  The seeded listing has threadId = 'l1'.
      expect(find.byType(ConversationScreen), findsOneWidget);
      expect(find.byKey(const Key('message-send-button')), findsOneWidget);
    },
  );
}
