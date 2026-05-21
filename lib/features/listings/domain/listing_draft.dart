import 'package:flutter/foundation.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';

@immutable
class ListingPersistedMedia {
  const ListingPersistedMedia({
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

@immutable
class ListingDraft {
  const ListingDraft({
    required this.title,
    required this.categoryId,
    required this.brandCode,
    required this.modelCode,
    required this.year,
    required this.price,
    required this.quantity,
    required this.condition,
    required this.description,
    required this.exchangeEnabled,
    this.listingId,
    this.exchangeDescription,
    this.media = const <ListingMediaSelection>[],
    this.persistedMedia = const <ListingPersistedMedia>[],
    this.wilayaCode,
    this.communeCode,
    this.wilayaLabel,
    this.communeLabel,
  });

  final String title;
  final String categoryId;
  final String brandCode;
  final String modelCode;
  final int year;
  final int price;
  final int quantity;
  final String condition;
  final String description;
  final bool exchangeEnabled;
  final String? listingId;
  final String? exchangeDescription;
  final List<ListingMediaSelection> media;
  final List<ListingPersistedMedia> persistedMedia;
  final String? wilayaCode;
  final String? communeCode;
  final String? wilayaLabel;
  final String? communeLabel;
}
