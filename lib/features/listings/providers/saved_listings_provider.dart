import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/data/saved_listings_repository.dart';

final savedListingIdsProvider =
    AsyncNotifierProvider<SavedListingIdsNotifier, Set<String>>(
      SavedListingIdsNotifier.new,
    );

final savedListingsProvider = FutureProvider<List<MarketplaceListing>>((
  ref,
) async {
  final ids = (await ref.watch(savedListingIdsProvider.future)).toList(
    growable: false,
  );
  if (ids.isEmpty) {
    return const <MarketplaceListing>[];
  }

  final repository = ref.watch(discoveryRepositoryProvider);
  final items = await Future.wait<MarketplaceListing?>(
    ids.map(repository.fetchListingById),
  );
  return items.whereType<MarketplaceListing>().toList(growable: false);
});
