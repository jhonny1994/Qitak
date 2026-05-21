import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/admin_queues_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('admin queues screen lists the operational queue routes', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: AdminQueuesScreen()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Queues'), findsOneWidget);
    expect(find.text('Seller verification queue'), findsOneWidget);
    expect(find.text('Listing moderation queue'), findsOneWidget);
    expect(find.text('Disputes queue'), findsOneWidget);
  });
}
