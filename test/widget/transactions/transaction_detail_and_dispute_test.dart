import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/dispute_create_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_history_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_request_screen.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this.record);

  TransactionRecord record;
  final List<
    ({String transactionId, String actorUserId, TransactionState nextState})
  >
  transitions =
      <
        ({String transactionId, String actorUserId, TransactionState nextState})
      >[];

  @override
  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  }) async => true;

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    return record;
  }

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    return transactionId == record.id ? record : null;
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async => [record];

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    return record = record.copyWith(
      state: TransactionState.sellerConfirmed,
      updatedAt: DateTime(2026, 1, 2),
      clearPaymentProofPath: true,
      clearPaymentProofSubmittedAt: true,
      clearPaymentConfirmedAt: true,
    );
  }

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    return record = record.copyWith(
      paymentMethod: paymentMethod,
      updatedAt: DateTime(2026, 1, 2),
    );
  }

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    return record = record.copyWith(
      state: TransactionState.paymentProofSubmitted,
      paymentProofPath: proof.fileName,
      paymentProofSubmittedAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    );
  }

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  }) async {
    transitions.add(
      (
        transactionId: transactionId,
        actorUserId: actorUserId,
        nextState: nextState,
      ),
    );
    return record = record.copyWith(
      state: nextState,
      updatedAt: DateTime(2026, 1, 2),
      confirmedAt: nextState == TransactionState.sellerConfirmed
          ? DateTime(2026, 1, 2)
          : record.confirmedAt,
      paymentConfirmedAt: nextState == TransactionState.paymentConfirmed
          ? DateTime(2026, 1, 2)
          : record.paymentConfirmedAt,
      completedAt: nextState == TransactionState.completed
          ? DateTime(2026, 1, 2)
          : record.completedAt,
      cancelledAt: nextState == TransactionState.cancelled
          ? DateTime(2026, 1, 2)
          : record.cancelledAt,
    );
  }
}

