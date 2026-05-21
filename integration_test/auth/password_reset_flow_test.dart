import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/features/auth/presentation/reset_password_screen.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('password reset shows non-enumerating success copy', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ResetPasswordScreen()),
      ),
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'missing@qitak.test');
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
  });
}
