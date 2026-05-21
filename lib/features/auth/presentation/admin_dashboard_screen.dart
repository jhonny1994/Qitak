import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/presentation/dashboard_metrics_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authSessionProvider).profile?.role;
    final showAdminTeam = role == AccountRole.superAdmin;
    final metrics = ref.watch(adminDashboardMetricsProvider);

    return metrics.when(
      data: (summary) => ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QitakSectionHeader(
                  key: const Key('admin-dashboard-title'),
                  eyebrow: context.l10n.adminDashboardEyebrow,
                  title: context.l10n.adminDashboardTitle,
                  subtitle: context.l10n.adminDashboardSubtitle,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    QitakChip(
                      label:
                          '${context.l10n.adminSellerVerificationsTitle}: ${summary.pendingVerificationCount}',
                    ),
                    QitakChip(
                      label:
                          '${context.l10n.adminListingReviewsTitle}: ${summary.listingCount}',
                    ),
                    QitakChip(
                      label:
                          '${context.l10n.adminDisputesQueueTitle}: ${summary.openDisputeCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => context.go('/admin/verifications'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.adminSellerVerificationsTitle,
                    meta: context.l10n.adminSellerVerificationsBody,
                    status: summary.pendingVerificationCount.toString(),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/admin/listings'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.adminListingReviewsTitle,
                    meta: context.l10n.adminListingReviewsBody,
                    status: summary.listingCount.toString(),
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
                  onTap: () => context.go('/admin/reports'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.adminReportsQueueTitle,
                    meta: context.l10n.adminReportsQueueSubtitle,
                    status: summary.openReportCount.toString(),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/admin/disputes'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.adminDisputesQueueTitle,
                    meta: context.l10n.adminDisputesQueueSubtitle,
                    status: summary.openDisputeCount.toString(),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                if (showAdminTeam)
                  InkWell(
                    onTap: () => context.go('/admin/team'),
                    borderRadius: BorderRadius.circular(18),
                    child: QitakQueueRow(
                      title: context.l10n.adminTeamTitle,
                      meta: context.l10n.adminTeamSubtitle,
                      status: context.l10n.adminQueueReadyStatus,
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
            QitakPanel(child: QitakSkeletonBox(height: 120)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
