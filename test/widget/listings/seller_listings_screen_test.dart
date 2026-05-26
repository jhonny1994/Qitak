import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/features/listings/presentation/seller_listings_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../fixtures/seeded_discovery_repository.dart';
import '../../test_bootstrap.dart';

class _FakeSellerListingsRepository implements SellerListingsRepository {
  _FakeSellerListingsRepository(this.items);

  final List<SellerManagedListing> items;
  final List<({String listingId, String action})> actions =
      <({String listingId, String action})>[];

  @override
  Future<void> applyAction({
    required String listingId,
    required String action,
  }) async {
    actions.add((listingId: listingId, action: action));
  }

  @override
  Future<List<SellerManagedListing>> listForSeller(String sellerUserId) async {
    return items;
  }

  @override
  Future<SellerManagedListing?> fetchById(String listingId) async {
    for (final item in items) {
      if (item.id == listingId) {
        return item;
      }
    }
    return null;
  }
}

void main() {
  testWidgets('localizes seeded seller inventory labels in Arabic', (
    tester,
  ) async {
    final scope = await buildTestScope(
      MaterialApp(
        locale: const Locale('ar'),
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
        home: const Scaffold(body: SellerListingsScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        sellerListingsRepositoryProvider.overrideWithValue(
          _FakeSellerListingsRepository([
            SellerManagedListing(
              id: 'listing-owned',
              title: 'Headlight assembly',
              status: 'active',
              price: 18500,
              categoryId: 'lighting',
              condition: 'Like new',
              primaryImageUrl: null,
              updatedAt: DateTime(2026, 5, 19),
            ),
          ]),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerListingsScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Headlight assembly'), findsOneWidget);
    expect(find.text('نشطة'), findsWidgets);
    expect(find.textContaining('آخر تحديث'), findsOneWidget);
  });

  testWidgets(
    'seller-owned preview hides buyer actions and exposes edit listing',
    (
      tester,
    ) async {
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(
            body: ListingDetailScreen(
              listingId: 'listing-1',
              sellerOwnedPreview: true,
            ),
          ),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
          sellerListingsRepositoryProvider.overrideWithValue(
            _FakeSellerListingsRepository([
              const SellerManagedListing(
                id: 'listing-1',
                title: 'Headlight assembly',
                status: 'rejected',
                price: 18500,
                categoryId: 'lighting',
                condition: 'Like new',
                primaryImageUrl: null,
              ),
            ]),
          ),
        ],
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ListingDetailScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('My listing'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Edit listing'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Edit listing'), findsOneWidget);
      expect(find.text('Message seller'), findsNothing);
      expect(find.text('Request to buy'), findsNothing);
      expect(find.text('Rejected'), findsWidgets);
    },
  );

  testWidgets('seller listings only show owned inventory rows', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerListingsScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        sellerListingsRepositoryProvider.overrideWithValue(
          _FakeSellerListingsRepository([
            const SellerManagedListing(
              id: 'listing-owned',
              title: 'Headlight assembly',
              status: 'active',
              price: 18500,
              categoryId: 'lighting',
              condition: 'Like new',
              primaryImageUrl: null,
            ),
          ]),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerListingsScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Headlight assembly'), findsOneWidget);
    expect(find.text('Foreign alternator'), findsNothing);
  });

  testWidgets('draft deletion waits for confirmation before applying action', (
    tester,
  ) async {
    final repository = _FakeSellerListingsRepository([
      const SellerManagedListing(
        id: 'draft-1',
        title: 'Draft listing',
        status: 'draft',
        price: 12000,
        categoryId: 'lighting',
        condition: 'Like new',
        primaryImageUrl: null,
      ),
    ]);

    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerListingsScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        sellerListingsRepositoryProvider.overrideWithValue(repository),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerListingsScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Drafts'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.widgetWithText(OutlinedButton, 'Delete'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Delete'))
        .onPressed!
        .call();
    await tester.pumpAndSettle();

    expect(find.text('Delete listing'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.actions, isEmpty);

    await tester.dragUntilVisible(
      find.widgetWithText(OutlinedButton, 'Delete'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    tester
        .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Delete'))
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      repository.actions,
      [
        (
          listingId: 'draft-1',
          action: 'delete_draft',
        ),
      ],
    );
  });

  testWidgets('empty seller inventory exposes create listing action', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SellerListingsScreen(),
          ),
        ),
        GoRoute(
          path: '/seller/listings/new',
          builder: (context, state) => const Scaffold(
            body: Text('create-listing-screen'),
          ),
        ),
      ],
    );

    final scope = await buildTestScope(
      MaterialApp.router(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        sellerListingsRepositoryProvider.overrideWithValue(
          _FakeSellerListingsRepository([]),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerListingsScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create listing').last);
    await tester.pumpAndSettle();

    expect(find.text('create-listing-screen'), findsOneWidget);
  });
}
