import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/auth/presentation/auth_surface_switcher.dart';
import 'package:qitak_app/features/auth/presentation/sign_in_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/discovery/presentation/search_screen.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/notifications/presentation/notification_center_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_onboarding_screen.dart';

import '../fixtures/discovery_filter_taxonomy_fixture.dart';
import '../fixtures/fake_discovery_repository.dart';
import '../fixtures/listing_media_fixture.dart';
import '../support/slice_test_bootstrap.dart';
import '../test_bootstrap.dart';

const _approvedApplication = SellerApplication(
  id: 'seller-app-seller-001',
  userId: 'seller-001',
  sellerType: 'business',
  businessName: 'Samir Auto Parts',
  phone: '+213555000222',
  email: 'seller@qitak.test',
  wilayaId: '1',
  communeId: '1001',
  bio: 'Verified seller profile',
  verificationStatus: SellerVerificationStatus.approved,
);

const _visualListings = <MarketplaceListing>[
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
    primaryImageUrl: testListingMediaDataUri,
    mediaUrls: [testListingMediaDataUri],
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
    primaryImageUrl: testListingMediaDataUri,
    mediaUrls: [testListingMediaDataUri],
  ),
];

const _visualDiscoveryRepository = FakeDiscoveryRepository(
  listings: _visualListings,
);

Future<void> _prepareViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _restoreSessionFor<T extends Widget>(WidgetTester tester) async {
  final container = ProviderScope.containerOf(tester.element(find.byType(T)));
  await container.read(authSessionProvider.notifier).restore();
  await tester.pumpAndSettle();
}

Future<void> _captureScaffold(
  WidgetTester tester,
  String goldenName,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await expectLater(
    find.byType(Scaffold).first,
    matchesGoldenFile('goldens/$goldenName'),
  );
}

Future<void> _captureScaffoldInBothThemes(
  WidgetTester tester, {
  required String goldenBaseName,
  required Future<void> Function(ThemeMode mode) pumpForMode,
}) async {
  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpForMode(mode);
    final suffix = mode == ThemeMode.light ? 'light' : 'dark';
    await _captureScaffold(tester, '$goldenBaseName-$suffix.png');
  }
}

void main() {
  testWidgets('captures auth surface switcher', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'auth-surface-switcher',
      pumpForMode: (mode) async {
        final switcherScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: AuthSurfaceSwitcher(
                    isSellerRole: false,
                    onBuyerRole: () {},
                    onSellerRole: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(switcherScope);
      },
    );
  });

  testWidgets('captures sign in screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'sign-in-screen',
      pumpForMode: (mode) async {
        final signInScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SignInScreen()),
          ),
        );

        await tester.pumpWidget(signInScope);
      },
    );
  });

  testWidgets('captures home screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'home-screen',
      pumpForMode: (mode) async {
        final homeScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: HomeScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              _visualDiscoveryRepository,
            ),
          ],
        );

        await tester.pumpWidget(homeScope);
        await _restoreSessionFor<HomeScreen>(tester);
      },
    );
  });

  testWidgets('captures search screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'search-screen',
      pumpForMode: (mode) async {
        final searchScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: SearchScreen(initialQuery: 'Headlight'),
            ),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              _visualDiscoveryRepository,
            ),
            discoveryFilterTaxonomyProvider.overrideWith(
              (ref) => Future.value(testDiscoveryFilterTaxonomy),
            ),
          ],
        );

        await tester.pumpWidget(searchScope);
        await _restoreSessionFor<SearchScreen>(tester);
      },
    );
  });

  testWidgets('captures listing detail surface', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'listing-detail-screen',
      pumpForMode: (mode) async {
        final scope = await buildSliceTestScope(
          SliceTestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: ListingDetailScreen(listingId: 'listing-1'),
            ),
          ),
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              _visualDiscoveryRepository,
            ),
          ],
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures listing form surface', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'listing-form-screen',
      pumpForMode: (mode) async {
        final scope = await buildSliceTestScope(
          SliceTestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ListingFormScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
          },
          overrides: [
            discoveryFilterTaxonomyProvider.overrideWith(
              (ref) => Future.value(testDiscoveryFilterTaxonomy),
            ),
            currentSellerApplicationProvider.overrideWith(
              (ref) async => _approvedApplication,
            ),
          ],
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures seller onboarding surface', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'seller-onboarding-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SellerOnboardingScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
          },
          overrides: [
            discoveryFilterTaxonomyProvider.overrideWith((ref) async {
              return testDiscoveryFilterTaxonomy;
            }),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SellerOnboardingScreen>(tester);
        await tester.ensureVisible(
          find.byKey(const Key('seller-onboarding-next')),
        );
        await tester.tap(find.byKey(const Key('seller-onboarding-next')));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures notification center screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'notification-center-screen',
      pumpForMode: (mode) async {
        final notificationScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: NotificationCenterScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(notificationScope);
      },
    );
  });

  testWidgets('captures admin team screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'admin-team-screen',
      pumpForMode: (mode) async {
        final adminScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: AdminTeamScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'superadmin@qitak.test',
          },
        );

        await tester.pumpWidget(adminScope);
      },
    );
  });
}
