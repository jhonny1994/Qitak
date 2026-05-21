import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerVerificationQueueScreen extends ConsumerWidget {
  const SellerVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(adminPendingSellerApplicationsProvider);
    return AdminSurfaceScaffold(
      eyebrow: context.l10n.adminDashboardEyebrow,
      title: context.l10n.adminVerificationsQueueTitle,
      subtitle: context.l10n.adminVerificationsQueueSubtitle,
      children: applications.when(
        data: (items) => items.isEmpty
            ? [
                QitakSignalStrip(
                  label: context.l10n.adminQueueStatus,
                  value: context.l10n.adminQueueEmptyValue,
                  status: context.l10n.adminQueueReadyStatus,
                ),
                const SizedBox(height: 16),
                QitakStateMessage(
                  title: context.l10n.adminQueueEmptyTitle,
                  message: context.l10n.adminVerificationsQueueEmptyBody,
                ),
              ]
            : [
                for (final item in items)
                  InkWell(
                    onTap: () => context.go('/admin/verifications/${item.id}'),
                    borderRadius: BorderRadius.circular(18),
                    child: QitakQueueRow(
                      title: item.businessName,
                      meta: '${item.sellerType} • ${item.phone}',
                      status: item.verificationStatus,
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
              ],
        error: (error, stackTrace) => [
          QitakStateMessage(
            title: context.l10n.errorStateTitle,
            message: context.l10n.discoveryErrorBody,
          ),
        ],
        loading: () => const [
          QitakPanel(child: QitakSkeletonBox(height: 96)),
        ],
      ),
    );
  }
}
