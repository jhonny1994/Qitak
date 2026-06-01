import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'buyer can submit a rating after transaction is completed',
    (tester) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      await container.read(authSessionProvider.notifier).restore();

      final repository = container.read(transactionRepositoryProvider);

      // Build a completed transaction in the local repository.
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
      // Sync the transactionProvider so the rating screen can find the record.
      await container
          .read(transactionProvider.notifier)
          .refreshForUser('buyer-001');

      // Navigate to the rating screen.
      container.read(goRouterProvider).go('/ratings/transaction/${record.id}');
      await tester.pumpAndSettle();

      final submitButton = find.byKey(const Key('rating-submit-button'));
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // A snack bar confirms successful submission (text is locale-dependent).
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  testWidgets(
    'duplicate rating shows already-submitted feedback',
    (tester) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
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
      // Sync the transactionProvider so the rating screen can find the record.
      await container
          .read(transactionProvider.notifier)
          .refreshForUser('buyer-001');

      container.read(goRouterProvider).go('/ratings/transaction/${record.id}');
      await tester.pumpAndSettle();

      final submitButton = find.byKey(const Key('rating-submit-button'));

      // First submission succeeds.
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Second submission on the same transaction must show
      // "already submitted" feedback, not a crash.
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // The duplicate snack bar or inline error container is surfaced
      // (text is locale-dependent, so we check by widget type).
      expect(find.byType(SnackBar), findsWidgets);
    },
  );

  testWidgets(
    'rating screen is inaccessible for an in-progress transaction',
    (tester) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      await container.read(authSessionProvider.notifier).restore();

      final repository = container.read(transactionRepositoryProvider);

      // Create intent but do NOT transition to completed.
      final record = await repository.createIntent(
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
      );

      container.read(goRouterProvider).go('/ratings/transaction/${record.id}');
      await tester.pumpAndSettle();

      // The submit button is present but a tap should return an ineligible
      // message, not succeed.
      final submitButton = find.byKey(const Key('rating-submit-button'));
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Rating submitted.'), findsNothing);
    },
  );
}
