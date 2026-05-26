import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';

class FakeDiscoveryRepository implements DiscoveryRepository {
  const FakeDiscoveryRepository({
    this.isLocal = false,
    this.listings = const <MarketplaceListing>[],
    this.delay = Duration.zero,
    this.error,
  });

  @override
  final bool isLocal;

  final List<MarketplaceListing> listings;
  final Duration delay;
  final Object? error;

  @override
  Future<List<MarketplaceListing>> fetchListings({
    required int minimumRating,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (error != null) {
      final failure = error!;
      if (failure is Error) {
        throw failure;
      }
      if (failure is Exception) {
        throw failure;
      }
      throw StateError(
        'FakeDiscoveryRepository received a non-throwable error.',
      );
    }
    return listings
        .where((listing) => listing.rating >= minimumRating)
        .toList(growable: false);
  }

  @override
  Future<List<MarketplaceListing>> searchListings({
    required int minimumRating,
    required String query,
    required SearchFilterState filters,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    return (await fetchListings(minimumRating: minimumRating))
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
    for (final listing in listings) {
      if (listing.id == listingId) {
        return listing;
      }
    }
    return null;
  }
}
