import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-up route can create buyer account', (tester) async {
    final app = await buildQitakApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QitakApp)),
    );
    container.read(goRouterProvider).go('/auth/sign-up');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Karim Test');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'newbuyer@qitak.test',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '+213555555555');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password1!');
    await tester.enterText(find.byType(TextFormField).at(4), 'Password1!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    final submit = find.byType(FilledButton).first;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final session = container.read(authSessionProvider);
    expect(session.isAuthenticated, isTrue);
    expect(session.profile?.email, 'newbuyer@qitak.test');
  });
}
