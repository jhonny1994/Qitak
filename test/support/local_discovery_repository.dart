import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';
import 'package:qitak_app/features/listings/data/local_listing_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDiscoveryRepository implements DiscoveryRepository {
  LocalDiscoveryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _seedListings = <MarketplaceListing>[
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
      primaryImageUrl:
          'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=1200&q=80',
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
      primaryImageUrl:
          'https://images.unsplash.com/photo-1613214150384-4d85f8fd7d23?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  @override
  bool get isLocal => true;

  @override
  Future<List<MarketplaceListing>> fetchListings({
    required int minimumRating,
  }) async {
    final storedListings = LocalListingStore(
      _prefs,
    ).readAll().map((item) => item.toMarketplaceListing());
    return [...storedListings, ..._seedListings]
        .where((listing) => listing.rating >= minimumRating)
        .toList(growable: false);
  }

  @override
  Future<List<MarketplaceListing>> searchListings({
    required int minimumRating,
    required String query,
    required SearchFilterState filters,
  }) async {
    final listings = await fetchListings(minimumRating: minimumRating);
    final normalizedQuery = query.trim().toLowerCase();
    return listings
        .where((item) {
          if (normalizedQuery.isNotEmpty) {
            final haystack = [
              item.title,
              item.description,
              item.communeCode ?? '',
              item.wilayaCode ?? '',
              item.brand ?? '',
              item.model ?? '',
              item.categoryCode,
            ].join(' ').toLowerCase();
            if (!haystack.contains(normalizedQuery)) {
              return false;
            }
          }
          if (filters.categoryId != null &&
              item.categoryId != filters.categoryId) {
            return false;
          }
          if (filters.wilayaId != null && item.wilayaCode != filters.wilayaId) {
            return false;
          }
          if (filters.communeId != null &&
              item.communeCode != filters.communeId) {
            return false;
          }
          if (filters.makeId != null &&
              item.brand?.toLowerCase() != filters.makeId!.toLowerCase()) {
            return false;
          }
          if (filters.baseModel != null &&
              item.model?.toLowerCase() != filters.baseModel!.toLowerCase()) {
            return false;
          }
          if (filters.year != null && item.year != filters.year) {
            return false;
          }
          if (filters.condition != null &&
              item.conditionCode != filters.condition) {
            return false;
          }
          if (filters.dealType == 'buy_or_exchange' && !item.exchangeAllowed) {
            return false;
          }
          final price = item.priceAmount;
          if (filters.priceMin != null && price < filters.priceMin!) {
            return false;
          }
          if (filters.priceMax != null && price > filters.priceMax!) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  Future<MarketplaceListing?> fetchListingById(String listingId) async {
    for (final listing in LocalListingStore(
      _prefs,
    ).readAll().map((item) => item.toMarketplaceListing())) {
      if (listing.id == listingId) {
        return listing;
      }
    }
    for (final listing in _seedListings) {
      if (listing.id == listingId) {
        return listing;
      }
    }
    return null;
  }
}
