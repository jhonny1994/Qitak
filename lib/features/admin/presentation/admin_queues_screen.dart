import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/auth/presentation/dashboard_metrics_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AdminQueuesScreen extends ConsumerWidget {
  const AdminQueuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(adminDashboardMetricsProvider);
    return metrics.when(
      data: (summary) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminDashboardEyebrow,
        title: context.l10n.adminQueuesTitle,
        subtitle: context.l10n.adminQueuesSubtitle,
        children: [
          InkWell(
            onTap: () => context.go('/admin/verifications'),
            borderRadius: BorderRadius.circular(18),
            child: QitakQueueRow(
              title: context.l10n.adminVerificationsQueueTitle,
              meta: context.l10n.adminVerificationsQueueSubtitle,
              status: '${summary.pendingVerificationCount}',
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          InkWell(
            onTap: () => context.go('/admin/listings'),
            borderRadius: BorderRadius.circular(18),
            child: QitakQueueRow(
              title: context.l10n.adminListingsQueueTitle,
              meta: context.l10n.adminListingsQueueSubtitle,
              status: '${summary.listingCount}',
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          InkWell(
            onTap: () => context.go('/admin/disputes'),
            borderRadius: BorderRadius.circular(18),
            child: QitakQueueRow(
              title: context.l10n.adminDisputesQueueTitle,
              meta: context.l10n.adminDisputesQueueSubtitle,
              status: '${summary.openDisputeCount}',
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.adminQueuesErrorBody,
        ),
      ),
      loading: () => const Padding(
        padding: qitakPagePadding,
        child: Column(
          children: [
            QitakPanel(child: QitakSkeletonBox(height: 96)),
            SizedBox(height: 12),
            QitakPanel(child: QitakSkeletonBox(height: 96)),
          ],
        ),
      ),
    );
  }
}
