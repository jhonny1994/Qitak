import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/onboarding_screen.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'fresh launch can skip onboarding and browse through guest account',
    (
      tester,
    ) async {
      final app = await buildQitakApp();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(GuestAccountScreen), findsOneWidget);
      expect(
        find.byKey(const Key('guest-account-language-button')),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.storefront_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home-search-field')), findsOneWidget);
    },
  );

  testWidgets('seller session routes to role-safe landing', (tester) async {
    final sellerApp = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );
    await tester.pumpWidget(sellerApp);
    await _approveSeller(tester);
    await tester.pumpAndSettle();
    await _enterSellerWorkspaceIfNeeded(tester);

    expect(find.byType(SellerDashboardScreen), findsOneWidget);
    expect(find.byKey(const Key('seller-dashboard-title')), findsOneWidget);
  });

  testWidgets('unapproved seller session lands on seller status', (
    tester,
  ) async {
    final sellerApp = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );
    await tester.pumpWidget(sellerApp);
    await tester.pumpAndSettle();

    expect(find.byType(SellerApplicationStatusScreen), findsOneWidget);
  });

  testWidgets('admin session routes to role-safe landing', (tester) async {
    final adminApp = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );
    await tester.pumpWidget(adminApp);
    await tester.pumpAndSettle();
    expect(find.byType(AdminDashboardScreen), findsOneWidget);
    expect(find.byKey(const Key('admin-dashboard-title')), findsOneWidget);
  });
}

Future<void> _approveSeller(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
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
      status: 'approved',
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
