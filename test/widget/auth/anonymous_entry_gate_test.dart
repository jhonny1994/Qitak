import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  testWidgets('anonymous buyer action opens auth gate', (tester) async {
    final app = await buildTestScope(
      const TestMaterialShell(child: Scaffold(body: HomeScreen())),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('home-featured-save-button'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Sign in to save this listing'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
