import 'dart:convert';

import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalListingStore {
  LocalListingStore(this._prefs);

  static const storageKey = 'qitak.local.marketplace.listings';

  final SharedPreferences _prefs;

  Future<void> append(LocalStoredListing listing) async {
    final listings = readAll().where((item) => item.id != listing.id).toList()
      ..insert(0, listing)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _prefs.setString(
      storageKey,
      jsonEncode(listings.map((item) => item.toJson()).toList(growable: false)),
    );
  }

  List<LocalStoredListing> readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const <LocalStoredListing>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <LocalStoredListing>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LocalStoredListing.fromJson)
        .toList(growable: false);
  }
}

class LocalStoredListing {
  const LocalStoredListing({
    required this.id,
    required this.sellerUserId,
    required this.sellerName,
    required this.title,
    required this.price,
    required this.wilayaLabel,
    required this.communeLabel,
    required this.brandCode,
    required this.modelCode,
    required this.year,
    required this.categoryId,
    required this.condition,
    required this.description,
    required this.quantity,
    required this.exchangeEnabled,
    required this.wilayaCode,
    required this.communeCode,
    required this.mediaUrls,
    required this.createdAt,
    required this.status,
  });

  factory LocalStoredListing.fromDraft({
    required String id,
    required String sellerUserId,
    required String sellerName,
    required ListingDraft draft,
    required DateTime createdAt,
    required String status,
  }) {
    return LocalStoredListing(
      id: id,
      sellerUserId: sellerUserId,
      sellerName: sellerName,
      title: draft.title,
      price: draft.price,
      wilayaLabel: draft.wilayaLabel ?? draft.wilayaCode ?? '-',
      communeLabel: draft.communeLabel ?? draft.communeCode ?? '-',
      brandCode: draft.brandCode,
      modelCode: draft.modelCode,
      year: draft.year,
      categoryId: draft.categoryId,
      condition: draft.condition,
      description: draft.description,
      quantity: draft.quantity,
      exchangeEnabled: draft.exchangeEnabled,
      wilayaCode: draft.wilayaCode,
      communeCode: draft.communeCode,
      mediaUrls: draft.media
          .map((item) => item.toDataUri())
          .toList(growable: false),
      createdAt: createdAt,
      status: status,
    );
  }

  factory LocalStoredListing.fromJson(Map<String, dynamic> json) {
    return LocalStoredListing(
      id: json['id'] as String? ?? '',
      sellerUserId: json['sellerUserId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      wilayaLabel: json['wilayaLabel'] as String? ?? '-',
      communeLabel: json['communeLabel'] as String? ?? '-',
      brandCode: json['brandCode'] as String? ?? '',
      modelCode: json['modelCode'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      categoryId: json['categoryId'] as String? ?? '',
      condition: json['condition'] as String? ?? 'used',
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      exchangeEnabled: json['exchangeEnabled'] as bool? ?? false,
      wilayaCode: json['wilayaCode'] as String?,
      communeCode: json['communeCode'] as String?,
      mediaUrls: (json['mediaUrls'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status'] as String? ?? 'draft',
    );
  }

  final String id;
  final String sellerUserId;
  final String sellerName;
  final String title;
  final int price;
  final String wilayaLabel;
  final String communeLabel;
  final String brandCode;
  final String modelCode;
  final int year;
  final String categoryId;
  final String condition;
  final String description;
  final int quantity;
  final bool exchangeEnabled;
  final String? wilayaCode;
  final String? communeCode;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sellerUserId': sellerUserId,
      'sellerName': sellerName,
      'title': title,
      'price': price,
      'wilayaLabel': wilayaLabel,
      'communeLabel': communeLabel,
      'brandCode': brandCode,
      'modelCode': modelCode,
      'year': year,
      'categoryId': categoryId,
      'condition': condition,
      'description': description,
      'quantity': quantity,
      'exchangeEnabled': exchangeEnabled,
      'wilayaCode': wilayaCode,
      'communeCode': communeCode,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  MarketplaceListing toMarketplaceListing() {
    final primaryImageUrl = mediaUrls.isEmpty ? null : mediaUrls.first;
    return MarketplaceListing(
      id: id,
      sellerUserId: sellerUserId,
      title: title,
      priceAmount: price,
      sellerLabelCode: _verifiedSellerCode(),
      rating: 0,
      threadId: '${id}_thread',
      transactionId: '${id}_transaction',
      categoryId: categoryId,
      categoryCode: categoryId,
      conditionCode: condition,
      description: description,
      exchangeAllowed: exchangeEnabled,
      wilayaCode: wilayaCode,
      communeCode: communeCode,
      brand: brandCode,
      model: modelCode,
      year: year,
      quantity: quantity,
      sellerName: sellerName,
      primaryImageUrl: primaryImageUrl,
      mediaUrls: mediaUrls,
      status: status,
    );
  }

  String _verifiedSellerCode() {
    return 'seller_label_verified';
  }
}
