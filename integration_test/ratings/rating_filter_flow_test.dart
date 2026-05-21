import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buyer can open rating route for a completed transaction', (
    tester,
  ) async {
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
    container.read(goRouterProvider).go('/ratings/transaction/${record.id}');
    await tester.pumpAndSettle();

    final submit = find.byKey(const Key('rating-submit-button'));
    expect(submit, findsOneWidget);
  });
}
