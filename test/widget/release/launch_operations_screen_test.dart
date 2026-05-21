import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/presentation/launch_operations_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('shows launch gate coverage before checklist execution', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: LaunchOperationsScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Launch gate coverage'), findsOneWidget);
    expect(find.text('Analyzer and static checks'), findsOneWidget);
    expect(find.text('Widget and route test sweep'), findsOneWidget);
    expect(find.text('Integration coverage'), findsOneWidget);
    expect(find.text('Database policy checks'), findsOneWidget);
  });
}
