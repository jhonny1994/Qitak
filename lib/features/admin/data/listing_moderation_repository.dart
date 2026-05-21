import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/admin/domain/listing_moderation_case.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/data/local_listing_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ListingModerationRepository {
  const ListingModerationRepository();

  Future<int> countPendingReviewListings();

  Future<int> countSellerListings(String sellerUserId);

  Future<List<ListingModerationQueueItem>> listPendingReviewListings();

  Future<ListingModerationCase?> fetchListingCase(String listingId);

  Future<void> reviewListing({
    required String listingId,
    required bool approved,
    String? note,
  });
}

final listingModerationRepositoryProvider =
    Provider<ListingModerationRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      if (client == null) {
        throw StateError('Supabase client is required for moderation data.');
      }
      return SupabaseListingModerationRepository(client);
    });

final adminPendingListingModerationProvider =
    FutureProvider<List<ListingModerationQueueItem>>((ref) {
      return ref
          .read(listingModerationRepositoryProvider)
          .listPendingReviewListings();
    });

// ignore: specify_nonobvious_property_types, stable family identity matters more than the generated provider type here.
final adminListingModerationCaseProvider =
    FutureProvider.family<ListingModerationCase?, String>((ref, listingId) {
      return ref
          .read(listingModerationRepositoryProvider)
          .fetchListingCase(listingId);
    });

class LocalListingModerationRepository implements ListingModerationRepository {
  LocalListingModerationRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<int> countPendingReviewListings() async {
    return LocalListingStore(
      _prefs,
    ).readAll().where((item) => item.status == 'pending_review').length;
  }

  @override
  Future<int> countSellerListings(String sellerUserId) async {
    return LocalListingStore(
      _prefs,
    ).readAll().where((item) => item.sellerUserId == sellerUserId).length;
  }

  @override
  Future<ListingModerationCase?> fetchListingCase(String listingId) async {
    final listing =
        LocalListingStore(
              _prefs,
            )
            .readAll()
            .map((item) => item.toMarketplaceListing())
            .where(
              (item) => item.id == listingId,
            );
    if (listing.isEmpty) {
      return null;
    }
    final item = listing.first;
    return ListingModerationCase(
      listing: item,
      submittedAt: DateTime.now(),
      riskLevel: 'yellow',
      sellerVerificationStatus: 'approved',
      sellerOpenReportCount: 0,
      photoCount: item.mediaUrls.length,
    );
  }

