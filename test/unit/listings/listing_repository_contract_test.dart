import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'local listing repository draft submission returns draft status',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalListingRepository(prefs, _sellerProfile);

      final result = await repository.submitListing(
        draft: _draft,
        action: ListingWorkflowAction.saveDraft,
      );

      expect(result.listingId, isNotEmpty);
      expect(result.status, 'draft');
    },
  );

  test(
    'local listing repository submit submission returns pending review',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalListingRepository(prefs, _sellerProfile);

      final result = await repository.submitListing(
        draft: _draft,
        action: ListingWorkflowAction.submit,
      );

      expect(result.listingId, isNotEmpty);
      expect(result.status, 'pending_review');
    },
  );
}

const AccountProfile _sellerProfile = AccountProfile(
  id: 'seller-001',
  fullName: 'Samir Auto Parts',
  email: 'seller@qitak.test',
  phone: '+213555000222',
  role: AccountRole.seller,
  language: 'ar',
  isActive: true,
);

const ListingDraft _draft = ListingDraft(
  title: 'Headlight assembly',
  categoryId: 'lighting',
  brandCode: 'Audi',
  modelCode: 'TT Coupe',
  year: 2018,
  price: 18500,
  quantity: 1,
  condition: 'like_new',
  description: 'Clear lens and working mounts.',
  exchangeEnabled: false,
  wilayaCode: '16',
  communeCode: '1601',
);
