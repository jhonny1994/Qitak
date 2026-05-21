import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/release/presentation/release_readiness_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('release readiness screen uses localized runtime warning copy', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ReleaseReadinessScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReleaseReadinessScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'This screen does not execute Flutter or Supabase gates at runtime.',
      ),
      findsOneWidget,
    );
  });
}
