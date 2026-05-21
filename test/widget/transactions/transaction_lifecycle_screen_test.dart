import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_lifecycle_screen.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('formats transaction reference and state labels for display', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: TransactionLifecycleScreen()),
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
      tester.element(find.byType(TransactionLifecycleScreen)),
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

    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('completed'), findsNothing);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Complete'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });
}
