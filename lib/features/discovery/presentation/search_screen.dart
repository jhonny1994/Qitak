import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/protected_action_gate.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';
import 'package:qitak_app/features/discovery/presentation/discovery_filter_sheet.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/discovery/providers/search_history_provider.dart';
import 'package:qitak_app/features/listings/providers/saved_listings_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _activeQuery = widget.initialQuery.trim();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
      _activeQuery = widget.initialQuery.trim();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFilterProvider);
    final searchQuery = _activeQuery;
    final listings = ref.watch(
      discoverySearchListingsProvider(
        DiscoverySearchRequest(
          minimumRating: 0,
          query: searchQuery,
          filters: filters,
        ),
      ),
    );
    final taxonomy = ref.watch(discoveryFilterTaxonomyProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final session = ref.watch(authSessionProvider);
    final savedIds = ref
        .watch(savedListingIdsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <String>{},
        );
    final canSave = session.profile?.role == AccountRole.buyer;
    final canShowSave = canSave || !session.isAuthenticated;

    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('search-results-field'),
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => setState(() {}),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: context.l10n.discoverySearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            _debounce?.cancel();
                            setState(() => _activeQuery = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).clearButtonTooltip,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tooltip(
                  message: context.l10n.discoveryEditFiltersButton,
                  child: FilledButton.tonalIcon(
                    key: const Key('search-results-filter-button'),
                    onPressed: () => showDiscoveryFilterSheet(context),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(context.l10n.discoveryEditFiltersButton),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (searchQuery.isEmpty)
          searchHistory.when(
            data: (items) => _SearchHistorySection(
              items: items,
              onTap: _applyRecentSearch,
              onClear: ref.read(searchHistoryProvider.notifier).clear,
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
            loading: () => const _SearchHistoryLoadingState(),
          )
        else
          taxonomy.when(
            data: (taxonomyData) => listings.when(
              data: (items) {
                final applied = _buildAppliedFilterSummary(
                  context,
                  filters,
                  taxonomyData,
                );

                if (items.isEmpty) {
                  return QitakStateMessage(
                    title: context.l10n.noResultsTitle,
                    message: context.l10n.noResultsBody,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (applied.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final label in applied) QitakChip(label: label),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      '${items.length} ${context.l10n.searchResultsSuffix}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (var index = 0; index < items.length; index++) ...[
                      _SearchResultRow(
                        item: items[index],
                        canShowSave: canShowSave,
                        isSaved: savedIds.contains(items[index].id),
                        onToggleSave: canShowSave
                            ? () => _toggleSave(items[index].id)
                            : null,
                      ),
                      if (index < items.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
              error: (error, stackTrace) => QitakStateMessage(
                title: context.l10n.errorStateTitle,
                message: context.l10n.discoveryErrorBody,
              ),
              loading: () => const _SearchLoadingState(),
            ),
            error: (error, stackTrace) => QitakStateMessage(
              title: context.l10n.errorStateTitle,
              message: context.l10n.discoveryErrorBody,
            ),
            loading: () => const _SearchLoadingState(),
          ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) {
        return;
      }
      final trimmed = value.trim();
      setState(() => _activeQuery = trimmed);
      if (trimmed.isNotEmpty) {
        await ref.read(searchHistoryProvider.notifier).add(trimmed);
      }
    });
  }

  void _applyRecentSearch(String query) {
    _debounce?.cancel();
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() => _activeQuery = query.trim());
  }

  List<String> _buildAppliedFilterSummary(
    BuildContext context,
    SearchFilterState filters,
    DiscoveryFilterTaxonomy taxonomy,
  ) {
    final labels = <String>[];
    final category = taxonomy.categories
        .where((item) => item.id == filters.categoryId)
        .cast<DiscoveryCategoryOption?>()
        .firstOrNull;
    if (category != null) {
      labels.add(context.l10n.discoveryCategoryLabel(category.slug));
    }

    final wilaya = taxonomy.wilayas
        .where((item) => item.id == filters.wilayaId)
        .cast<WilayaOption?>()
        .firstOrNull;
    if (wilaya != null) {
      labels.add(context.displayWilaya(wilaya));
      final commune = wilaya.communes
          .where((item) => item.id == filters.communeId)
          .cast<CommuneOption?>()
          .firstOrNull;
      if (commune != null) {
        labels.add(context.displayCommune(commune));
      }
    }

    if (filters.makeId != null) {
      labels.add(filters.makeId!);
    }
    if (filters.baseModel != null) {
      labels.add(filters.baseModel!);
    }
    if (filters.year != null) {
      labels.add(filters.year.toString());
    }
    if (filters.condition != null) {
      labels.add(context.l10n.discoveryConditionLabel(filters.condition!));
    }
    if (filters.dealType != null) {
      labels.add(context.l10n.discoveryDealTypeLabel(filters.dealType!));
    }
    return labels;
  }

  Future<void> _toggleSave(String listingId) async {
    final session = ref.read(authSessionProvider);
    if (session.profile?.role == AccountRole.buyer) {
      await ref.read(savedListingIdsProvider.notifier).toggle(listingId);
      return;
    }
    if (!session.isAuthenticated) {
      final trimmedQuery = _controller.text.trim();
      final route = trimmedQuery.isEmpty
          ? '/search/results'
          : '/search/results?q=${Uri.encodeComponent(trimmedQuery)}';
      await showProtectedActionGate(
        context,
        ref,
        intent: PostAuthRedirectIntent.action(
          'save-listing',
          arguments: <String, String>{
            'route': route,
            'listingId': listingId,
          },
        ),
      );
    }
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.item,
    required this.canShowSave,
    required this.isSaved,
    required this.onToggleSave,
  });

  final MarketplaceListing item;
  final bool canShowSave;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    return QitakPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => context.go('/listing/${item.id}'),
              child: Row(
                children: [
                  QitakListingThumbnail(
                    imageUrl: item.preferredImageUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.localizedTitle(context.l10n),
                          style:
                              Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.localizedLocation(context.l10n),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.localizedPrice(context.l10n),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (canShowSave) ...[
                const SizedBox(height: 6),
                IconButton(
                  key: Key('search-result-save-${item.id}'),
                  onPressed: onToggleSave,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  tooltip: context.l10n.discoverySave,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSkeletonBox(height: 52),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 42),
            ],
          ),
        ),
        SizedBox(height: 16),
        QitakPanel(
          child: Column(
            children: [
              QitakSkeletonBox(height: 20),
              SizedBox(height: 10),
              QitakSkeletonBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchHistorySection extends StatelessWidget {
  const _SearchHistorySection({
    required this.items,
    required this.onTap,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onTap;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return QitakPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QitakSectionHeader(
            eyebrow: context.l10n.searchRecentLabel,
            title: context.l10n.searchRecentLabel,
            trailing: TextButton(
              onPressed: onClear,
              child: Text(context.l10n.searchHistoryClearAction),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded),
              title: Text(items[index]),
              onTap: () => onTap(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHistoryLoadingState extends StatelessWidget {
  const _SearchHistoryLoadingState();

  @override
  Widget build(BuildContext context) {
    return const QitakPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QitakSkeletonBox(height: 24, width: 180),
          SizedBox(height: 12),
          QitakSkeletonBox(height: 52),
          SizedBox(height: 10),
          QitakSkeletonBox(height: 52),
        ],
      ),
    );
  }
}

extension _IterableFirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
