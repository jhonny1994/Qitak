import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_intent_screen.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('creates transaction intent', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: TransactionIntentScreen(
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
      tester.element(find.byType(TransactionIntentScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    final button = find.byKey(const Key('transaction-start-button'));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Transaction intent created.'), findsOneWidget);
  });
}
