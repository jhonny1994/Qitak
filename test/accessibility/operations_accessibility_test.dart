import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';

import '../test_bootstrap.dart';

void main() {
  testWidgets('admin team surface meets tap target guidance', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: AdminTeamScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });
}
