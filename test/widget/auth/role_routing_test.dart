import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/admin_queues_screen.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/admin/presentation/reports_queue_screen.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/language_selection_screen.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/discovery/presentation/search_screen.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets(
    'seller session currently lands on seller status screen until approved',
    (
      tester,
    ) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(SellerApplicationStatusScreen), findsOneWidget);
      expect(find.byType(SellerDashboardScreen), findsNothing);
    },
  );

  testWidgets('admin session lands on admin dashboard', (tester) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });

  testWidgets(
    'anonymous account destination opens guest account branch',
    (
      tester,
    ) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.ui.onboarding_seen': true,
          'qitak.ui.guest_language': 'en',
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(GuestAccountScreen), findsOneWidget);
      expect(
        find.byKey(const Key('guest-account-language-button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byType(SearchScreen), findsNothing);
    },
  );

  testWidgets('guest language utility returns to guest account shell', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.ui.onboarding_seen': true,
        'qitak.ui.guest_browsing_enabled': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(GuestAccountScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('guest-account-language-button')));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(GuestAccountScreen), findsOneWidget);
  });

  testWidgets(
    'buyer language utility returns to buyer profile shell',
    (
      tester,
    ) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-language-button')));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSelectionScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    },
  );

  testWidgets(
    'seller workspace branches stay blocked until seller approval exists',
    (
      tester,
    ) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(SellerApplicationStatusScreen), findsOneWidget);
      expect(find.byType(SellerDashboardScreen), findsNothing);
    },
  );

  testWidgets('unapproved seller session lands on seller status screen', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(SellerApplicationStatusScreen), findsOneWidget);
    expect(find.byType(SellerDashboardScreen), findsNothing);
  });

  testWidgets('admin shell destinations keep admin workspace navigation', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(AdminQueuesScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsQueueScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('super admin team destination opens inside shell', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'superadmin@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.group_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(AdminTeamScreen), findsOneWidget);
  });

  testWidgets('buyer profile does not expose seller onboarding controls', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byKey(const Key('profile-enable-seller')), findsNothing);
  });
}
