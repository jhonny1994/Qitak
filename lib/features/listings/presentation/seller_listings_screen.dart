import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerListingsScreen extends ConsumerStatefulWidget {
  const SellerListingsScreen({super.key});

  @override
  ConsumerState<SellerListingsScreen> createState() =>
      _SellerListingsScreenState();
}

class _SellerListingsScreenState extends ConsumerState<SellerListingsScreen> {
  String _status = 'active';

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final statusContracts = ref.watch(listingStatusContractsProvider);
    final statusCatalog = statusContracts.asData?.value
        .map((entry) => (code: entry.code, labelKey: entry.labelKey))
        .toList(growable: false);
    final options = _statusOptions(context, statusCatalog);
    final effectiveStatus = options.any((option) => option.value == _status)
        ? _status
        : options.first.value;
    final sellerId = session.profile?.id;
    if (sellerId == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    final listings = ref.watch(sellerManagedListingsProvider(sellerId));
    return listings.when(
      data: (items) {
        final filtered = items.where((item) => item.status == _status).toList();
        final counts = <String, int>{
          for (final option in options)
            option.value: items
                .where((item) => item.status == option.value)
                .length,
        };
        return QitakPullToRefresh(
          onRefresh: () async =>
              ref.invalidate(sellerManagedListingsProvider(sellerId)),
          slivers: [
            SliverPadding(
              padding: qitakPagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  QitakPanel(
                    child: QitakSectionHeader(
                      eyebrow: context.l10n.sellerListingsEyebrow,
                      title: context.l10n.sellerListingsTitle,
                      subtitle: context.l10n.sellerListingsSubtitle,
                      trailing: FilledButton.tonal(
                        onPressed: () => context.go('/seller/listings/new'),
                        child: Text(context.l10n.createListingCta),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in options)
                        QitakChip(
                          label:
                              '${option.label} (${counts[option.value] ?? 0})',
                          selected: option.value == effectiveStatus,
                          onTap: () => setState(() => _status = option.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Text(
                      _statusBody(context, _status),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    QitakStateMessage(
                      title: _statusLabel(context, _status),
                      message: _emptyBody(context, _status),
                    )
                  else
                    for (final item in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QitakListingSurface(
                          title: item.title,
                          price: context.l10n.priceWithDzd(item.price),
                          subtitle: [
                            item.fitmentSummary,
                            item.locationSummary,
                            _listingMeta(context, item),
                          ].where((part) => part.isNotEmpty).join(' | '),
                          imageUrl: item.primaryImageUrl,
                          ratingLabel: _statusLabel(context, item.status),
                          badges: [
                            QitakChip(label: item.condition),
                            if ((item.rejectionReason ?? '').isNotEmpty)
                              QitakChip(label: item.rejectionReason!),
                          ],
                          actions: _buildActions(context, item),
                        ),
                      ),
                ]),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.sellerListingsErrorBody,
        ),
      ),
      loading: () => const _SellerListingsLoadingState(),
    );
  }

  List<Widget> _buildActions(BuildContext context, SellerManagedListing item) {
    switch (item.status) {
      case 'active':
        return [
          OutlinedButton(
            onPressed: () => _applyAction(item.id, 'pause'),
            child: Text(context.l10n.sellerListingPauseAction),
          ),
          OutlinedButton(
            onPressed: () => context.go('/seller/listings/${item.id}/edit'),
            child: Text(context.l10n.sellerListingEditAction),
          ),
          FilledButton.tonal(
            onPressed: () => _applyAction(item.id, 'close'),
            child: Text(context.l10n.sellerListingCloseAction),
          ),
        ];
      case 'draft':
        return [
          OutlinedButton(
            onPressed: () => context.go('/seller/listings/${item.id}/edit'),
            child: Text(context.l10n.sellerListingEditAction),
          ),
          OutlinedButton(
            onPressed: () => _confirmDeleteDraft(item.id),
            child: Text(context.l10n.sellerListingDeleteAction),
          ),
          FilledButton(
            onPressed: () => _applyAction(item.id, 'resubmit'),
            child: Text(context.l10n.sellerListingSubmitAction),
          ),
        ];
      case 'pending_review':
        return [
          FilledButton.tonal(
            onPressed: () => context.go('/seller/listings/${item.id}'),
            child: Text(context.l10n.sellerListingsPreviewAction),
          ),
        ];
      case 'paused':
        return [
          OutlinedButton(
            onPressed: () => _applyAction(item.id, 'resume'),
            child: Text(context.l10n.sellerListingResumeAction),
          ),
          OutlinedButton(
            onPressed: () => context.go('/seller/listings/${item.id}/edit'),
            child: Text(context.l10n.sellerListingEditAction),
          ),
          FilledButton.tonal(
            onPressed: () => _applyAction(item.id, 'close'),
            child: Text(context.l10n.sellerListingCloseAction),
          ),
        ];
      case 'rejected':
        return [
          OutlinedButton(
            onPressed: () => context.go('/seller/listings/${item.id}/edit'),
            child: Text(context.l10n.sellerListingEditAction),
          ),
          FilledButton(
            onPressed: () => _applyAction(item.id, 'resubmit'),
            child: Text(context.l10n.sellerListingResubmitAction),
          ),
        ];
      default:
        return [
          FilledButton.tonal(
            onPressed: () => context.go('/seller/listings/${item.id}'),
            child: Text(context.l10n.sellerListingsPreviewAction),
          ),
        ];
    }
  }

  Future<void> _applyAction(String listingId, String action) async {
    await ref
        .read(sellerListingsRepositoryProvider)
        .applyAction(
          listingId: listingId,
          action: action,
        );
    final sellerId = ref.read(authSessionProvider).profile?.id;
    if (sellerId != null) {
      ref.invalidate(sellerManagedListingsProvider(sellerId));
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.sellerListingActionUpdated)),
    );
  }

  Future<void> _confirmDeleteDraft(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => QitakConfirmationModal(
        title: context.l10n.deleteListingTitle,
        body: context.l10n.deleteListingBody,
        confirmLabel: context.l10n.deleteListingConfirm,
        cancelLabel: context.l10n.cancel,
        isDestructive: true,
      ),
    );
    if (confirmed == true) {
      await _applyAction(listingId, 'delete_draft');
    }
  }
}

extension _SellerManagedListingPresentationX on SellerManagedListing {
  String get fitmentSummary {
    final parts = <String>[
      if (brand != null && brand!.isNotEmpty) brand!,
      if (model != null && model!.isNotEmpty) model!,
      if (year != null) year.toString(),
    ];
    return parts.join(' | ');
  }

  String get locationSummary {
    final commune = communeId?.trim().isNotEmpty == true ? communeId! : '-';
    final wilaya = wilayaId?.trim().isNotEmpty == true ? wilayaId! : '-';
    return '$commune | $wilaya';
  }
}

String _listingMeta(BuildContext context, SellerManagedListing item) {
  if (item.status == 'pending_review' && item.submittedAt != null) {
    return context.l10n.sellerListingSubmittedLabel(
      item.submittedAt!.toLocal().toIso8601String().split('T').first,
    );
  }
  if (item.updatedAt != null) {
    return context.l10n.sellerListingUpdatedLabel(
      item.updatedAt!.toLocal().toIso8601String().split('T').first,
    );
  }
  return '';
}

class _SellerListingsLoadingState extends StatelessWidget {
  const _SellerListingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: const [
        QitakPanel(child: QitakSkeletonBox(height: 120)),
      ],
    );
  }
}

