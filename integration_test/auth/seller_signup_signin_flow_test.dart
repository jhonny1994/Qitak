import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-up route can create seller account', (tester) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{'qitak.ui.onboarding_seen': true},
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QitakApp)),
    );
    // Seller sign-up uses the dedicated seller route.
    container.read(goRouterProvider).go('/auth/seller/sign-up');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Samir Boudiaf');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'newseller@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '+213666777888');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password1!');
    await tester.enterText(find.byType(TextFormField).at(4), 'Password1!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    // Wait for Android soft-keyboard close animation (OS-level, not caught by pumpAndSettle).
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final checkbox = find.byType(CheckboxListTile);
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    final submit = find.byType(FilledButton).last;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final session = container.read(authSessionProvider);
    expect(session.isAuthenticated, isTrue);
    expect(session.profile?.email, 'newseller@qitak.test');
    expect(session.profile?.role, AccountRole.seller);
  });

  testWidgets('sign-in with seeded seller credentials succeeds', (
    tester,
  ) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{'qitak.ui.onboarding_seen': true},
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QitakApp)),
    );
    container.read(goRouterProvider).go('/auth/seller/sign-in');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'seller@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    // Wait for Android soft-keyboard close animation (OS-level, not caught by pumpAndSettle).
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final submit = find.byType(FilledButton).last;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final session = container.read(authSessionProvider);
    expect(session.isAuthenticated, isTrue);
    expect(session.profile?.role, AccountRole.seller);
  });

  testWidgets(
    'sign-in with wrong password shows error and stays unauthenticated',
    (
      tester,
    ) async {
      final app = await buildQitakApp(
        seed: const <String, Object>{'qitak.ui.onboarding_seen': true},
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      container.read(goRouterProvider).go('/auth/sign-in');
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'buyer@qitak.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final submit = find.byType(FilledButton).first;
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isFalse);
    },
  );
}
