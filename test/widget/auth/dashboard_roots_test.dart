import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/dashboard_metrics_provider.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('seller dashboard renders denser rooted workspace rows', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: SellerDashboardScreen(),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerDashboardScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Seller Dashboard'), findsOneWidget);
    expect(find.text('Create listing'), findsOneWidget);
    expect(find.text('My listings'), findsOneWidget);
    expect(find.text('Seller application status'), findsNothing);
  });

  testWidgets(
    'seller dashboard shows needs info as a distinct verification state',
    (
      tester,
    ) async {
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(
            body: SellerDashboardScreen(),
          ),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
        },
        overrides: [
          sellerDashboardMetricsProvider(
            'seller-001',
          ).overrideWith(
            (ref) => Future.value(
              const SellerDashboardMetrics(
                listingCount: 2,
                openDeals: 1,
                recentMessages: 3,
                verificationStatus: 'needs_more_info',
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SellerDashboardScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('Needs info'), findsOneWidget);
      expect(find.text('Submitted'), findsNothing);
    },
  );

  testWidgets('admin dashboard renders denser operational workspace rows', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(
          body: AdminDashboardScreen(),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AdminDashboardScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Admin dashboard'), findsOneWidget);
    expect(find.text('Reports queue'), findsOneWidget);
    expect(find.text('Disputes queue'), findsOneWidget);
    expect(find.text('Admin team'), findsNothing);
    expect(find.text('Local development feed'), findsNothing);
  });
}
