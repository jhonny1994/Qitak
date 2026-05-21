import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';

import '../test_bootstrap.dart';

void main() {
  testWidgets('auth sign in screen meets tap target and label guidance', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SignInScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
