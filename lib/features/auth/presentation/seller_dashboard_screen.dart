import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/dashboard_metrics_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authSessionProvider).profile;
    if (profile == null) {
      return const SizedBox.shrink();
    }
    final metrics = ref.watch(sellerDashboardMetricsProvider(profile.id));

    return metrics.when(
      data: (summary) => ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QitakSectionHeader(
                  key: const Key('seller-dashboard-title'),
                  eyebrow: context.l10n.profileRoleSeller,
                  title: context.l10n.sellerDashboardTitle,
                  subtitle: context.l10n.sellerDashboardSubtitle,
                ),
                const SizedBox(height: 14),
                QitakSignalStrip(
                  label: context.l10n.sellerStatusTitle,
                  value: _verificationLabel(
                    context,
                    summary.verificationStatus,
                  ),
                  status: summary.verificationStatus == 'approved'
                      ? context.l10n.adminQueueReadyStatus
                      : context.l10n.adminQueueStatus,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    QitakChip(
                      label:
                          '${context.l10n.sellerListingsTitle}: ${summary.listingCount}',
                    ),
                    QitakChip(
                      label:
                          '${context.l10n.sellerPendingDealsTitle}: ${summary.openDeals}',
                    ),
                    QitakChip(
                      label:
                          '${context.l10n.messagesTitle}: ${summary.recentMessages}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  key: const Key('seller-dashboard-create-listing'),
                  onTap: () => context.go('/seller/listings/new'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.createListingCta,
                    meta: context.l10n.createListingSubtitle,
                    status: context.l10n.sellerActionStatus,
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                QitakQueueRow(
                  title: context.l10n.sellerPendingDealsTitle,
                  meta: context.l10n.sellerPendingDealsBody,
                  status: summary.openDeals.toString(),
                ),
                InkWell(
                  onTap: () => context.go('/transactions'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.sellerLifecycleTitle,
                    meta: context.l10n.sellerLifecycleBody,
                    status: context.l10n.sellerActionStatus,
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go('/seller/listings'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.sellerListingsTitle,
                    meta: context.l10n.sellerListingsSubtitle,
                    status: summary.listingCount.toString(),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/messages'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.messagesTitle,
                    meta: context.l10n.messagesInboxSubtitle,
                    status: summary.recentMessages.toString(),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.discoveryErrorBody,
        ),
      ),
      loading: () => const Padding(
        padding: qitakPagePadding,
        child: Column(
          children: [
            QitakPanel(child: QitakSkeletonBox(height: 160)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

String _verificationLabel(BuildContext context, String status) {
  switch (status) {
    case 'approved':
      return context.l10n.sellerStatusApproved;
    case 'submitted':
      return context.l10n.sellerStatusSubmitted;
    case 'needs_more_info':
      return context.l10n.sellerStatusNeedsInfo;
    case 'rejected':
      return context.l10n.sellerStatusRejected;
    case 'draft':
    case 'not_started':
    default:
      return context.l10n.sellerStatusNotStarted;
  }
}
