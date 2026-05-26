import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/data/listing_moderation_repository.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ListingModerationQueueScreen extends ConsumerWidget {
  const ListingModerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(adminPendingListingModerationProvider);
    return listings.when(
      data: (items) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminDashboardEyebrow,
        title: context.l10n.adminListingsQueueTitle,
        subtitle: context.l10n.adminListingsQueueSubtitle,
        children: items.isEmpty
            ? [
                QitakSignalStrip(
                  label: context.l10n.adminQueueStatus,
                  value: context.l10n.adminQueueEmptyValue,
                  status: context.l10n.adminQueueReadyStatus,
                ),
                const SizedBox(height: 16),
                QitakStateMessage(
                  title: context.l10n.adminQueueEmptyTitle,
                  message: context.l10n.adminListingsQueueEmptyBody,
                ),
              ]
            : [
                for (final item in items)
                  InkWell(
                    onTap: () =>
                        context.go('/admin/listings/${item.listingId}'),
                    borderRadius: BorderRadius.circular(18),
                    child: QitakQueueRow(
                      title: item.title,
                      meta:
                          '${context.l10n.localMarketplaceCategory(item.categoryCode)} • ${item.sellerName}',
                      status: item.riskLevel.toUpperCase(),
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