List<({String value, String label})> _statusOptions(
  BuildContext context,
  List<({String code, String? labelKey})>? statusContracts,
) {
  final contracts =
      statusContracts ??
      const <({String code, String? labelKey})>[
        (code: 'active', labelKey: 'sellerListingsStatusActive'),
        (code: 'draft', labelKey: 'sellerListingsStatusDrafts'),
        (code: 'pending_review', labelKey: 'sellerListingsStatusUnderReview'),
        (code: 'paused', labelKey: 'sellerListingsStatusPaused'),
        (code: 'rejected', labelKey: 'sellerListingsStatusRejected'),
        (code: 'closed', labelKey: 'sellerListingsStatusClosed'),
      ];
  return [
    for (final contract in contracts)
      (
        value: contract.code,
        label: _statusLabel(
          context,
          contract.code,
          contract.labelKey,
        ),
      ),
  ];
}

String _statusLabel(BuildContext context, String status, [String? labelKey]) {
  switch (labelKey) {
    case 'sellerListingsStatusActive':
      return context.l10n.sellerListingsStatusActive;
    case 'sellerListingsStatusDrafts':
      return context.l10n.sellerListingsStatusDrafts;
    case 'sellerListingsStatusUnderReview':
      return context.l10n.sellerListingsStatusUnderReview;
    case 'sellerListingsStatusPaused':
      return context.l10n.sellerListingsStatusPaused;
    case 'sellerListingsStatusRejected':
      return context.l10n.sellerListingsStatusRejected;
    case 'sellerListingsStatusClosed':
      return context.l10n.sellerListingsStatusClosed;
    default:
      break;
  }
  switch (status) {
    case 'active':
      return context.l10n.sellerListingsStatusActive;
    case 'draft':
      return context.l10n.sellerListingsStatusDrafts;
    case 'pending_review':
      return context.l10n.sellerListingsStatusUnderReview;
    case 'paused':
      return context.l10n.sellerListingsStatusPaused;
    case 'rejected':
      return context.l10n.sellerListingsStatusRejected;
    case 'closed':
      return context.l10n.sellerListingsStatusClosed;
    default:
      return status;
  }
}

String _statusBody(BuildContext context, String status) {
  switch (status) {
    case 'draft':
      return context.l10n.listingSaveDraftAction;
    case 'pending_review':
      return context.l10n.listingSubmittedForReviewSuccess;
    case 'paused':
      return context.l10n.sellerListingResumeAction;
    case 'rejected':
      return context.l10n.adminModerationRejectSuccess;
    case 'closed':
      return context.l10n.sellerListingCloseAction;
    case 'active':
    default:
      return context.l10n.sellerListingsSubtitle;
  }
}

String _emptyBody(BuildContext context, String status) {
  switch (status) {
    case 'draft':
      return context.l10n.listingDraftSavedSuccess;
    case 'pending_review':
      return context.l10n.listingSubmittedForReviewSuccess;
    case 'paused':
      return context.l10n.sellerListingResumeAction;
    case 'rejected':
      return context.l10n.adminModerationRejectSuccess;
    case 'closed':
      return context.l10n.sellerListingsPreviewAction;
    case 'active':
    default:
      return context.l10n.sellerListingsEmptyBody;
  }
}
