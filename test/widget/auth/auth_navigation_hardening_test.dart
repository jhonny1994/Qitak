import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/presentation/account_settings_screen.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/onboarding_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_up_screen.dart';
import 'package:qitak_app/features/auth/presentation/unknown_route_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  group('auth navigation hardening', () {
    testWidgets(
      'signed-in buyer does not remain on buyer sign up surface',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
            'qitak.ui.onboarding_seen': true,
          },
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(tester).go('/auth/sign-up');
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'signed-in seller does not remain on seller sign up surface',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
            'qitak.ui.onboarding_seen': true,
          },
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(tester).go('/auth/seller/sign-up');
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsNothing);
        expect(find.byType(SellerApplicationStatusScreen), findsOneWidget);
      },
    );

    testWidgets(
      'seller auth alias opens shared customer sign in in seller mode',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{'qitak.ui.onboarding_seen': true},
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(tester).go('/auth/seller/sign-in');
        await tester.pumpAndSettle();

        expect(find.byType(SignInScreen), findsOneWidget);
        expect(
          _routerFor(tester).routerDelegate.currentConfiguration.uri.toString(),
          '/auth/sign-in?mode=seller',
        );
      },
    );

    testWidgets(
      'signed-in admin does not remain on generic sign in surface',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{
            'qitak.local.session.email': 'admin@qitak.test',
            'qitak.ui.onboarding_seen': true,
          },
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(tester).go('/auth/sign-in');
        await tester.pumpAndSettle();

        expect(find.byType(SignInScreen), findsNothing);
        expect(find.byType(AdminDashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'signed-in buyer does not remain on reset password auth utility',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
            'qitak.ui.onboarding_seen': true,
          },
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(tester).go('/auth/reset-password');
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'unknown route screen does not expose auth query parameters',
      (tester) async {
        final app = await buildQitakApp(
          seed: const <String, Object>{'qitak.ui.onboarding_seen': true},
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        _routerFor(
          tester,
        ).go(
          '/missing?redirect=/admin/home&intentArgs=token=secret&access_token=abc123',
        );
        await tester.pumpAndSettle();

        expect(find.byType(UnknownRouteScreen), findsOneWidget);
        expect(find.textContaining('redirect='), findsNothing);
        expect(find.textContaining('intentArgs='), findsNothing);
        expect(find.textContaining('access_token'), findsNothing);
      },
    );

    testWidgets(
      'unknown route screen suppresses malformed token-like path values',
      (tester) async {
        final scope = await buildTestScope(
          const TestMaterialShell(
            child: Scaffold(
              body: UnknownRouteScreen(requestedPath: 'access_token=abc123'),
            ),
          ),
        );

        await tester.pumpWidget(scope);
        await tester.pumpAndSettle();

        expect(find.byType(UnknownRouteScreen), findsOneWidget);
        expect(find.textContaining('access_token'), findsNothing);
      },
    );

    testWidgets('onboarding clamps an out-of-range high step', (tester) async {
      final scope = await buildTestScope(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(body: OnboardingScreen(step: 99)),
        ),
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('onboarding-progress-chip')),
          matching: find.text('3/3'),
        ),
        findsOneWidget,
      );
      expect(find.text('99/3'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('onboarding clamps an out-of-range low step', (tester) async {
      final scope = await buildTestScope(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(body: OnboardingScreen(step: 0)),
        ),
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('onboarding-progress-chip')),
          matching: find.text('1/3'),
        ),
        findsOneWidget,
      );
      expect(find.text('0/3'), findsNothing);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets(
      'admin account settings hides transaction history dead end',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final scope = await buildTestScope(
          const TestMaterialShell(
            child: Scaffold(body: AccountSettingsScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'admin@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AccountSettingsScreen)),
        );
        await container.read(authSessionProvider.notifier).restore();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('account-settings-transaction-history')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'buyer account settings keeps transaction history access',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final scope = await buildTestScope(
          const TestMaterialShell(
            child: Scaffold(body: AccountSettingsScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AccountSettingsScreen)),
        );
        await container.read(authSessionProvider.notifier).restore();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('account-settings-transaction-history')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'buyer account settings orders entry opens live transactions',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const Scaffold(body: AccountSettingsScreen()),
            ),
            GoRoute(
              path: '/transactions',
              builder: (context, state) =>
                  const Scaffold(body: Text('transactions-screen')),
            ),
          ],
        );

        final scope = await buildTestScope(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(locale: const Locale('en')),
            darkTheme: AppTheme.dark(locale: const Locale('en')),
            themeMode: ThemeMode.dark,
            locale: const Locale('en'),
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
        );

        await tester.pumpWidget(scope);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        await container.read(authSessionProvider.notifier).restore();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('account-settings-transaction-history')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('account-settings-transaction-history')),
        );
        await tester.pumpAndSettle();

        expect(find.text('transactions-screen'), findsOneWidget);
      },
    );
  });
}

GoRouter _routerFor(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  return container.read(goRouterProvider);
}
