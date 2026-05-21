import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/domain/search_filter_state.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

Future<void> showDiscoveryFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _DiscoveryFilterSheet(),
  );
}

class _DiscoveryFilterSheet extends ConsumerStatefulWidget {
  const _DiscoveryFilterSheet();

  @override
  ConsumerState<_DiscoveryFilterSheet> createState() =>
      _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends ConsumerState<_DiscoveryFilterSheet> {
  late SearchFilterState _draft;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(searchFilterProvider);
    _priceMinController = TextEditingController(
      text: _draft.priceMin?.toString() ?? '',
    );
    _priceMaxController = TextEditingController(
      text: _draft.priceMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxonomy = ref.watch(discoveryFilterTaxonomyProvider);

    return SafeArea(
      child: taxonomy.when(
        data: (data) => SingleChildScrollView(
          padding: qitakPagePadding.copyWith(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.discoveryFilterButton,
                title: context.l10n.discoveryFiltersTitle,
                subtitle: context.l10n.discoveryFiltersSubtitle,
              ),
              const SizedBox(height: 18),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CategoryField(
                      categories: data.categories,
                      selectedId: _draft.categoryId,
                      onChanged: (value) => setState(
                        () => _draft = SearchFilterState(
                          categoryId: value,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: _draft.year,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _WilayaField(
                      wilayas: data.wilayas,
                      selectedId: _draft.wilayaId,
                      onChanged: (value) => setState(() {
                        _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: value,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: _draft.year,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _CommuneField(
                      wilayas: data.wilayas,
                      selectedWilayaId: _draft.wilayaId,
                      selectedCommuneId: _draft.communeId,
                      onChanged: (value) => setState(
                        () => _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: value,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: _draft.year,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MakeField(
                      makes: data.makes,
                      selectedId: _draft.makeId,
                      onChanged: (value) => setState(() {
                        _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: value,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _ModelField(
                      makes: data.makes,
                      selectedMakeId: _draft.makeId,
                      selectedModel: _draft.baseModel,
                      onChanged: (value) => setState(() {
                        _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: _draft.makeId,
                          baseModel: value,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _YearField(
                      makes: data.makes,
                      selectedMakeId: _draft.makeId,
                      selectedModel: _draft.baseModel,
                      selectedYear: _draft.year,
                      onChanged: (value) => setState(
                        () => _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: value,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: QitakFormGroup(
                            label: context.l10n.discoveryMinPriceLabel,
                            child: TextFormField(
                              key: const Key('filter-price-min-field'),
                              controller: _priceMinController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QitakFormGroup(
                            label: context.l10n.discoveryMaxPriceLabel,
                            child: TextFormField(
                              key: const Key('filter-price-max-field'),
                              controller: _priceMaxController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ChoiceChipsRow<String>(
                      label: context.l10n.discoveryConditionFieldLabel,
                      options: const ['new', 'like_new', 'used'],
                      selected: _draft.condition,
                      display: (value) =>
                          context.l10n.discoveryConditionLabel(value),
                      onChanged: (value) => setState(
                        () => _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: _draft.year,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: value,
                          dealType: _draft.dealType,
                          sort: _draft.sort,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChoiceChipsRow<String>(
                      label: context.l10n.discoveryDealTypeFieldLabel,
                      options: const ['buy', 'buy_or_exchange'],
                      selected: _draft.dealType,
                      display: (value) =>
                          context.l10n.discoveryDealTypeLabel(value),
                      onChanged: (value) => setState(
                        () => _draft = SearchFilterState(
                          categoryId: _draft.categoryId,
                          wilayaId: _draft.wilayaId,
                          communeId: _draft.communeId,
                          makeId: _draft.makeId,
                          baseModel: _draft.baseModel,
                          year: _draft.year,
                          priceMin: _parseInt(_priceMinController.text),
                          priceMax: _parseInt(_priceMaxController.text),
                          condition: _draft.condition,
                          dealType: value,
                          sort: _draft.sort,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.discoverySortFieldLabel,
                      child: DropdownButtonFormField<String>(
                        key: const Key('filter-sort-field'),
                        initialValue: _draft.sort,
                        decoration: const InputDecoration(),
                        items: [
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text(
                              context.l10n.discoverySortLabel('newest'),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _draft = SearchFilterState(
                            categoryId: _draft.categoryId,
                            wilayaId: _draft.wilayaId,
                            communeId: _draft.communeId,
                            makeId: _draft.makeId,
                            baseModel: _draft.baseModel,
                            year: _draft.year,
                            priceMin: _parseInt(_priceMinController.text),
                            priceMax: _parseInt(_priceMaxController.text),
                            condition: _draft.condition,
                            dealType: _draft.dealType,
                            sort: value ?? 'newest',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('filter-reset-button'),
                            onPressed: () {
                              ref
                                  .read(searchFilterProvider.notifier)
                                  .resetFilters();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              context.l10n.discoveryResetFiltersButton,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            key: const Key('filter-apply-button'),
                            onPressed: () {
                              ref
                                  .read(searchFilterProvider.notifier)
                                  .appliedFilters = SearchFilterState(
                                categoryId: _draft.categoryId,
                                wilayaId: _draft.wilayaId,
                                communeId: _draft.communeId,
                                makeId: _draft.makeId,
                                baseModel: _draft.baseModel,
                                year: _draft.year,
                                priceMin: _parseInt(
                                  _priceMinController.text,
                                ),
                                priceMax: _parseInt(
                                  _priceMaxController.text,
                                ),
                                condition: _draft.condition,
                                dealType: _draft.dealType,
                                sort: _draft.sort,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              context.l10n.discoveryApplyFiltersButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Padding(
          padding: qitakPagePadding,
          child: QitakPanel(
            child: Column(
              children: [
                QitakSkeletonBox(height: 52),
                SizedBox(height: 12),
                QitakSkeletonBox(height: 52),
                SizedBox(height: 12),
                QitakSkeletonBox(height: 52),
              ],
            ),
          ),
        ),
        error: (error, stackTrace) => Padding(
          padding: qitakPagePadding,
          child: QitakStateMessage(
            title: context.l10n.errorStateTitle,
            message: context.l10n.discoveryFilterErrorBody,
          ),
        ),
      ),
    );
  }

  int? _parseInt(String raw) => int.tryParse(raw.trim());
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<DiscoveryCategoryOption> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [...categories]
      ..sort(
        (a, b) => context.l10n
            .discoveryCategoryLabel(a.slug)
            .compareTo(context.l10n.discoveryCategoryLabel(b.slug)),
      );
    final resolvedSelectedId =
        sortedCategories.any(
          (category) => category.id == selectedId,
        )
        ? selectedId
        : null;

    return QitakFormGroup(
      label: context.l10n.categoryLabel,
      child: QitakDropdownField<String>(
        key: ValueKey('filter-category-field-${resolvedSelectedId ?? 'none'}'),
        value: resolvedSelectedId,
        items: [
          for (final category in sortedCategories)
            DropdownMenuItem(
              value: category.id,
              child: Text(context.l10n.discoveryCategoryLabel(category.slug)),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _WilayaField extends StatelessWidget {
  const _WilayaField({
    required this.wilayas,
    required this.selectedId,
    required this.onChanged,
  });

  final List<WilayaOption> wilayas;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final sortedWilayas = [...wilayas]
      ..sort(
        (a, b) => context.displayWilaya(a).compareTo(context.displayWilaya(b)),
      );
    final resolvedSelectedId =
        sortedWilayas.any((wilaya) => wilaya.id == selectedId)
        ? selectedId
        : null;

    return QitakFormGroup(
      label: context.l10n.wilayaLabel,
      child: QitakDropdownField<String>(
        key: ValueKey('filter-wilaya-field-${resolvedSelectedId ?? 'none'}'),
        value: resolvedSelectedId,
        items: [
          for (final wilaya in sortedWilayas)
            DropdownMenuItem(
              value: wilaya.id,
              child: Text(context.displayWilaya(wilaya)),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _CommuneField extends StatelessWidget {
  const _CommuneField({
    required this.wilayas,
    required this.selectedWilayaId,
    required this.selectedCommuneId,
    required this.onChanged,
  });

  final List<WilayaOption> wilayas;
  final String? selectedWilayaId;
  final String? selectedCommuneId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedWilaya = wilayas
        .where((wilaya) => wilaya.id == selectedWilayaId)
        .cast<WilayaOption?>()
        .firstOrNull;
    final communes = [...?selectedWilaya?.communes]
      ..sort(
        (a, b) =>
            context.displayCommune(a).compareTo(context.displayCommune(b)),
      );
    final resolvedSelectedCommuneId =
        communes.any(
          (commune) => commune.id == selectedCommuneId,
        )
        ? selectedCommuneId
        : null;

    return QitakFormGroup(
      label: context.l10n.communeLabel,
      helper: selectedWilayaId == null
          ? context.l10n.discoveryFilterCommuneHelper
          : null,
      child: QitakDropdownField<String>(
        key: ValueKey(
          'filter-commune-field-${selectedWilayaId ?? 'none'}-${resolvedSelectedCommuneId ?? 'none'}',
        ),
        value: resolvedSelectedCommuneId,
        items: [
          for (final commune in communes)
            DropdownMenuItem(
              value: commune.id,
              child: Text(context.displayCommune(commune)),
            ),
        ],
        onChanged: selectedWilayaId == null ? null : onChanged,
      ),
    );
  }
}

class _MakeField extends StatelessWidget {
  const _MakeField({
    required this.makes,
    required this.selectedId,
    required this.onChanged,
  });

  final List<CarMakeOption> makes;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final sortedMakes = [...makes]..sort((a, b) => a.name.compareTo(b.name));
    final resolvedSelectedId = sortedMakes.any((make) => make.id == selectedId)
        ? selectedId
        : null;

    return QitakFormGroup(
      label: context.l10n.brandLabel,
      child: QitakDropdownField<String>(
        key: ValueKey('filter-make-field-${resolvedSelectedId ?? 'none'}'),
        value: resolvedSelectedId,
        items: [
          for (final make in sortedMakes)
            DropdownMenuItem(
              value: make.id,
              child: Text(make.name),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ModelField extends StatelessWidget {
  const _ModelField({
    required this.makes,
    required this.selectedMakeId,
    required this.selectedModel,
    required this.onChanged,
  });

  final List<CarMakeOption> makes;
  final String? selectedMakeId;
  final String? selectedModel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedMake = makes
        .where((make) => make.id == selectedMakeId)
        .cast<CarMakeOption?>()
        .firstOrNull;
    final models = [...?selectedMake?.models]
      ..sort((a, b) => a.name.compareTo(b.name));
    final resolvedSelectedModel =
        models.any((model) => model.name == selectedModel)
        ? selectedModel
        : null;

    return QitakFormGroup(
      label: context.l10n.modelLabel,
      helper: selectedMakeId == null
          ? context.l10n.discoveryFilterModelHelper
          : null,
      child: QitakDropdownField<String>(
        key: ValueKey(
          'filter-model-field-${selectedMakeId ?? 'none'}-${resolvedSelectedModel ?? 'none'}',
        ),
        value: resolvedSelectedModel,
        items: [
          for (final model in models)
            DropdownMenuItem(
              value: model.name,
              child: Text(model.name),
            ),
        ],
        onChanged: selectedMakeId == null ? null : onChanged,
      ),
    );
  }
}

class _YearField extends StatelessWidget {
  const _YearField({
    required this.makes,
    required this.selectedMakeId,
    required this.selectedModel,
    required this.selectedYear,
    required this.onChanged,
  });

  final List<CarMakeOption> makes;
  final String? selectedMakeId;
  final String? selectedModel;
  final int? selectedYear;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedMake = makes
        .where((make) => make.id == selectedMakeId)
        .cast<CarMakeOption?>()
        .firstOrNull;
    final selectedModelOption = selectedMake?.models
        .where((model) => model.name == selectedModel)
        .cast<CarModelOption?>()
        .firstOrNull;
    final years = selectedModelOption?.years ?? const <int>[];
    final resolvedSelectedYear = years.contains(selectedYear)
        ? selectedYear
        : null;

    return QitakFormGroup(
      label: context.l10n.yearLabel,
      helper: selectedModel == null
          ? context.l10n.discoveryFilterYearHelper
          : null,
      child: QitakDropdownField<int>(
        key: ValueKey(
          'filter-year-field-${selectedMakeId ?? 'none'}-${selectedModel ?? 'none'}-${resolvedSelectedYear ?? 'none'}',
        ),
        value: resolvedSelectedYear,
        items: [
          for (final year in years)
            DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            ),
        ],
        onChanged: selectedModel == null ? null : onChanged,
      ),
    );
  }
}

class _ChoiceChipsRow<T> extends StatelessWidget {
  const _ChoiceChipsRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T value) display;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return QitakFormGroup(
      label: label,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            QitakChip(
              label: display(option),
              selected: selected == option,
              onTap: () => onChanged(selected == option ? null : option),
            ),
        ],
      ),
    );
  }
}

extension _IterableFirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
