import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

import '../../fixtures/discovery_filter_taxonomy_fixture.dart';
import '../../fixtures/fake_discovery_repository.dart';
import '../../support/slice_test_bootstrap.dart';

void main() {
  const seededDiscoveryRepository = FakeDiscoveryRepository(
    listings: [
      MarketplaceListing(
        id: 'listing-1',
        sellerUserId: 'seller-001',
        title: 'Headlight assembly',
        priceAmount: 18500,
        sellerLabelCode: 'seller_label_verified',
        rating: 4.8,
        threadId: 'l1',
        transactionId: 't1',
        categoryId: 'lighting',
        categoryCode: 'lighting',
        conditionCode: 'like_new',
        description:
            'Verified fitment listing with clear lens condition and working mounts.',
        memberSinceLabel: 'Since 2023',
        exchangeAllowed: true,
        wilayaCode: '16',
        communeCode: '1601',
        brand: 'Peugeot',
        model: '308',
        year: 2018,
        sellerName: 'Samir Auto Parts',
        primaryImageUrl: 'https://example.com/headlight.png',
      ),
      MarketplaceListing(
        id: 'listing-2',
        sellerUserId: 'seller-001',
        title: 'Brake pad set',
        priceAmount: 7500,
        sellerLabelCode: 'seller_label_business',
        rating: 4.1,
        threadId: 'l2',
        transactionId: 't2',
        categoryId: 'braking',
        categoryCode: 'braking',
        conditionCode: 'new',
        description:
            'Fresh stock brake pad kit for one fitment target, ready for pickup.',
        memberSinceLabel: 'Since 2022',
        wilayaCode: '31',
        communeCode: '3104',
        brand: 'Renault',
        model: 'Symbol',
        year: 2016,
        sellerName: 'Samir Auto Parts',
        primaryImageUrl: 'https://example.com/brakes.png',
      ),
    ],
  );

  List<Object> defaultOverrides() => [
    discoveryRepositoryProvider.overrideWithValue(seededDiscoveryRepository),
  ];

  Future<void> settleDiscovery(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Widget buildShell(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  Finder filterField(String prefix) => find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith(prefix),
  );

  testWidgets('renders local seeded marketplace feed', (tester) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: defaultOverrides(),
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(find.byKey(const Key('home-search-field')), findsOneWidget);
    expect(find.byKey(const Key('home-filter-button')), findsOneWidget);
    expect(find.byKey(const Key('home-search-button')), findsOneWidget);
    expect(find.text('Featured listings'), findsOneWidget);
    expect(find.text('Headlight assembly'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Latest listings'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Latest listings'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Brake pad set'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Brake pad set'), findsOneWidget);
    expect(find.text('Local development feed'), findsNothing);
    expect(find.text('Engine'), findsNothing);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('renders loading skeletons before discovery data resolves', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          const FakeDiscoveryRepository(delay: Duration(milliseconds: 300)),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pump();

    expect(find.byType(QitakSkeletonBox), findsWidgets);
    expect(find.text('No listings yet'), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('renders production-safe empty state when no listings exist', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          const FakeDiscoveryRepository(),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(find.text('No listings yet'), findsOneWidget);
    expect(
      find.text(
        'When the production marketplace has active stock, listings will appear here.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders retryable error state when discovery fails', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          FakeDiscoveryRepository(error: StateError('boom')),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text(
        'We could not load marketplace listings. Try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('anonymous marketplace actions open the protected action gate', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: defaultOverrides(),
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    final button = find.byKey(const Key('home-featured-save-button'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Sign in to save this listing'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('authenticated home shows save affordance on featured listing', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: defaultOverrides(),
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await settleDiscovery(tester);

    expect(find.byKey(const Key('home-featured-save-button')), findsOneWidget);
  });

  testWidgets('listing cards expose hero tags for detail transition', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: defaultOverrides(),
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero && widget.tag == qitakListingHeroTag('listing-1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('featured listing uses media url when discovery provides one', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          const FakeDiscoveryRepository(
            listings: [
              MarketplaceListing(
                id: 'listing-media',
                sellerUserId: 'seller-001',
                title: 'Media listing',
                priceAmount: 18500,
                sellerLabelCode: 'seller_label_verified',
                rating: 4.8,
                threadId: 'l1',
                transactionId: 't1',
                categoryCode: 'lighting',
                conditionCode: 'like_new',
                mediaUrls: ['https://example.com/headlight.png'],
              ),
            ],
          ),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    final surface = tester.widget<QitakListingSurface>(
      find.byType(QitakListingSurface),
    );
    expect(surface.imageUrl, 'https://example.com/headlight.png');
  });

  testWidgets('categories are not exposed as persistent home chips', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: defaultOverrides(),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Lighting'), findsNothing);
    expect(find.text('Brakes'), findsNothing);
    expect(find.text('Wilaya'), findsNothing);
  });

  testWidgets('filter button opens the structured filter sheet shell', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      buildShell(const HomeScreen()),
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await settleDiscovery(tester);

    await tester.tap(find.byKey(const Key('home-filter-button')));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
  });

  testWidgets(
    'filter sheet applies wilaya -> commune and make -> model -> year dependencies',
    (
      tester,
    ) async {
      final scope = await buildSliceTestScope(
        buildShell(const HomeScreen()),
        overrides: [
          discoveryFilterTaxonomyProvider.overrideWith(
            (ref) => Future.value(testDiscoveryFilterTaxonomy),
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await settleDiscovery(tester);

      await tester.tap(find.byKey(const Key('home-filter-button')));
      await tester.pumpAndSettle();

      final communeFieldBefore = tester.widget<QitakDropdownField<String>>(
        filterField('filter-commune-field'),
      );
      final modelFieldBefore = tester.widget<QitakDropdownField<String>>(
        filterField('filter-model-field'),
      );
      final yearFieldBefore = tester.widget<QitakDropdownField<int>>(
        filterField('filter-year-field'),
      );
      expect(communeFieldBefore.onChanged, isNull);
      expect(modelFieldBefore.onChanged, isNull);
      expect(yearFieldBefore.onChanged, isNull);

      await tester.tap(filterField('filter-wilaya-field'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adrar').last);
      await tester.pumpAndSettle();

      final communeFieldAfterWilaya = tester.widget<QitakDropdownField<String>>(
        filterField('filter-commune-field'),
      );
      expect(communeFieldAfterWilaya.onChanged, isNotNull);
      await tester.tap(filterField('filter-commune-field'));
      await tester.pumpAndSettle();
      expect(find.text('Adrar').last, findsOneWidget);
      await tester.tap(find.text('Adrar').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(filterField('filter-make-field'));
      await tester.pumpAndSettle();
      await tester.tap(filterField('filter-make-field'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Audi').last);
      await tester.pumpAndSettle();

      final modelFieldAfterMake = tester.widget<QitakDropdownField<String>>(
        filterField('filter-model-field'),
      );
      expect(modelFieldAfterMake.onChanged, isNotNull);

      await tester.ensureVisible(filterField('filter-model-field'));
      await tester.pumpAndSettle();
      await tester.tap(filterField('filter-model-field'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TT Coupe').last);
      await tester.pumpAndSettle();

      final yearFieldAfterModel = tester.widget<QitakDropdownField<int>>(
        filterField('filter-year-field'),
      );
      expect(yearFieldAfterModel.onChanged, isNotNull);

      await tester.ensureVisible(find.byKey(const Key('filter-apply-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter-apply-button')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      final filters = container.read(searchFilterProvider);
      expect(filters.wilayaId, '1');
      expect(filters.communeId, '1001');
      expect(filters.makeId, 'Audi');
      expect(filters.baseModel, 'TT Coupe');
    },
  );
}
