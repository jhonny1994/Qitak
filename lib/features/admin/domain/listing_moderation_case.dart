import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';

class ListingModerationQueueItem {
  const ListingModerationQueueItem({
    required this.listingId,
    required this.title,
    required this.categoryLabel,
    required this.sellerName,
    required this.submittedAt,
    required this.riskLevel,
  });

  final String listingId;
  final String title;
  final String categoryLabel;
  final String sellerName;
  final DateTime submittedAt;
  final String riskLevel;
}

class ListingModerationCase {
  const ListingModerationCase({
    required this.listing,
    required this.submittedAt,
    required this.riskLevel,
    required this.sellerVerificationStatus,
    required this.sellerOpenReportCount,
    required this.photoCount,
    this.rejectionReason,
  });

  final MarketplaceListing listing;
  final DateTime submittedAt;
  final String riskLevel;
  final String sellerVerificationStatus;
  final int sellerOpenReportCount;
  final int photoCount;
  final String? rejectionReason;
}
