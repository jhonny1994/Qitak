import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/admin/presentation/seller_verification_queue_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('seller verification queue renders empty state', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerVerificationQueueScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Seller verification queue'), findsOneWidget);
    expect(find.text('Queue is empty'), findsOneWidget);
  });

  testWidgets('admin team renders invite action surface', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: AdminTeamScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'superadmin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Admin team'), findsOneWidget);
    expect(find.byKey(const Key('admin-team-invite-button')), findsOneWidget);
  });
}
