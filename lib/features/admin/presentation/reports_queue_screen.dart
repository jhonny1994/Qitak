import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ReportsQueueScreen extends ConsumerWidget {
  const ReportsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(adminReportsProvider);
    return reports.when(
      data: (items) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminDashboardEyebrow,
        title: context.l10n.adminReportsQueueTitle,
        subtitle: context.l10n.adminReportsQueueSubtitle,
        children: items.isEmpty
            ? [
                QitakStateMessage(
                  title: context.l10n.adminQueueEmptyTitle,
                  message: context.l10n.adminReportsQueueEmptyBody,
                ),
              ]
            : [
                for (final item in items)
                  InkWell(
                    onTap: () => context.go('/admin/reports/${item.id}'),
                    borderRadius: BorderRadius.circular(18),
                    child: QitakQueueRow(
                      title: item.reason,
                      meta:
                          '${item.reporterName.isEmpty ? item.reporterUserId : item.reporterName}\n${item.entityPreview}',
                      status: item.status,
                      trailing: const Icon(Icons.chevron_right_rounded),
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
            QitakPanel(child: QitakSkeletonBox(height: 96)),
            SizedBox(height: 12),
            QitakPanel(child: QitakSkeletonBox(height: 96)),
          ],
        ),
      ),
    );
  }
}
