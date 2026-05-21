import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';

// Stable family identity matters more than spelling out the long generated
// provider type here.
// ignore: specify_nonobvious_property_types
final discoveryListingsProvider =
    FutureProvider.family<List<MarketplaceListing>, int>((ref, minimumRating) {
      return ref
          .watch(discoveryRepositoryProvider)
          .fetchListings(minimumRating: minimumRating);
    });

// Stable family identity matters more than spelling out the long generated
// provider type here.
// ignore: specify_nonobvious_property_types
final discoveryListingProvider =
    FutureProvider.family<MarketplaceListing?, String>((ref, listingId) {
      return ref.watch(discoveryRepositoryProvider).fetchListingById(listingId);
    });

@immutable
class DiscoverySearchRequest {
  const DiscoverySearchRequest({
    required this.minimumRating,
    required this.query,
    required this.filters,
  });

  final int minimumRating;
  final String query;
  final SearchFilterState filters;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DiscoverySearchRequest &&
        other.minimumRating == minimumRating &&
        other.query == query &&
        other.filters == filters;
  }

  @override
  int get hashCode => Object.hash(minimumRating, query, filters);
}

// ignore: specify_nonobvious_property_types, stable family identity matters
final discoverySearchListingsProvider =
    FutureProvider.family<List<MarketplaceListing>, DiscoverySearchRequest>((
      ref,
      request,
    ) {
      return ref
          .watch(discoveryRepositoryProvider)
          .searchListings(
            minimumRating: request.minimumRating,
            query: request.query,
            filters: request.filters,
          );
    });
