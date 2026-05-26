import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/presentation/listing_detail_screen.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

import '../../fixtures/fake_discovery_repository.dart';
import '../../fixtures/listing_media_fixture.dart';
import '../../fixtures/seeded_discovery_repository.dart';
import '../../support/slice_test_bootstrap.dart';

void main() {
  testWidgets('renders production-style listing detail from discovery data', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(
          body: ListingDetailScreen(listingId: 'listing-1'),
        ),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Headlight assembly'), findsWidgets);
    expect(find.byType(QitakSignalStrip), findsWidgets);
    expect(find.byType(QitakListingGallery), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero && widget.tag == qitakListingHeroTag('listing-1'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Description'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Part details'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Peugeot'), findsWidgets);
    expect(find.text('308'), findsOneWidget);
    expect(find.text('2018'), findsWidgets);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
  });

  testWidgets('guest buyer actions stay gated from listing detail', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(
          body: ListingDetailScreen(listingId: 'listing-1'),
        ),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Message seller'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Message seller'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Message seller'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to message the seller'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('shows unavailable state when listing cannot be resolved', (
    tester,
  ) async {
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(
          body: ListingDetailScreen(listingId: 'missing'),
        ),
      ),
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(
          seededDiscoveryRepository,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Listing unavailable'), findsWidgets);
  });

  testWidgets('passes ordered media urls into listing gallery', (tester) async {
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(
          body: ListingDetailScreen(listingId: 'listing-media'),
        ),
      ),
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
                mediaUrls: [
                  testListingMediaDataUri,
                  'https://example.com/second.png',
                ],
              ),
            ],
          ),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final gallery = tester.widget<QitakListingGallery>(
      find.byType(QitakListingGallery),
    );
    expect(gallery.primaryImageUrl, testListingMediaDataUri);
    expect(gallery.imageUrls, ['https://example.com/second.png']);
  });
}
