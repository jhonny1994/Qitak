import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/presentation/admin_queues_screen.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/admin/presentation/reports_queue_screen.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/presentation/search_screen.dart';
import 'package:qitak_app/features/listings/presentation/seller_listings_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('approved seller session lands on seller dashboard', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
    );

    await tester.pumpWidget(app);
    await _approveSellerApplication(tester);
    await tester.pumpAndSettle();

    expect(find.byType(SellerDashboardScreen), findsOneWidget);
  });

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

    GoRouter.of(
      tester.element(find.byType(GuestAccountScreen)),
    ).go('/auth/language');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(GuestAccountScreen), findsOneWidget);
  });

  testWidgets('buyer language utility returns to buyer profile shell', (
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

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets(
    'approved seller shell destinations route to seller workspace branches',
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
      await _approveSellerApplication(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SellerListingsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ConversationListScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
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
    expect(find.text('حالة طلب البائع'), findsNothing);
  });

  testWidgets('seller status back to profile uses seller profile tree', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SellerApplicationStatusScreen(),
          ),
        ),
        GoRoute(
          path: '/seller/profile/settings',
          builder: (context, state) => const Scaffold(
            body: Text('seller-profile-settings'),
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
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        currentSellerApplicationProvider.overrideWith(
          (ref) => Future.value(
            const SellerApplication(
              id: 'app-1',
              userId: 'seller-001',
              sellerType: 'business',
              businessName: 'Samir Auto Parts',
              phone: '+213555000222',
              email: 'seller@qitak.test',
              wilayaId: '1',
              communeId: '1001',
              bio: 'Pending verification',
              verificationStatus: 'submitted',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('seller-status-profile-action')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('seller-status-profile-action')));
    await tester.pumpAndSettle();

    expect(find.text('seller-profile-settings'), findsOneWidget);
  });

  testWidgets(
    'submitted seller status uses profile return instead of continue',
    (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SellerApplicationStatusScreen(),
            ),
          ),
          GoRoute(
            path: '/seller/profile/settings',
            builder: (context, state) => const Scaffold(
              body: Text('seller-profile-settings'),
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
          'qitak.local.session.email': 'seller@qitak.test',
        },
        overrides: [
          currentSellerApplicationProvider.overrideWith(
            (ref) => Future.value(
              const SellerApplication(
                id: 'app-1',
                userId: 'seller-001',
                sellerType: 'individual',
                businessName: 'Samir Auto Parts',
                phone: '+213555000222',
                email: 'seller@qitak.test',
                wilayaId: '1',
                communeId: '1001',
                bio: '',
                verificationStatus: 'submitted',
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('Continue application'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('seller-status-profile-action')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('seller-status-primary-action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('seller-status-profile-action')),
        findsOneWidget,
      );
    },
  );

  testWidgets('seller status header back does not loop back to status', (
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
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}

Future<void> _approveSellerApplication(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  final profile = container.read(authSessionProvider).profile;
  if (profile == null) {
    throw StateError('Expected an authenticated seller profile in test setup.');
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
          bio: 'Approved seller test application.',
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
