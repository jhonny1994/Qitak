import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/ratings/presentation/rating_screen.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

class _StaticTransactionRepository implements TransactionRepository {
  const _StaticTransactionRepository({
    required this.record,
    this.exposeToAnyUser = false,
  });

  final TransactionRecord record;
  final bool exposeToAnyUser;

  @override
  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  }) async {
    final isParticipant =
        (record.buyerUserId == fromUserId && record.sellerUserId == toUserId) ||
        (record.sellerUserId == fromUserId && record.buyerUserId == toUserId);
    return record.id == transactionId &&
        record.state == TransactionState.completed &&
        isParticipant;
  }

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    return transactionId == record.id ? record : null;
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async {
    if (exposeToAnyUser ||
        userId == record.buyerUserId ||
        userId == record.sellerUserId) {
      return <TransactionRecord>[record];
    }
    return const <TransactionRecord>[];
  }

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  }) async {
    throw UnimplementedError();
  }
}

TransactionRecord _fixtureTransactionRecord({
  required String id,
  required String buyerUserId,
  required String sellerUserId,
  required TransactionState state,
}) {
  return TransactionRecord(
    id: id,
    listingId: 'listing-1',
    buyerUserId: buyerUserId,
    sellerUserId: sellerUserId,
    state: state,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

Future<void> _scrollToSubmitButton(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('rating-submit-button')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.byKey(const Key('rating-submit-button')));
  await tester.pumpAndSettle();
}

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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RatingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    final repository = container.read(transactionRepositoryProvider);
    final record = await repository.createRequest(
      listingId: 'listing-1',
      buyerUserId: 'buyer-001',
      sellerUserId: 'seller-001',
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.sellerConfirmed,
    );
    await repository.selectPaymentMethod(
      transactionId: record.id,
      actorUserId: 'buyer-001',
      paymentMethod: TransactionPaymentMethod.cash,
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.completed,
    );
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('buyer-001');
    await tester.pumpAndSettle();

    await _scrollToSubmitButton(tester);
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await _scrollToSubmitButton(tester);
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Rating already submitted for this transaction.'),
      findsNWidgets(2),
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
    final record = await repository.createRequest(
      listingId: 'listing-1',
      buyerUserId: 'buyer-001',
      sellerUserId: 'seller-001',
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.sellerConfirmed,
    );
    await repository.selectPaymentMethod(
      transactionId: record.id,
      actorUserId: 'buyer-001',
      paymentMethod: TransactionPaymentMethod.cash,
    );
    await repository.transition(
      transactionId: record.id,
      actorUserId: 'seller-001',
      nextState: TransactionState.completed,
    );
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('buyer-001');
    await tester.pumpAndSettle();

    expect(find.text('Deal context'), findsOneWidget);
    expect(find.text('#001'), findsNothing);
    expect(find.text('Headlight assembly'), findsOneWidget);
    expect(find.text('Linked listing'), findsOneWidget);
  });

  testWidgets('blocks rating until the transaction is completed', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: RatingScreen(transactionId: 'tx-pending')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: _StaticTransactionRepository(
        record: _fixtureTransactionRecord(
          id: 'tx-pending',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.sellerConfirmed,
        ),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RatingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('buyer-001');
    await tester.pumpAndSettle();

    await _scrollToSubmitButton(tester);
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('rating-submit-button')))
          .onPressed,
      isNotNull,
    );
    expect(
      find.text('Rating is allowed only for completed transactions.'),
      findsOneWidget,
    );
  });

  testWidgets('blocks rating when the viewer is not a deal participant', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: RatingScreen(transactionId: 'tx-complete')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: _StaticTransactionRepository(
        record: _fixtureTransactionRecord(
          id: 'tx-complete',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.completed,
        ),
        exposeToAnyUser: true,
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RatingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await container
        .read(transactionProvider.notifier)
        .refreshForUser('admin-001');
    await tester.pumpAndSettle();

    expect(find.text('Deal context'), findsOneWidget);

    await _scrollToSubmitButton(tester);
    await tester.tap(find.byKey(const Key('rating-submit-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Rating is allowed only for completed transactions.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('rating-submit-button')))
          .onPressed,
      isNotNull,
    );
  });
}
