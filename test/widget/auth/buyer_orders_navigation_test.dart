import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_navigation_shell.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('buyer orders tab opens live transactions route', (tester) async {
    final rootKey = GlobalKey<NavigatorState>();
    final shellKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      navigatorKey: rootKey,
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => QitakNavigationShell(
            navigationShell: navigationShell,
          ),
          branches: [
            StatefulShellBranch(
              navigatorKey: shellKey,
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Scaffold(
                    body: Text('home-screen'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/seller/listings',
                  builder: (context, state) => const Scaffold(
                    body: Text('seller-listings-screen'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/transactions',
                  builder: (context, state) => const Scaffold(
                    body: Text('transactions-screen'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/messages',
                  builder: (context, state) => const Scaffold(
                    body: Text('messages-screen'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const Scaffold(
                    body: Text('profile-screen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final scope = await buildTestScope(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        theme: AppTheme.light(locale: const Locale('en')),
        darkTheme: AppTheme.dark(locale: const Locale('en')),
        themeMode: ThemeMode.dark,
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

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.text('transactions-screen'), findsOneWidget);
  });
}
