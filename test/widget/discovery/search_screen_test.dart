import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';
import 'package:qitak_app/features/discovery/presentation/search_screen.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/discovery/providers/search_history_provider.dart';

import '../../fixtures/discovery_filter_taxonomy_fixture.dart';
import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

void main() {
  Future<void> settleDiscovery(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('filters marketplace results from the explicit results route', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen(initialQuery: 'Brake')),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(find.text('Brake pad set'), findsOneWidget);
    expect(find.text('Headlight assembly'), findsNothing);
    expect(
      find.byKey(const Key('search-results-filter-button')),
      findsOneWidget,
    );
    expect(find.textContaining('1 matches'), findsOneWidget);
  });

  testWidgets('applied structured filters affect results', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen(initialQuery: 'Brake')),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SearchScreen)),
    );
    container.read(searchFilterProvider.notifier).appliedFilters =
        const SearchFilterState(categoryId: 'braking', makeId: 'Renault');
    await settleDiscovery(tester);

    expect(find.text('Brake pad set'), findsOneWidget);
    expect(find.text('Headlight assembly'), findsNothing);
    expect(find.text('Renault'), findsOneWidget);
  });

  testWidgets('buyer search results expose a direct save action', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen(initialQuery: 'Headlight')),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await ProviderScope.containerOf(
      tester.element(find.byType(SearchScreen)),
    ).read(authSessionProvider.notifier).restore();
    await settleDiscovery(tester);

    final saveButton = find.byKey(const Key('search-result-save-listing-1'));
    expect(saveButton, findsOneWidget);

    final buttonWidget = tester.widget<IconButton>(saveButton);
    expect(buttonWidget.onPressed, isNotNull);
  });

  testWidgets('guest search results still expose protected save action', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen(initialQuery: 'Headlight')),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    final saveButton = find.byKey(const Key('search-result-save-listing-1'));
    expect(saveButton, findsOneWidget);

    final buttonWidget = tester.widget<IconButton>(saveButton);
    expect(buttonWidget.onPressed, isNotNull);
  });

  testWidgets('empty search shows recent history and clear action', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen()),
      ),
      seed: const <String, Object>{
        'search_history': '["Headlight","Brake"]',
      },
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(find.text('Recent searches'), findsWidgets);
    expect(find.text('Headlight'), findsOneWidget);
    expect(find.text('Brake'), findsOneWidget);
    expect(find.text('Clear history'), findsOneWidget);
  });

  testWidgets('typing debounces then persists recent search', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SearchScreen()),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    await tester.enterText(
      find.byKey(const Key('search-results-field')),
      'Brake',
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('1 matches'), findsNothing);

    await tester.pump(const Duration(milliseconds: 150));
    await settleDiscovery(tester);
    expect(find.textContaining('1 matches'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SearchScreen)),
    );
    final history = container.read(searchHistoryProvider).asData?.value ?? [];
    expect(history.first, 'Brake');
  });
}
