import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/discovery/data/discovery_filter_taxonomy_repository.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';

class SearchFilterNotifier extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() => const SearchFilterState();

  SearchFilterState get appliedFilters => state;

  set appliedFilters(SearchFilterState next) {
    state = next;
  }

  void resetFilters() {
    state = const SearchFilterState();
  }
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilterState>(
      SearchFilterNotifier.new,
    );

final discoveryFilterTaxonomyProvider = FutureProvider<DiscoveryFilterTaxonomy>(
  (ref) {
    return ref.read(discoveryFilterTaxonomyRepositoryProvider).load();
  },
);
