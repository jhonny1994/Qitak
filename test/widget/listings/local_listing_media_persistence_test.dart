import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/listing_media_fixture.dart';

void main() {
  test(
    'local listing repository persists media for discovery surfaces',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalListingRepository(
        prefs,
        const AccountProfile(
          id: 'seller-001',
          fullName: 'Samir Auto Parts',
          email: 'seller@qitak.test',
          phone: '+213555000222',
          role: AccountRole.seller,
          language: 'ar',
          isActive: true,
        ),
      );
      final discoveryRepository = LocalDiscoveryRepository(prefs);

      await repository.submitListing(
        draft: ListingDraft(
          title: 'Audi headlight assembly',
          categoryId: 'lighting',
          brandCode: 'Audi',
          modelCode: 'TT Coupe',
          year: 2018,
          price: 18500,
          quantity: 2,
          condition: 'like_new',
          description: 'Clear lens and working mounts.',
          exchangeEnabled: true,
          wilayaCode: '1',
          communeCode: '1001',
          wilayaLabel: 'Adrar',
          communeLabel: 'Adrar',
          media: [
            ListingMediaSelection(
              fileName: 'headlight.png',
              mimeType: 'image/png',
              bytes: buildTestListingMediaBytes(),
            ),
          ],
        ),
        action: ListingWorkflowAction.saveDraft,
      );

      final listings = await discoveryRepository.fetchListings(
        minimumRating: 0,
      );
      final createdListing = listings.firstWhere(
        (item) => item.title == 'Audi headlight assembly',
      );

      expect(createdListing.mediaUrls, hasLength(1));
      expect(createdListing.primaryImageUrl, testListingMediaDataUri);
    },
  );
}
