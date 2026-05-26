class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.sellerUserId,
    required this.title,
    required this.priceAmount,
    required this.sellerLabelCode,
    required this.rating,
    required this.threadId,
    required this.transactionId,
    this.categoryId,
    this.categoryCode = '',
    this.conditionCode = '',
    this.description = '',
    this.memberSinceLabel = '',
    this.exchangeAllowed = false,
    this.wilayaCode,
    this.communeCode,
    this.brand,
    this.model,
    this.year,
    this.quantity = 1,
    this.sellerName = '',
    this.primaryImageUrl,
    this.mediaUrls = const <String>[],
    this.status = 'active',
  });

  final String id;
  final String sellerUserId;
  final String title;
  final int priceAmount;
  final String sellerLabelCode;
  final double rating;
  final String threadId;
  final String transactionId;
  final String? categoryId;
  final String categoryCode;
  final String conditionCode;
  final String description;
  final String memberSinceLabel;
  final bool exchangeAllowed;
  final String? wilayaCode;
  final String? communeCode;
  final String? brand;
  final String? model;
  final int? year;
  final int quantity;
  final String sellerName;
  final String? primaryImageUrl;
  final List<String> mediaUrls;
  final String status;

  String? get preferredImageUrl {
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      return primaryImageUrl;
    }
    for (final url in mediaUrls) {
      if (url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  List<String> get galleryImageUrls {
    final primary = preferredImageUrl;
    if (primary == null) {
      return const <String>[];
    }
    if (mediaUrls.isNotEmpty && mediaUrls.first == primary) {
      return mediaUrls.skip(1).toList(growable: false);
    }
    return mediaUrls.where((url) => url != primary).toList(growable: false);
  }
}