void main() {
  testWidgets('transaction detail shows missing state when record is absent', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionDetailScreen(transactionId: 'tx-missing'),
        ),
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
      tester.element(find.byType(TransactionDetailScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Transaction not found'), findsOneWidget);
  });

  testWidgets('transaction detail does not leak the raw linked listing id', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: TransactionDetailScreen(transactionId: 'tx-1')),
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
      tester.element(find.byType(TransactionDetailScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await container
        .read(transactionProvider.notifier)
        .createRequest(
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('listing-1'), findsNothing);
    expect(find.text('Headlight assembly'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('dispute screen validates description length', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: DisputeCreateScreen(transactionId: 'tx-1'),
        ),
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
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const Key('dispute-submit-button')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<FilledButton>(find.byKey(const Key('dispute-submit-button')))
        .onPressed!
        .call();
    await tester.pumpAndSettle();

    expect(
      find.text('Enter at least 50 characters so the case can be reviewed.'),
      findsOneWidget,
    );
  });

  testWidgets('transaction detail confirms before cancelling', (tester) async {
    final repository = _FakeTransactionRepository(
      TransactionRecord(
        id: 'tx-cancel',
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
        state: TransactionState.pendingSellerResponse,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionDetailScreen(transactionId: 'tx-cancel'),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionDetailScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.widgetWithText(OutlinedButton, 'Cancel'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel'))
        .onPressed!
        .call();
    await tester.pumpAndSettle();

    expect(find.text('Cancel transaction'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.transitions, isEmpty);

    await tester.dragUntilVisible(
      find.widgetWithText(OutlinedButton, 'Cancel'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel'))
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel transaction'));
    await tester.pumpAndSettle();

    expect(
      repository.transitions.single,
      (
        transactionId: 'tx-cancel',
        actorUserId: 'buyer-001',
        nextState: TransactionState.cancelled,
      ),
    );
  });

  testWidgets('transaction detail shows cash handoff guidance for seller', (
    tester,
  ) async {
    final repository = _FakeTransactionRepository(
      TransactionRecord(
        id: 'tx-cash',
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
        state: TransactionState.sellerConfirmed,
        paymentMethod: TransactionPaymentMethod.cash,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionDetailScreen(transactionId: 'tx-cash'),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: repository,
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionDetailScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Meet the buyer in person, collect cash, then confirm the cash order.',
      ),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('transaction-detail-support')),
      findsOneWidget,
    );
  });

  testWidgets(
    'transaction detail shows proof review guidance for seller after upload',
    (tester) async {
      final repository = _FakeTransactionRepository(
        TransactionRecord(
          id: 'tx-proof',
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.paymentProofSubmitted,
          paymentMethod: TransactionPaymentMethod.ccp,
          paymentProofPath: 'proof.png',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );

      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(
            body: TransactionDetailScreen(transactionId: 'tx-proof'),
          ),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
        transactionRepositoryOverride: repository,
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TransactionDetailScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(
        find.text('Review the uploaded proof and confirm or reject it.'),
        findsWidgets,
      );
      expect(
        find.byKey(const Key('transaction-detail-support')),
        findsOneWidget,
      );
    },
  );

  testWidgets('dispute screen renders success state after submit', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: DisputeCreateScreen(transactionId: 'tx-1'),
          ),
        ),
        GoRoute(
          path: '/deals',
          builder: (context, state) => const Scaffold(
            body: Text('deals-screen'),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(
      MaterialApp.router(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
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
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'The seller confirmed the deal but the delivered part does not match the listing details at all.',
    );
    await tester.dragUntilVisible(
      find.byKey(const Key('dispute-submit-button')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<FilledButton>(find.byKey(const Key('dispute-submit-button')))
        .onPressed!
        .call();
    await tester.pumpAndSettle();

    expect(find.text('Dispute submitted'), findsOneWidget);
    expect(
      find.text(
        'Dispute submitted. Our team will review within 24 to 48 hours.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'transaction detail uses dispute-open copy instead of rejection copy',
    (
      tester,
    ) async {
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(
            body: TransactionDetailScreen(transactionId: 'tx-dispute-open'),
          ),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
        transactionRepositoryOverride: _FakeTransactionRepository(
          TransactionRecord(
            id: 'tx-dispute-open',
            listingId: 'listing-1',
            buyerUserId: 'buyer-001',
            sellerUserId: 'seller-001',
            state: TransactionState.disputeOpened,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TransactionDetailScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('Dispute open'), findsWidgets);
      expect(
        find.text('A dispute is open and the operations team is reviewing it.'),
        findsOneWidget,
      );
      expect(
        find.text('This transaction was rejected by the seller.'),
        findsNothing,
      );
    },
  );

  testWidgets('transaction history surfaces resolved disputes with final copy', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionDetailScreen(transactionId: 'tx-dispute-resolved'),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: _FakeTransactionRepository(
        TransactionRecord(
          id: 'tx-dispute-resolved',
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.disputeResolved,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionDetailScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Dispute resolved'), findsWidgets);
    expect(
      find.text(
        'The dispute was resolved. Review the final outcome before taking the next step.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('This transaction was rejected by the seller.'),
      findsNothing,
    );
  });

  testWidgets('transaction history shows dispute guidance copy', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: TransactionHistoryScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      transactionRepositoryOverride: _FakeTransactionRepository(
        TransactionRecord(
          id: 'tx-history-dispute',
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.disputeOpened,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionHistoryScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(
      find.text('A dispute is open and the operations team is reviewing it.'),
      findsOneWidget,
    );
    expect(
      find.text('This transaction was rejected by the seller.'),
      findsNothing,
    );
  });

  testWidgets('transaction history labels event time as updated', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: TransactionHistoryScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      transactionRepositoryOverride: _FakeTransactionRepository(
        TransactionRecord(
          id: 'tx-history-updated',
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.pendingSellerResponse,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026, 1, 3),
        ),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionHistoryScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Deal date'), findsNothing);
    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('2026-01-03'), findsOneWidget);
  });

  testWidgets('expired transaction detail exposes try again action', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: TransactionDetailScreen(transactionId: 'tx-expired'),
          ),
        ),
        GoRoute(
          path: '/transactions/listing/:listingId/request',
          builder: (context, state) => Scaffold(
            body: Text('retry-${state.pathParameters['listingId']}'),
          ),
        ),
      ],
    );
    final scope = await buildTestScope(
      MaterialApp.router(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
      transactionRepositoryOverride: _FakeTransactionRepository(
        TransactionRecord(
          id: 'tx-expired',
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
          state: TransactionState.expired,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    final retryButton = find.widgetWithText(FilledButton, 'Retry');
    expect(retryButton, findsOneWidget);
  });

  testWidgets('transaction request uses request CTA label', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionRequestScreen(listingId: 'listing-1'),
        ),
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
      tester.element(find.byType(TransactionRequestScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Send request'), findsOneWidget);
  });
}
