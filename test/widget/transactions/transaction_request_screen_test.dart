import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_request_screen.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

class _ThrowingTransactionRepository extends LocalTransactionRepository {
  _ThrowingTransactionRepository(this.error);

  final AppException error;

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    throw error;
  }
}

void main() {
  testWidgets('request screen distinguishes buy and exchange intent', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionRequestScreen(
            listingId: 'listing-1',
          ),
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

    expect(find.byKey(const Key('transaction-intent-buy')), findsOneWidget);
    expect(
      find.byKey(const Key('transaction-intent-exchange')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('transaction-obligations')), findsOneWidget);
  });

  testWidgets('creates purchase request', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionRequestScreen(
            listingId: 'listing-1',
          ),
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

    final button = find.byKey(const Key('transaction-request-button'));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Purchase request created.'), findsOneWidget);
  });

  testWidgets('shows network-specific request error copy', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionRequestScreen(
            listingId: 'listing-1',
          ),
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
      transactionRepositoryOverride: _ThrowingTransactionRepository(
        AppException.fromCode(AppErrorCode.networkUnavailable),
      ),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionRequestScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('transaction-request-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Network unavailable. Check your connection and try again.'),
      findsWidgets,
    );
    expect(
      find.text('An active deal already exists for this listing.'),
      findsNothing,
    );
  });
}
