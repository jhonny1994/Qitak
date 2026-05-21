import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';

import '../../test/fixtures/seeded_discovery_repository.dart';
import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buyer creates transaction intent from discovery listing', (
    tester,
  ) async {
    final app = await buildTestScope(
      const QitakApp(),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QitakApp)),
    );
    container.read(goRouterProvider).go('/transactions/listing/listing-1/new');
    await tester.pumpAndSettle();

    final startButton = find.byKey(const Key('transaction-start-button'));
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsWidgets);
  });
}
