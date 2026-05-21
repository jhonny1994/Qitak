import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';
import 'package:qitak_app/features/listings/data/local_listing_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DiscoveryRepository {
  const DiscoveryRepository();

  bool get isLocal;

  Future<List<MarketplaceListing>> fetchListings({
    required int minimumRating,
  });

  Future<List<MarketplaceListing>> searchListings({
    required int minimumRating,
    required String query,
    required SearchFilterState filters,
  });

  Future<MarketplaceListing?> fetchListingById(String listingId);
}

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for runtime discovery.');
  }
  return SupabaseDiscoveryRepository(client);
});

class LocalDiscoveryRepository implements DiscoveryRepository {
  LocalDiscoveryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _seedListings = <MarketplaceListing>[
    MarketplaceListing(
      id: 'listing-1',
      sellerUserId: 'seller-001',
      title: 'Headlight assembly',
      priceLabel: '18,500 DZD',
      locationLabel: 'Bab Ezzouar | Alger',
      fitmentLabel: 'Peugeot 308 | 2018',
      sellerLabel: 'Verified seller',
      rating: 4.8,
      threadId: 'l1',
      transactionId: 't1',
      categoryId: 'lighting',
      categoryLabel: 'Lighting',
      conditionLabel: 'Like new',
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
      priceLabel: '7,500 DZD',
      locationLabel: 'Bir El Djir | Oran',
      fitmentLabel: 'Renault Symbol | 2016',
      sellerLabel: 'Business seller',
      rating: 4.1,
      threadId: 'l2',
      transactionId: 't2',
      categoryId: 'braking',
      categoryLabel: 'Brakes',
      conditionLabel: 'New',
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
              item.locationLabel,
              item.fitmentLabel,
              item.categoryLabel,
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
              _conditionIdForListing(item.conditionLabel) !=
                  filters.condition) {
            return false;
          }
          if (filters.dealType == 'buy_or_exchange' && !item.exchangeAllowed) {
            return false;
          }
          final price = _parsePrice(item.priceLabel);
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

  String _conditionIdForListing(String conditionLabel) {
    switch (conditionLabel.toLowerCase()) {
      case 'new':
        return 'new';
      case 'like new':
        return 'like_new';
      case 'used':
        return 'used';
      default:
        return conditionLabel.toLowerCase();
    }
  }

  int _parsePrice(String priceLabel) {
    final digits = priceLabel.replaceAll(RegExp('[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}

class SupabaseDiscoveryRepository implements DiscoveryRepository {
  SupabaseDiscoveryRepository(this._client);

  final SupabaseClient _client;
  static const _pageSize = 200;

  @override
  bool get isLocal => false;

  @override
  Future<List<MarketplaceListing>> fetchListings({
    required int minimumRating,
  }) async {
    final lookupsFuture = _fetchLookups();
    final rowsFuture = _fetchListingRows();
    final lookups = await lookupsFuture;
    final rows = await rowsFuture;

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => _mapListingRow(row, lookups))
        .toList(growable: false);
  }

  @override
  Future<List<MarketplaceListing>> searchListings({
    required int minimumRating,
    required String query,
    required SearchFilterState filters,
  }) async {
    final lookupsFuture = _fetchLookups();
    final rowsFuture = _fetchListingRows(
      query: query,
      filters: filters,
    );
    final lookups = await lookupsFuture;
    final rows = await rowsFuture;

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => _mapListingRow(row, lookups))
        .where((listing) => listing.rating >= minimumRating)
        .where((listing) {
          final price = _parsePrice(listing.priceLabel);
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
    final lookupsFuture = _fetchLookups();
    final rowFuture = _client
        .from('listings')
        .select(
          'id, seller_id, title, description, price, wilaya_id, '
          'commune_id, category_id, condition, quantity, exchange_enabled, exchange_description, '
          'brand, vehicle_fitment, seller_display_name, status, '
          'sellers!inner(user_id, business_name, verification_status), '
          'listing_media(public_url, sort_order)',
        )
        .eq('id', listingId)
        .maybeSingle();
    final lookups = await lookupsFuture;
    final row = await rowFuture;
    if (row == null) {
      return null;
    }

    return _mapListingRow(row, lookups);
  }

  Future<List<dynamic>> _fetchListingRows({
    String query = '',
    SearchFilterState filters = const SearchFilterState(),
  }) async {
    final rows = <dynamic>[];
    var start = 0;
    while (true) {
      final batch =
          await _buildListingQuery(
                query: query,
                filters: filters,
              )
              .order('created_at', ascending: false)
              .range(start, start + _pageSize - 1);
      rows.addAll(batch);
      if (batch.length < _pageSize) {
        return rows;
      }
      start += _pageSize;
    }
  }

  PostgrestFilterBuilder<PostgrestList> _buildListingQuery({
    required String query,
    required SearchFilterState filters,
  }) {
    final escapedQuery = query.trim().replaceAll(',', ' ');
    var builder = _client
        .from('listings')
        .select(
          'id, seller_id, title, description, price, wilaya_id, '
          'commune_id, category_id, condition, quantity, exchange_enabled, exchange_description, status, '
          'brand, vehicle_fitment, seller_display_name, sellers!inner(user_id, business_name, verification_status), '
          'listing_media(public_url, sort_order)',
        );

    if (filters.categoryId != null) {
      builder = builder.eq('category_id', filters.categoryId!);
    }
    if (filters.wilayaId != null) {
      builder = builder.eq('wilaya_id', int.parse(filters.wilayaId!));
    }
    if (filters.communeId != null) {
      builder = builder.eq('commune_id', filters.communeId!);
    }
    final fitmentFilter = <String, dynamic>{};
    if (filters.makeId != null) {
      fitmentFilter['make'] = filters.makeId;
    }
    if (filters.baseModel != null) {
      fitmentFilter['model'] = filters.baseModel;
    }
    if (filters.year != null) {
      fitmentFilter['year'] = filters.year;
    }
    if (fitmentFilter.isNotEmpty) {
      builder = builder.contains('vehicle_fitment', [fitmentFilter]);
    }
    if (filters.condition != null) {
      builder = builder.eq(
        'condition',
        _conditionValueForQuery(filters.condition!),
      );
    }
    if (filters.dealType == 'buy_or_exchange') {
      builder = builder.eq('exchange_enabled', true);
    }
    if (escapedQuery.isNotEmpty) {
      final keyword = '%${escapedQuery.replaceAll('%', '')}%';
      builder = builder.or(
        'title.ilike.$keyword,description.ilike.$keyword,brand.ilike.$keyword',
      );
    }
    return builder;
  }

  MarketplaceListing _mapListingRow(
    Map<String, dynamic> row,
    _DiscoveryLookups lookups,
  ) {
    final fitment = _extractPrimaryFitment(row['vehicle_fitment']);
    final brand = (row['brand'] as String?) ?? fitment?['make'] as String?;
    final model = fitment?['model'] as String?;
    final year = (fitment?['year'] as num?)?.toInt();
    final mediaUrls = _extractMediaUrls(row['listing_media']);
    final primaryImageUrl = mediaUrls.isEmpty ? null : mediaUrls.first;
    final wilayaCode = row['wilaya_id']?.toString();
    final communeCode = row['commune_id']?.toString();
    final categoryId = row['category_id']?.toString();
    final seller = _extractSeller(row['sellers']);
    final wilayaName = wilayaCode == null
        ? null
        : lookups.wilayaNames[wilayaCode];
    final communeName = communeCode == null
        ? null
        : lookups.communeNames[communeCode];
    final categorySlug = categoryId == null
        ? null
        : lookups.categorySlugs[categoryId];

    return MarketplaceListing(
      id: row['id'] as String,
      sellerUserId: seller?['user_id'] as String? ?? '',
      title: (row['title'] as String?) ?? '',
      priceLabel: '${row['price'] ?? 0} DZD',
      locationLabel: _locationLabel(
        communeName,
        wilayaName,
        communeCode,
        wilayaCode,
      ),
      fitmentLabel: _fitmentLabel(brand, model, year),
      sellerLabel: 'Verified seller',
      rating: 0,
      threadId: '',
      transactionId: '',
      categoryId: categoryId ?? '',
      categoryLabel: categorySlug ?? categoryId ?? '',
      conditionLabel: (row['condition'] as String?) ?? 'used',
      description: (row['description'] as String?) ?? '',
      exchangeAllowed: (row['exchange_enabled'] as bool?) ?? false,
      wilayaCode: wilayaCode,
      communeCode: communeCode,
      brand: brand,
      model: model,
      year: year,
      quantity: (row['quantity'] as int?) ?? 1,
      sellerName:
          (row['seller_display_name'] as String?) ??
          (seller?['business_name'] as String?) ??
          '',
      primaryImageUrl: primaryImageUrl,
      mediaUrls: mediaUrls,
      status: row['status'] as String? ?? 'active',
    );
  }

  Future<_DiscoveryLookups> _fetchLookups() async {
    final results = await Future.wait([
      _client.from('part_categories').select('id, slug'),
      _client.from('wilayas').select('id, name'),
      _client.from('communes').select('id, name'),
    ]);

    final categorySlugs = <String, String>{};
    for (final row
        in (results[0] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      categorySlugs[row['id'].toString()] = row['slug'] as String? ?? '';
    }

    final wilayaNames = <String, String>{};
    for (final row
        in (results[1] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      wilayaNames[row['id'].toString()] = row['name'] as String? ?? '';
    }

    final communeNames = <String, String>{};
    for (final row
        in (results[2] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      communeNames[row['id'].toString()] = row['name'] as String? ?? '';
    }

    return _DiscoveryLookups(
      categorySlugs: categorySlugs,
      wilayaNames: wilayaNames,
      communeNames: communeNames,
    );
  }

  Map<String, dynamic>? _extractPrimaryFitment(Object? raw) {
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return raw.first as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? _extractSeller(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return raw.first as Map<String, dynamic>;
    }
    return null;
  }

  String _fitmentLabel(String? brand, String? model, int? year) {
    final parts = <String>[
      if (brand != null && brand.isNotEmpty) brand,
      if (model != null && model.isNotEmpty) model,
      if (year != null) year.toString(),
    ];
    return parts.join(' | ');
  }

  List<String> _extractMediaUrls(Object? raw) {
    if (raw is! List) {
      return const <String>[];
    }
    final sortedRows =
        raw.whereType<Map<String, dynamic>>().toList(growable: false)..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );
    return sortedRows
        .map((row) => row['public_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  String _locationLabel(
    String? communeName,
    String? wilayaName,
    String? communeCode,
    String? wilayaCode,
  ) {
    final commune = communeName?.trim().isNotEmpty == true
        ? communeName!
        : (communeCode ?? '-');
    final wilaya = wilayaName?.trim().isNotEmpty == true
        ? wilayaName!
        : (wilayaCode ?? '-');
    return '$commune | $wilaya';
  }

  String _conditionValueForQuery(String condition) {
    switch (condition) {
      case 'like_new':
        return 'like new';
      default:
        return condition;
    }
  }

  int _parsePrice(String priceLabel) {
    final digits = priceLabel.replaceAll(RegExp('[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}

class _DiscoveryLookups {
  const _DiscoveryLookups({
    required this.categorySlugs,
    required this.wilayaNames,
    required this.communeNames,
  });

  final Map<String, String> categorySlugs;
  final Map<String, String> wilayaNames;
  final Map<String, String> communeNames;
}
