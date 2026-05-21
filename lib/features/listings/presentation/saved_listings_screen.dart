import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/providers/saved_listings_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(savedListingsProvider);

    return listings.when(
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: qitakPagePadding,
            child: QitakStateMessage(
              title: context.l10n.savedListingsTitle,
              message: context.l10n.savedListingsEmptyBody,
              action: FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(context.l10n.savedListingsBrowseAction),
              ),
            ),
          );
        }

        return QitakPullToRefresh(
          onRefresh: () async {
            ref
              ..invalidate(savedListingIdsProvider)
              ..invalidate(savedListingsProvider);
          },
          slivers: [
            SliverPadding(
              padding: qitakPagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  QitakPanel(
                    child: QitakSectionHeader(
                      eyebrow: context.l10n.savedListingsEyebrow,
                      title: context.l10n.savedListingsTitle,
                      subtitle: context.l10n.savedListingsSubtitle,
                    ),
                  ),
                  const SizedBox(height: 18),
                  QitakPanel(
                    child: Column(
                      children: [
                        for (var index = 0; index < items.length; index++) ...[
                          _SavedListingRow(item: items[index]),
                          if (index < items.length - 1)
                            const Divider(height: 24),
                        ],
                      ],
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
          message: context.l10n.savedListingsErrorBody,
        ),
      ),
      loading: () => const _SavedListingsLoadingState(),
    );
  }
}

class _SavedListingRow extends ConsumerWidget {
  const _SavedListingRow({required this.item});

  final MarketplaceListing item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => context.go('/listing/${item.id}'),
          borderRadius: BorderRadius.circular(18),
          child: QitakQueueRow(
            title: item.title,
            meta: '${item.fitmentLabel} • ${item.locationLabel}',
            status: item.priceLabel,
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.categoryLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
              onPressed: () =>
                  ref.read(savedListingIdsProvider.notifier).remove(item.id),
              child: Text(context.l10n.savedListingsRemoveAction),
            ),
          ],
        ),
      ],
    );
  }
}

class _SavedListingsLoadingState extends StatelessWidget {
  const _SavedListingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: const [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 28, width: 180),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 16, width: 240),
            ],
          ),
        ),
        SizedBox(height: 16),
        QitakPanel(
          child: QitakSkeletonBox(height: 120),
        ),
      ],
    );
  }
}
