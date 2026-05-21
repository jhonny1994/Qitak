import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerManagedListingMedia {
  const SellerManagedListingMedia({
    required this.storagePath,
    required this.publicUrl,
    required this.mimeType,
    required this.sortOrder,
  });

  final String storagePath;
  final String publicUrl;
  final String mimeType;
  final int sortOrder;
}

class SellerManagedListing {
  const SellerManagedListing({
    required this.id,
    required this.title,
    required this.status,
    required this.price,
    required this.fitmentLabel,
    required this.locationLabel,
    required this.categoryId,
    required this.condition,
    required this.primaryImageUrl,
    this.media = const <SellerManagedListingMedia>[],
    this.wilayaId,
    this.communeId,
    this.brand,
    this.model,
    this.year,
    this.quantity = 1,
    this.description = '',
    this.exchangeEnabled = false,
    this.exchangeDescription,
    this.submittedAt,
    this.updatedAt,
    this.rejectionReason,
  });

  final String id;
  final String title;
  final String status;
  final num price;
  final String fitmentLabel;
  final String locationLabel;
  final String categoryId;
  final String condition;
  final String? primaryImageUrl;
  final List<SellerManagedListingMedia> media;
  final String? wilayaId;
  final String? communeId;
  final String? brand;
  final String? model;
  final int? year;
  final int quantity;
  final String description;
  final bool exchangeEnabled;
  final String? exchangeDescription;
  final DateTime? submittedAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
}

abstract class SellerListingsRepository {
  const SellerListingsRepository();

  Future<List<SellerManagedListing>> listForSeller(String sellerUserId);
  Future<SellerManagedListing?> fetchById(String listingId);

  Future<void> applyAction({
    required String listingId,
    required String action,
  });
}

final sellerListingsRepositoryProvider = Provider<SellerListingsRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for seller listings.');
  }
  return SupabaseSellerListingsRepository(client);
});

// ignore: specify_nonobvious_property_types, reason: Riverpod family aliases are version-specific in this repo.
final sellerManagedListingsProvider =
    FutureProvider.family<List<SellerManagedListing>, String>((
      ref,
      sellerUserId,
    ) {
      return ref
          .read(sellerListingsRepositoryProvider)
          .listForSeller(sellerUserId);
    });

// ignore: specify_nonobvious_property_types, reason: Riverpod family aliases are version-specific in this repo.
final sellerManagedListingProvider =
    FutureProvider.family<SellerManagedListing?, String>((ref, listingId) {
      return ref.read(sellerListingsRepositoryProvider).fetchById(listingId);
    });