  @override
  Future<List<ListingModerationQueueItem>> listPendingReviewListings() async {
    return LocalListingStore(_prefs)
        .readAll()
        .where((item) => item.status == 'pending_review')
        .map(
          (item) => ListingModerationQueueItem(
            listingId: item.id,
            title: item.title,
            categoryLabel: item.categoryId,
            sellerName: item.sellerName,
            submittedAt: item.createdAt,
            riskLevel: 'yellow',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> reviewListing({
    required String listingId,
    required bool approved,
    String? note,
  }) async {}
}

class SupabaseListingModerationRepository
    implements ListingModerationRepository {
  const SupabaseListingModerationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<int> countPendingReviewListings() async {
    final rows = await _client
        .from('listings')
        .select('id')
        .eq('status', 'pending_review');
    return rows.length;
  }

  @override
  Future<int> countSellerListings(String sellerUserId) async {
    final sellerRow = await _client
        .from('sellers')
        .select('id')
        .eq('user_id', sellerUserId)
        .maybeSingle();
    final sellerId = sellerRow?['id'] as String?;
    if (sellerId == null || sellerId.isEmpty) {
      return 0;
    }
    final rows = await _client
        .from('listings')
        .select('id')
        .eq('seller_id', sellerId);
    return rows.length;
  }

  @override
  Future<ListingModerationCase?> fetchListingCase(String listingId) async {
    final row = await _client
        .from('listings')
        .select(
          'id, seller_id, title, description, price, wilaya_id, '
          'commune_id, category_id, condition, quantity, exchange_enabled, exchange_description, '
          'seller_display_name, status, submitted_at, rejection_reason, '
          'brand, vehicle_fitment, sellers!inner(id, user_id, verification_status, business_name), '
          'listing_media(public_url, sort_order)',
        )
        .eq('id', listingId)
        .maybeSingle();
    if (row == null) {
      return null;
    }

    final seller = _extractSeller(row['sellers']);
    final reportsFuture = _client
        .from('reports')
        .select('id')
        .eq('reported_entity_type', 'seller')
        .eq('reported_entity_id', seller?['id'] as String? ?? '')
        .inFilter('status', ['open', 'under_review']);
    final lookupsFuture = _fetchLookups();

    final lookups = await lookupsFuture;
    final sellerReports = await reportsFuture;
    final listing = _mapListingRow(row, lookups);
    final category = row['category_id'] == null
        ? null
        : lookups.categoryMeta[row['category_id'].toString()];

    return ListingModerationCase(
      listing: listing,
      submittedAt:
          DateTime.tryParse(row['submitted_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      riskLevel: category?.riskLevel ?? 'yellow',
      sellerVerificationStatus:
          seller?['verification_status'] as String? ?? 'not_started',
      sellerOpenReportCount: sellerReports.length,
      photoCount: listing.mediaUrls.length,
      rejectionReason: row['rejection_reason'] as String?,
    );
  }

  @override
  Future<List<ListingModerationQueueItem>> listPendingReviewListings() async {
    final rows = await _client
        .from('listings')
        .select(
          'id, title, seller_display_name, submitted_at, category_id',
        )
        .eq('status', 'pending_review')
        .order('submitted_at', ascending: true);
    final data = rows.whereType<Map<String, dynamic>>();
    final lookups = await _fetchLookups();
    return data
        .map((row) {
          final category = row['category_id'] == null
              ? null
              : lookups.categoryMeta[row['category_id'].toString()];
          return ListingModerationQueueItem(
            listingId: row['id'] as String,
            title: row['title'] as String? ?? '',
            categoryLabel: category?.slug ?? '',
            sellerName: row['seller_display_name'] as String? ?? '',
            submittedAt:
                DateTime.tryParse(
                  row['submitted_at'] as String? ?? '',
                )?.toLocal() ??
                DateTime.now(),
            riskLevel: category?.riskLevel ?? 'yellow',
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> reviewListing({
    required String listingId,
    required bool approved,
    String? note,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'admin_review_listing',
        params: <String, dynamic>{
          'p_listing_id': listingId,
          'p_decision': approved ? 'approve' : 'reject',
          'p_note': note,
        },
      );
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  Future<_DiscoveryLookups> _fetchLookups() async {
    final results = await Future.wait([
      _client.from('part_categories').select('id, slug'),
      _client.from('part_categories').select('id, slug, risk_level'),
      _client.from('wilayas').select('id, name'),
      _client.from('communes').select('id, name'),
    ]);

    final categorySlugs = <String, String>{};
    for (final row
        in (results[0] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      categorySlugs[row['id'].toString()] = row['slug'] as String? ?? '';
    }
    final categoryMeta = <String, _CategoryMeta>{};
    for (final row
        in (results[1] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      categoryMeta[row['id'].toString()] = _CategoryMeta(
        slug: row['slug'] as String? ?? '',
        riskLevel: row['risk_level'] as String? ?? 'yellow',
      );
    }

    final wilayaNames = <String, String>{};
    for (final row
        in (results[2] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      wilayaNames[row['id'].toString()] = row['name'] as String? ?? '';
    }

    final communeNames = <String, String>{};
    for (final row
        in (results[3] as List<dynamic>).whereType<Map<String, dynamic>>()) {
      communeNames[row['id'].toString()] = row['name'] as String? ?? '';
    }

    return _DiscoveryLookups(
      categorySlugs: categorySlugs,
      categoryMeta: categoryMeta,
      wilayaNames: wilayaNames,
      communeNames: communeNames,
    );
  }

  MarketplaceListing _mapListingRow(
    Map<String, dynamic> row,
    _DiscoveryLookups lookups,
  ) {
    final fitment = _extractFitment(row['vehicle_fitment']);
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
      title: row['title'] as String? ?? '',
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
      conditionLabel: row['condition'] as String? ?? 'used',
      description: row['description'] as String? ?? '',
      exchangeAllowed: (row['exchange_enabled'] as bool?) ?? false,
      wilayaCode: wilayaCode,
      communeCode: communeCode,
      brand: brand,
      model: model,
      year: year,
      quantity: (row['quantity'] as int?) ?? 1,
      sellerName:
          row['seller_display_name'] as String? ??
          seller?['business_name'] as String? ??
          '',
      primaryImageUrl: primaryImageUrl,
      mediaUrls: mediaUrls,
      status: row['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic>? _extractFitment(Object? raw) {
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
}

class _DiscoveryLookups {
  const _DiscoveryLookups({
    required this.categorySlugs,
    required this.categoryMeta,
    required this.wilayaNames,
    required this.communeNames,
  });

  final Map<String, String> categorySlugs;
  final Map<String, _CategoryMeta> categoryMeta;
  final Map<String, String> wilayaNames;
  final Map<String, String> communeNames;
}

class _CategoryMeta {
  const _CategoryMeta({
    required this.slug,
    required this.riskLevel,
  });

  final String slug;
  final String riskLevel;
}
