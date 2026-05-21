import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/ratings/presentation/rating_screen.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('prevents duplicate rating submission by same actor', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: RatingScreen(transactionId: 'tx-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.ensureVisible(find.byKey(const Key('rating-submit-button')));
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('rating-submit-button')));
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Rating already submitted for this transaction.'),
      findsOneWidget,
    );
  });

  testWidgets('shows completed deal context before rating', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: RatingScreen(transactionId: 'tx-1')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RatingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    final repository = container.read(transactionRepositoryProvider);
    final record = await repository.createIntent(
      listingId: 'listing-1',
      buyerUserId: 'buyer-001',
      sellerUserId: 'seller-001',
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.sellerConfirmed,
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'buyer-001',
      nextState: TransactionState.completed,
    );
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('buyer-001');
    await tester.pumpAndSettle();

    expect(find.text('Deal context'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Linked listing'), findsOneWidget);
  });
}
