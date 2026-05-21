import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('sign in dismisses keyboard when submit is tapped', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).first;
    await tester.tap(emailField);
    await tester.pumpAndSettle();
    await tester.showKeyboard(emailField);
    await tester.pump();

    final emailElement = tester.element(emailField);
    expect(FocusScope.of(emailElement).hasFocus, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in').last);
    await tester.pumpAndSettle();

    expect(FocusScope.of(emailElement).hasFocus, isFalse);
  });
}
