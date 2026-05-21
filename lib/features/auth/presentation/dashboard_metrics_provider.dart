import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/admin/data/listing_moderation_repository.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

class SellerDashboardMetrics {
  const SellerDashboardMetrics({
    required this.listingCount,
    required this.openDeals,
    required this.recentMessages,
    required this.verificationStatus,
  });

  final int listingCount;
  final int openDeals;
  final int recentMessages;
  final String verificationStatus;
}

class AdminDashboardMetrics {
  const AdminDashboardMetrics({
    required this.pendingVerificationCount,
    required this.listingCount,
    required this.openReportCount,
    required this.openDisputeCount,
  });

  final int pendingVerificationCount;
  final int listingCount;
  final int openReportCount;
  final int openDisputeCount;
}

// Riverpod family provider aliases are version-specific in this repo; keep
// inference here so the provider remains strongly typed without pinning to an
// unavailable concrete family class name.
// ignore: specify_nonobvious_property_types
final sellerDashboardMetricsProvider =
    FutureProvider.family<SellerDashboardMetrics, String>((ref, userId) async {
      final listingModerationRepository = ref.read(
        listingModerationRepositoryProvider,
      );
      final transactionRepository = ref.read(transactionRepositoryProvider);
      final messagingRepository = ref.read(messagingRepositoryProvider);
      final sellerApplicationRepository = ref.read(
        sellerApplicationRepositoryProvider,
      );
      final listingsFuture = listingModerationRepository.countSellerListings(
        userId,
      );
      final dealsFuture = transactionRepository.listForUser(userId);
      final threadsFuture = messagingRepository.listThreadsForUser(userId);
      final applicationFuture = sellerApplicationRepository.fetchCurrentForUser(
        userId,
      );
      final listings = await listingsFuture;
      final deals = await dealsFuture;
      final threads = await threadsFuture;
      final application = await applicationFuture;

      return SellerDashboardMetrics(
        listingCount: listings,
        openDeals: deals
            .where(
              (item) => item.sellerUserId == userId && !item.state.isClosed,
            )
            .length,
        recentMessages: threads
            .where((item) => item.lastSenderId != userId)
            .length,
        verificationStatus: application?.verificationStatus ?? 'not_started',
      );
    });

final FutureProvider<AdminDashboardMetrics> adminDashboardMetricsProvider =
    FutureProvider<AdminDashboardMetrics>((ref) async {
      final sellerApplicationRepository = ref.read(
        sellerApplicationRepositoryProvider,
      );
      final listingModerationRepository = ref.read(
        listingModerationRepositoryProvider,
      );
      final adminReportsRepository = ref.read(adminReportsRepositoryProvider);
      final disputeRepository = ref.read(disputeRepositoryProvider);

      final pendingFuture = sellerApplicationRepository
          .listPendingApplications();
      final listingsFuture = listingModerationRepository
          .countPendingReviewListings();
      final reportsFuture = adminReportsRepository.listOpenReports();
      final disputesFuture = disputeRepository.listOpenDisputes();
      final pending = await pendingFuture;
      final listings = await listingsFuture;
      final reports = await reportsFuture;
      final disputes = await disputesFuture;

      return AdminDashboardMetrics(
        pendingVerificationCount: pending.length,
        listingCount: listings,
        openReportCount: reports.length,
        openDisputeCount: disputes.length,
      );
    });