class SupabaseSellerListingsRepository implements SellerListingsRepository {
  const SupabaseSellerListingsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> applyAction({
    required String listingId,
    required String action,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'seller_manage_listing',
        params: <String, dynamic>{
          'p_listing_id': listingId,
          'p_action': action,
        },
      );
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<SellerManagedListing?> fetchById(String listingId) async {
    final row = await _client
        .from('listings')
        .select(
          'id, title, status, price, wilaya_id, commune_id, category_id, brand, vehicle_fitment, '
          'condition, rejection_reason, quantity, description, exchange_enabled, exchange_description, submitted_at, updated_at, '
          'listing_media(storage_path, public_url, mime_type, sort_order)',
        )
        .eq('id', listingId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    final wilayaNames = await _loadWilayaNames();
    final communeNames = await _loadCommuneNames();
    return _mapListingRow(row, wilayaNames, communeNames);
  }

  @override
  Future<List<SellerManagedListing>> listForSeller(String sellerUserId) async {
    final sellerRow = await _client
        .from('sellers')
        .select('id')
        .eq('user_id', sellerUserId)
        .maybeSingle();
    final sellerId = sellerRow?['id'] as String?;
    if (sellerId == null || sellerId.isEmpty) {
      return const <SellerManagedListing>[];
    }

    final rows = await _client
        .from('listings')
        .select(
          'id, title, status, price, wilaya_id, commune_id, category_id, brand, vehicle_fitment, '
          'condition, rejection_reason, quantity, description, exchange_enabled, exchange_description, submitted_at, updated_at, '
          'listing_media(storage_path, public_url, mime_type, sort_order)',
        )
        .eq('seller_id', sellerId)
        .order('updated_at', ascending: false);
    final wilayaNames = await _loadWilayaNames();
    final communeNames = await _loadCommuneNames();
    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => _mapListingRow(row, wilayaNames, communeNames))
        .toList(growable: false);
  }

  Future<Map<String, String>> _loadWilayaNames() async {
    final wilayas = await _client.from('wilayas').select('id, name');
    return <String, String>{
      for (final row in wilayas.whereType<Map<String, dynamic>>())
        row['id'].toString(): row['name'] as String? ?? '',
    };
  }

  Future<Map<String, String>> _loadCommuneNames() async {
    final communes = await _client.from('communes').select('id, name');
    return <String, String>{
      for (final row in communes.whereType<Map<String, dynamic>>())
        row['id'].toString(): row['name'] as String? ?? '',
    };
  }

  SellerManagedListing _mapListingRow(
    Map<String, dynamic> row,
    Map<String, String> wilayaNames,
    Map<String, String> communeNames,
  ) {
    final fitment = _extractFitment(row['vehicle_fitment']);
    final media = _extractMediaRows(row['listing_media']);
    final wilayaCode = row['wilaya_id']?.toString();
    final communeCode = row['commune_id']?.toString();
    final brand = (row['brand'] as String?) ?? fitment?['make'] as String?;
    final model = fitment?['model'] as String?;
    final year = (fitment?['year'] as num?)?.toInt();
    return SellerManagedListing(
      id: row['id'] as String,
      title: row['title'] as String? ?? '',
      status: row['status'] as String? ?? 'draft',
      price: row['price'] as num? ?? 0,
      fitmentLabel: [
        brand,
        model,
        year?.toString(),
      ].whereType<String>().where((part) => part.isNotEmpty).join(' | '),
      locationLabel:
          '${communeNames[communeCode ?? ''] ?? communeCode ?? '-'} | ${wilayaNames[wilayaCode ?? ''] ?? wilayaCode ?? '-'}',
      categoryId: row['category_id']?.toString() ?? '',
      condition: row['condition'] as String? ?? 'used',
      primaryImageUrl: media.isEmpty ? null : media.first.publicUrl,
      media: media,
      wilayaId: wilayaCode,
      communeId: communeCode,
      brand: brand,
      model: model,
      year: year,
      quantity: (row['quantity'] as num?)?.toInt() ?? 1,
      description: row['description'] as String? ?? '',
      exchangeEnabled: row['exchange_enabled'] as bool? ?? false,
      exchangeDescription: row['exchange_description'] as String?,
      submittedAt: DateTime.tryParse(
        row['submitted_at'] as String? ?? '',
      )?.toLocal(),
      updatedAt: DateTime.tryParse(
        row['updated_at'] as String? ?? '',
      )?.toLocal(),
      rejectionReason: row['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic>? _extractFitment(Object? raw) {
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return raw.first as Map<String, dynamic>;
    }
    return null;
  }

  List<SellerManagedListingMedia> _extractMediaRows(Object? raw) {
    if (raw is! List) {
      return const <SellerManagedListingMedia>[];
    }
    final sorted = raw.whereType<Map<String, dynamic>>().toList(growable: false)
      ..sort(
        (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
          (b['sort_order'] as num?)?.toInt() ?? 0,
        ),
      );
    return sorted
        .map(
          (row) => SellerManagedListingMedia(
            storagePath: row['storage_path'] as String? ?? '',
            publicUrl: row['public_url'] as String? ?? '',
            mimeType: row['mime_type'] as String? ?? 'image/jpeg',
            sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
          ),
        )
        .where((item) => item.publicUrl.isNotEmpty)
        .toList(growable: false);
  }
}
