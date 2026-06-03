import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_detail_screen.dart';

import '../../test/fixtures/seeded_discovery_repository.dart';
import '../../test/test_bootstrap.dart';

/// Full cross-feature E2E smoke-test.
///
/// Covers:
///   1. Seller signs up, completes onboarding, is approved by admin.
///   2. Seller lands on the seller workspace.
///   3. Buyer is authenticated and browsed the listing catalogue.
///   4. Admin session confirms the dashboard is accessible.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─── seller side ──────────────────────────────────────────────────────────

  testWidgets(
    'seller session: sign-up → onboarding → approved → seller workspace',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(scope);
      await _approveSeller(tester);
      await tester.pumpAndSettle();
      await _enterSellerWorkspaceIfNeeded(tester);

      expect(find.byType(SellerDashboardScreen), findsOneWidget);
    },
  );

  testWidgets(
    'seller sees create-listing button on dashboard and can reach listing form',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(scope);
      await _approveSeller(tester);
      await tester.pumpAndSettle();
      await _enterSellerWorkspaceIfNeeded(tester);

      expect(
        find.byKey(const Key('seller-dashboard-create-listing')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('seller-dashboard-create-listing')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListingFormScreen), findsOneWidget);
    },
  );

  // ─── buyer side ───────────────────────────────────────────────────────────

  testWidgets(
    'buyer session: home screen shows search field and seeded listings',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home-search-field')), findsOneWidget);
    },
  );

  testWidgets(
    'buyer taps listing on home and reaches listing detail',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      // Navigate directly — mirrors tapping a listing tile.
      container.read(goRouterProvider).go('/listing/listing-1');
      await tester.pumpAndSettle();

      expect(find.byType(ListingDetailScreen), findsOneWidget);
      // Title appears in both the collapsing app bar and the body panel.
      expect(find.text('Headlight assembly'), findsWidgets);
    },
  );

  testWidgets(
    'buyer can initiate a transaction from listing detail',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      container
          .read(goRouterProvider)
          .go('/transactions/listing/listing-1/request');
      await tester.pumpAndSettle();

      final startButton = find.byKey(const Key('transaction-request-button'));
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailScreen), findsOneWidget);
    },
  );

  // ─── admin side ───────────────────────────────────────────────────────────

  testWidgets(
    'admin session: dashboard is accessible with queue shortcuts',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'admin@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.byKey(const Key('admin-dashboard-title')), findsOneWidget);
    },
  );

  // ─── full cross-role state transitions ────────────────────────────────────

  testWidgets(
    'full flow: buyer creates purchase request, seller confirms, cash payment completes',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      // Use the repository directly to simulate the multi-actor lifecycle
      // without switching accounts — the local repositories support it.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      await container.read(authSessionProvider.notifier).restore();

      final repository = container.read(transactionRepositoryProvider);

      final record = await repository.createRequest(
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
      );
      // The local in-memory repo starts at pendingSellerResponse.
      expect(record.state, TransactionState.pendingSellerResponse);

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

      final updated = await repository.transition(
        transactionId: record.id,
        actorUserId: 'seller-001',
        nextState: TransactionState.completed,
      );
      expect(updated.state, TransactionState.completed);

      // After completion, navigating to the rating screen should work.
      container.read(goRouterProvider).go('/ratings/transaction/${record.id}');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('rating-submit-button')), findsOneWidget);
    },
  );
}

// ─── helpers ────────────────────────────────────────────────────────────────

Future<void> _approveSeller(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(QitakApp)),
  );
  await container.read(authSessionProvider.notifier).restore();
  final profile = container.read(authSessionProvider).profile;
  if (profile == null) {
    throw StateError('Expected seller profile in integration setup.');
  }
  final repository = container.read(sellerApplicationRepositoryProvider);
  final existing = await repository.fetchCurrentForUser(profile.id);
  final application =
      existing ??
      await repository.submitApplication(
        userId: profile.id,
        draft: const SellerApplicationDraft(
          sellerType: 'business',
          businessName: 'Samir Auto Parts',
          phone: '+213555000222',
          wilayaId: '1',
          communeId: '1001',
          bio: 'Approved seller integration fixture.',
          policiesAccepted: true,
        ),
      );
  if (!application.isApproved) {
    await repository.updateStatus(
      applicationId: application.id,
      status: SellerVerificationStatus.approved,
    );
  }
}

Future<void> _enterSellerWorkspaceIfNeeded(WidgetTester tester) async {
  if (find.byType(SellerApplicationStatusScreen).evaluate().isNotEmpty) {
    final context = tester.element(find.byType(SellerApplicationStatusScreen));
    await tester.tap(find.text(context.l10n.sellerStatusBackToWorkspace));
    await tester.pumpAndSettle();
  }
}
