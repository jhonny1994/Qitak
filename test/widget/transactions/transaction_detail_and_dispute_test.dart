import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/dispute_create_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_intent_screen.dart';
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
  Future<TransactionRecord> createIntent({
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
    return record = TransactionRecord(
      id: record.id,
      listingId: record.listingId,
      buyerUserId: record.buyerUserId,
      sellerUserId: record.sellerUserId,
      state: nextState,
      createdAt: record.createdAt,
      updatedAt: DateTime(2026, 1, 2),
      dealType: record.dealType,
      exchangeOffer: record.exchangeOffer,
      expiresAt: record.expiresAt,
      confirmedAt: record.confirmedAt,
      completedAt: record.completedAt,
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
        .createIntent(
          listingId: 'listing-1',
          buyerUserId: 'buyer-001',
          sellerUserId: 'seller-001',
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('listing-1'), findsNothing);
    expect(find.text('Headlight assembly'), findsOneWidget);
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
          path: '/transactions/listing/:listingId/new',
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

  testWidgets('transaction intent uses request part CTA label', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionIntentScreen(listingId: 'listing-1'),
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
      tester.element(find.byType(TransactionIntentScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Request part'), findsOneWidget);
  });
}
