import 'package:flutter/foundation.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';

@immutable
class DiscoverySearchRequest {
  const DiscoverySearchRequest({
    required this.minimumRating,
    this.query = '',
    this.filters = const SearchFilterState(),
  });

  final int minimumRating;
  final String query;
  final SearchFilterState filters;

  @override
  bool operator ==(Object other) {
    return other is DiscoverySearchRequest &&
        other.minimumRating == minimumRating &&
        other.query == query &&
        other.filters.categoryId == filters.categoryId &&
        other.filters.wilayaId == filters.wilayaId &&
        other.filters.communeId == filters.communeId &&
        other.filters.makeId == filters.makeId &&
        other.filters.baseModel == filters.baseModel &&
        other.filters.year == filters.year &&
        other.filters.priceMin == filters.priceMin &&
        other.filters.priceMax == filters.priceMax &&
        other.filters.condition == filters.condition &&
        other.filters.dealType == filters.dealType &&
        other.filters.sort == filters.sort;
  }

  @override
  int get hashCode => Object.hash(
    minimumRating,
    query,
    filters.categoryId,
    filters.wilayaId,
    filters.communeId,
    filters.makeId,
    filters.baseModel,
    filters.year,
    filters.priceMin,
    filters.priceMax,
    filters.condition,
    filters.dealType,
    filters.sort,
  );
}
