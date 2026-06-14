import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/seller_orders_screen.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('seller orders screen prioritizes actionable seller work', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOrdersScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOrdersScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    final repository = container.read(transactionRepositoryProvider);

    await repository.createRequest(
      listingId: 'listing-1',
      buyerUserId: 'buyer-001',
      sellerUserId: 'seller-001',
    );
    final proof = await repository.createRequest(
      listingId: 'listing-2',
      buyerUserId: 'buyer-002',
      sellerUserId: 'seller-001',
    );
    await repository.transition(
      transactionId: proof.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.sellerConfirmed,
    );
    await repository.selectPaymentMethod(
      transactionId: proof.id,
      actorUserId: 'buyer-002',
      paymentMethod: TransactionPaymentMethod.ccp,
    );
    await repository.submitPaymentProof(
      transactionId: proof.id,
      actorUserId: 'buyer-002',
      proof: ListingMediaSelection(
        fileName: 'proof.jpg',
        mimeType: 'image/jpeg',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      ),
    );
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('seller-001');
    await tester.pumpAndSettle();

    expect(find.text('Seller orders'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Proof review'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Accept'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Confirm payment'),
      findsOneWidget,
    );
  });
}
