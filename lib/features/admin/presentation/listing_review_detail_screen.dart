import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/data/listing_moderation_repository.dart';
import 'package:qitak_app/features/admin/domain/listing_moderation_case.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/auth/presentation/dashboard_metrics_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ListingReviewDetailScreen extends ConsumerStatefulWidget {
  const ListingReviewDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<ListingReviewDetailScreen> createState() =>
      _ListingReviewDetailScreenState();
}

class _ListingReviewDetailScreenState
    extends ConsumerState<ListingReviewDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingCase = ref.watch(
      adminListingModerationCaseProvider(widget.listingId),
    );

    return AdminSurfaceScaffold(
      eyebrow: context.l10n.adminListingsQueueTitle,
      title: context.l10n.adminListingReviewTitle,
      subtitle: context.l10n.adminListingReviewSubtitle,
      children: listingCase.when(
        data: (item) => item == null
            ? [
                QitakStateMessage(
                  title: context.l10n.adminListingReviewEmptyTitle,
                  message: context.l10n.adminListingReviewEmptyBody,
                ),
              ]
            : _buildContent(context, item),
        error: (error, stackTrace) => [
          QitakStateMessage(
            title: context.l10n.errorStateTitle,
            message: context.l10n.discoveryErrorBody,
          ),
        ],
        loading: () => const [QitakPanel(child: QitakSkeletonBox(height: 180))],
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    ListingModerationCase item,
  ) {
    final checklist = <MapEntry<String, bool>>[
      MapEntry(
        context.l10n.adminModerationPhotosCheck,
        item.photoCount >= 2,
      ),
      MapEntry(
        context.l10n.adminModerationFitmentCheck,
        item.listing.brand?.isNotEmpty == true &&
            item.listing.model?.isNotEmpty == true &&
            item.listing.year != null,
      ),
      MapEntry(
        context.l10n.adminModerationQuantityCheck,
        item.listing.quantity > 0,
      ),
      MapEntry(
        context.l10n.adminModerationDescriptionCheck,
        item.listing.description.trim().isNotEmpty,
      ),
    ];

    return [
      QitakListingSurface(
        title: item.listing.localizedTitle(context.l10n),
        price: item.listing.localizedPrice(context.l10n),
        subtitle:
            '${item.listing.localizedFitment(context.l10n)} | ${item.listing.localizedLocation(context.l10n)}',
        imageUrl: item.listing.preferredImageUrl,
        ratingLabel: item.listing.localizedCondition(context.l10n),
        badges: [
          QitakChip(label: item.listing.localizedCategory(context.l10n)),
          QitakChip(label: item.riskLevel.toUpperCase()),
          QitakChip(label: item.listing.status),
        ],
      ),
      const SizedBox(height: 16),
      QitakPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.adminModerationChecklistTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final row in checklist)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      row.value
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: row.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(row.key)),
                  ],
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
            _detailRow(
              context.l10n.adminModerationSellerStatusLabel,
              item.sellerVerificationStatus,
            ),
            _detailRow(
              context.l10n.adminModerationSellerReportsLabel,
              item.sellerOpenReportCount.toString(),
            ),
            _detailRow(
              context.l10n.listingLocationLabel,
              item.listing.localizedLocation(context.l10n),
            ),
            _detailRow(
              context.l10n.quantityLabel,
              item.listing.quantity.toString(),
            ),
            _detailRow(
              context.l10n.listingDescriptionTitle,
              item.listing.description.isEmpty ? '-' : item.listing.description,
            ),
            if ((item.rejectionReason ?? '').trim().isNotEmpty)
              _detailRow(
                context.l10n.adminModerationLastRejectionLabel,
                item.rejectionReason!,
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      QitakPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.adminModerationDecisionNoteLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('admin-listing-review-note'),
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: context.l10n.adminModerationDecisionNoteHint,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _submitting
                      ? null
                      : () => _reviewListing(context, approved: true),
                  child: Text(context.l10n.adminVerificationApproveAction),
                ),
                OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => _reviewListing(context, approved: false),
                  child: Text(context.l10n.adminVerificationRejectAction),
                ),
                FilledButton.tonal(
                  onPressed: () => context.go('/listing/${widget.listingId}'),
                  child: Text(context.l10n.sellerListingsPreviewAction),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _reviewListing(
    BuildContext context, {
    required bool approved,
  }) async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(listingModerationRepositoryProvider)
          .reviewListing(
            listingId: widget.listingId,
            approved: approved,
            note: _noteController.text,
          );
      ref
        ..invalidate(adminPendingListingModerationProvider)
        ..invalidate(adminDashboardMetricsProvider)
        ..invalidate(adminListingModerationCaseProvider(widget.listingId));
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? context.l10n.adminModerationApproveSuccess
                : context.l10n.adminModerationRejectSuccess,
          ),
        ),
      );
      context.go('/admin/listings');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text('$label: $value'),
  );
}
