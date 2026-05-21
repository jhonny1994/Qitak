import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/account_settings_screen.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/presentation/appearance_preferences_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/language_selection_screen.dart';
import 'package:qitak_app/features/auth/presentation/onboarding_screen.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/presentation/protected_action_gate.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_up_screen.dart';
import 'package:qitak_app/features/auth/presentation/splash_screen.dart';
import 'package:qitak_app/features/auth/presentation/support_help_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  MaterialApp routerShell(GoRouter router) {
    return MaterialApp.router(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }

  testWidgets('sign in validates required fields', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('account settings updates local session profile', (tester) async {
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

    await tester.enterText(find.byType(TextFormField).first, 'Karim Updated');
    await tester.enterText(find.byType(TextFormField).at(1), '+213555444333');
    await tester.tap(find.byKey(const Key('account-settings-save')));
    await tester.pumpAndSettle();

    final updated = container.read(authSessionProvider).profile;
    expect(updated?.fullName, 'Karim Updated');
    expect(updated?.phone, '+213555444333');
  });

  testWidgets('account settings can deactivate the current account', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: AccountSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/guest/account',
          builder: (context, state) => const Scaffold(
            body: GuestAccountScreen(),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(
      routerShell(router),
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('account-settings-delete-account')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const Key('account-settings-delete-account')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-settings-delete-account')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account').last);
    await tester.pumpAndSettle();

    expect(find.byType(GuestAccountScreen), findsOneWidget);
    expect(
      container.read(authSessionProvider).status,
      AuthResolutionStatus.anonymous,
    );
  });

  testWidgets('language selection updates session language', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: LanguageSelectionScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanguageSelectionScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language-option-fr')));
    await tester.pumpAndSettle();

    expect(container.read(authSessionProvider).profile?.language, 'fr');
  });

  testWidgets('language selection updates guest preference when anonymous', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: LanguageSelectionScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanguageSelectionScreen)),
    );
    await tester.tap(find.byKey(const Key('language-option-en')));
    await tester.pumpAndSettle();

    expect(container.read(appPreferencesProvider).guestLanguage, 'en');
  });

  testWidgets('appearance selection updates persistent theme preference', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: AppearancePreferencesScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePreferencesScreen)),
    );
    await tester.tap(find.byKey(const Key('appearance-option-light')));
    await tester.pumpAndSettle();

    expect(container.read(appPreferencesProvider).themeMode, ThemeMode.light);
  });

  testWidgets(
    'profile screen omits seller-conversion signals for buyer accounts',
    (tester) async {
      final scope = await buildTestScope(
        MaterialApp(
          locale: const Locale('ar'),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(body: ProfileScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('Karim Benali'), findsOneWidget);
      expect(find.text('buyer@qitak.test'), findsOneWidget);
      expect(find.text('وضع البائع'), findsNothing);
      expect(find.text('مساحة البائع مفعلة'), findsNothing);
      expect(find.text('مساحة البائع غير مفعلة بعد'), findsNothing);
    },
  );

  testWidgets('sign in stays credential-focused', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Admin access'), findsNothing);
    expect(find.text('Help and support'), findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets(
    'shared sign in surface switches role and uses text link for mode',
    (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/auth/sign-in',
            builder: (context, state) => const Scaffold(
              body: SignInScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/seller/sign-in',
            builder: (context, state) => const Scaffold(
              body: SignInScreen(variant: SignInVariant.seller),
            ),
          ),
          GoRoute(
            path: '/auth/sign-up',
            builder: (context, state) => const Scaffold(
              body: SignUpScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/seller/sign-up',
            builder: (context, state) => const Scaffold(
              body: SignUpScreen(variant: SignUpVariant.seller),
            ),
          ),
        ],
        initialLocation: '/auth/sign-in',
      );

      final scope = await buildTestScope(routerShell(router));
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);

      await tester.tap(find.text('Seller'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        find.text('Restricted sign-in for seller accounts only.'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.text('Need a seller account? Create one'),
      );
      await tester.tap(find.text('Need a seller account? Create one'));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Create seller account'), findsOneWidget);
    },
  );

  testWidgets(
    'shared sign up surface switches role and uses text link for mode',
    (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/auth/sign-in',
            builder: (context, state) => const Scaffold(
              body: SignInScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/seller/sign-in',
            builder: (context, state) => const Scaffold(
              body: SignInScreen(variant: SignInVariant.seller),
            ),
          ),
          GoRoute(
            path: '/auth/sign-up',
            builder: (context, state) => const Scaffold(
              body: SignUpScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/seller/sign-up',
            builder: (context, state) => const Scaffold(
              body: SignUpScreen(variant: SignUpVariant.seller),
            ),
          ),
        ],
        initialLocation: '/auth/seller/sign-up',
      );

      final scope = await buildTestScope(routerShell(router));
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Create seller account'), findsOneWidget);

      await tester.tap(find.text('Buyer'));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Create account'), findsAtLeastNWidgets(1));

      await tester.ensureVisible(find.text('Already have an account? Sign in'));
      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        find.text('Sign in to your account'),
        findsOneWidget,
      );
    },
  );

  testWidgets('buyer sign in rejects seller accounts', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'seller@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('This account is not a buyer account.'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignInScreen)),
    );
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
  });

  testWidgets('seller sign in rejects buyer accounts', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen(variant: SignInVariant.seller)),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'buyer@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('This account is not a seller account.'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignInScreen)),
    );
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
  });

  testWidgets('admin sign in rejects buyer accounts', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen(variant: SignInVariant.admin)),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'buyer@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(
      find.text('This account does not have admin access.'),
      findsOneWidget,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignInScreen)),
    );
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
  });

  testWidgets('failed sign in preserves guest browsing preference', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
      seed: const <String, Object>{
        'qitak.ui.guest_browsing_enabled': true,
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignInScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'missing@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(container.read(appPreferencesProvider).guestBrowsingEnabled, isTrue);
  });

  testWidgets('seller sign up lands on seller onboarding status', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SignUpScreen(variant: SignUpVariant.seller),
          ),
        ),
        GoRoute(
          path: '/seller/onboarding/status',
          builder: (context, state) => const Scaffold(
            body: Text('seller-status'),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(routerShell(router));
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Seller Ready');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'seller.ready@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '+213555111222');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create account').last);
    await tester.pumpAndSettle();

    expect(find.text('seller-status'), findsOneWidget);
  });

  testWidgets(
    'seller sign up still lands on seller onboarding when approval lookup fails',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SignUpScreen(variant: SignUpVariant.seller),
            ),
          ),
          GoRoute(
            path: '/seller/onboarding/status',
            builder: (context, state) => const Scaffold(
              body: Text('seller-status'),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(
        routerShell(router),
        sellerApplicationRepositoryOverride:
            const _ThrowingSellerApplicationRepository(),
      );
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Seller Fallback',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'seller.fallback@qitak.test',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '+213555111999');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Create account').last,
      );
      await tester.pumpAndSettle();

      expect(find.text('seller-status'), findsOneWidget);
      expect(find.text('We could not create your account.'), findsNothing);
    },
  );

  testWidgets('failed sign up preserves guest browsing preference', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignUpScreen()),
      ),
      seed: const <String, Object>{
        'qitak.ui.guest_browsing_enabled': true,
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SignUpScreen)),
    );
    await container
        .read(appPreferencesProvider.notifier)
        .setGuestBrowsingEnabled(enabled: true);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Missing User');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'buyer@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '+213555444333');
    await tester.enterText(find.byType(TextFormField).at(3), 'wrongpass123');
    await tester.enterText(find.byType(TextFormField).at(4), 'wrongpass123');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create account').last,
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Create account').last,
    );
    await tester.pumpAndSettle();

    expect(container.read(appPreferencesProvider).guestBrowsingEnabled, isTrue);
  });

  testWidgets('admin sign in stays isolated from guest and sign-up paths', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen(variant: SignInVariant.admin)),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Admin access'), findsNothing);
    expect(find.text('Back to user auth'), findsOneWidget);
  });

  testWidgets('account settings focuses on editable account controls', (
    tester,
  ) async {
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
      find.byKey(const Key('account-settings-language-link')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('account-settings-appearance-link')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('account-settings-notifications-link')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('account-settings-support-link')),
      findsNothing,
    );
    expect(find.byKey(const Key('account-settings-legal-link')), findsNothing);
    expect(find.byKey(const Key('account-settings-save')), findsOneWidget);
    expect(
      find.byKey(const Key('account-settings-password-reset')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('account-settings-delete-account')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('account-settings-delete-account')),
      findsOneWidget,
    );
  });

  testWidgets(
    'seller profile hub exposes account utilities and settings entry',
    (
      tester,
    ) async {
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
          home: const Scaffold(body: ProfileScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
        },
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-settings-button')), findsOneWidget);
      expect(find.byKey(const Key('profile-language-button')), findsOneWidget);
      expect(
        find.byKey(const Key('profile-appearance-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('profile-notifications-button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('profile-support-button')), findsOneWidget);
      expect(find.byKey(const Key('profile-legal-button')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile-sign-out')),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile-sign-out')), findsOneWidget);
      expect(find.text('Create a listing'), findsNothing);
      expect(find.text('My listings'), findsNothing);
      expect(find.text('Transactions'), findsNothing);
    },
  );

  testWidgets(
    'admin profile hub exposes account utilities without seller-only actions',
    (
      tester,
    ) async {
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
          home: const Scaffold(body: ProfileScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'admin@qitak.test',
        },
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-settings-button')), findsOneWidget);
      expect(find.byKey(const Key('profile-language-button')), findsOneWidget);
      expect(
        find.byKey(const Key('profile-appearance-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('profile-notifications-button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('profile-support-button')), findsOneWidget);
      expect(find.byKey(const Key('profile-legal-button')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile-sign-out')),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile-sign-out')), findsOneWidget);
      expect(find.text('Create a listing'), findsNothing);
      expect(find.text('My listings'), findsNothing);
      expect(find.text('Transactions'), findsNothing);
    },
  );

  testWidgets('onboarding skip persists state and routes to guest account', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: OnboardingScreen(step: 1),
          ),
        ),
        GoRoute(
          path: '/guest/account',
          builder: (context, state) => const Scaffold(
            body: GuestAccountScreen(),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(routerShell(router));
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(GuestAccountScreen)),
    );
    expect(container.read(appPreferencesProvider).hasSeenOnboarding, isTrue);
    expect(find.byType(GuestAccountScreen), findsOneWidget);
  });

  testWidgets(
    'guest account hub exposes buyer, seller, admin, and utility actions',
    (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: GuestAccountScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/admin/sign-in',
            builder: (context, state) => const Scaffold(
              body: Text('admin-entry'),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(routerShell(router));
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Admin access'), findsOneWidget);
      expect(
        find.byKey(const Key('guest-account-language-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('guest-account-appearance-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('guest-account-support-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('guest-account-legal-button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

      router.go('/');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Admin access'));
      await tester.pumpAndSettle();
      expect(find.text('admin-entry'), findsOneWidget);
    },
  );

  testWidgets(
    'guest support notifications route to guest account instead of raw sign in',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SupportHelpScreen(),
            ),
          ),
          GoRoute(
            path: '/guest/account',
            builder: (context, state) => const Scaffold(
              body: GuestAccountScreen(),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(routerShell(router));
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(GuestAccountScreen), findsOneWidget);
      expect(find.byType(SignInScreen), findsNothing);
    },
  );

  testWidgets(
    'authenticated support handoff routes to account settings in profile tree',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SupportHelpScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/settings',
            builder: (context, state) => const Scaffold(
              body: Text('profile-settings'),
            ),
          ),
          GoRoute(
            path: '/profile/legal',
            builder: (context, state) => const Scaffold(
              body: Text('profile-legal'),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(
        routerShell(router),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
      );
      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SupportHelpScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Account settings'));
      await tester.pumpAndSettle();
      expect(find.text('profile-settings'), findsOneWidget);
    },
  );

  testWidgets(
    'authenticated support handoff routes to legal in profile tree',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SupportHelpScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/settings',
            builder: (context, state) => const Scaffold(
              body: Text('profile-settings'),
            ),
          ),
          GoRoute(
            path: '/profile/legal',
            builder: (context, state) => const Scaffold(
              body: Text('profile-legal'),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(
        routerShell(router),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
      );
      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SupportHelpScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(FilledButton).last);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      expect(find.text('profile-legal'), findsOneWidget);
    },
  );

  testWidgets(
    'protected guest action sign in goes directly to sign in form',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, child) => Center(
                  child: FilledButton(
                    onPressed: () => showProtectedActionGate(
                      context,
                      ref,
                      intent: PostAuthRedirectIntent.action(
                        'save-listing',
                        arguments: const {'route': '/saved'},
                      ),
                    ),
                    child: const Text('Open gate'),
                  ),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/auth/sign-in',
            builder: (context, state) => const Scaffold(
              body: SignInScreen(),
            ),
          ),
        ],
      );

      final scope = await buildTestScope(routerShell(router));
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open gate'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    },
  );

  testWidgets('splash reopens home when guest browsing was persisted', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: SplashScreen()),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Text('guest-home'),
          ),
        ),
        GoRoute(
          path: '/guest/account',
          builder: (context, state) => const Scaffold(
            body: Text('guest-account'),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(
      routerShell(router),
      seed: const <String, Object>{
        'qitak.ui.onboarding_seen': true,
        'qitak.ui.guest_browsing_enabled': true,
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('guest-home'), findsOneWidget);
    expect(find.text('guest-account'), findsNothing);
  });
}

class _ThrowingSellerApplicationRepository
    implements SellerApplicationRepository {
  const _ThrowingSellerApplicationRepository();

  @override
  Future<SellerApplication?> fetchById(String applicationId) async {
    throw StateError('lookup failed');
  }

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async {
    throw StateError('lookup failed');
  }

  @override
  Future<List<SellerApplication>> listPendingApplications() async {
    throw StateError('lookup failed');
  }

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) async {
    throw StateError('lookup failed');
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required String status,
    String? reasonCode,
    String? note,
  }) async {
    throw StateError('lookup failed');
  }
}
