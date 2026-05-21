import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_provider.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

List<WilayaOption> _sortedWilayas(
  BuildContext context,
  List<WilayaOption> wilayas,
) => [
  ...wilayas,
]..sort((a, b) => context.displayWilaya(a).compareTo(context.displayWilaya(b)));

List<CommuneOption> _sortedCommunes(
  BuildContext context,
  List<CommuneOption> communes,
) => [...communes]
  ..sort(
    (a, b) => context.displayCommune(a).compareTo(context.displayCommune(b)),
  );

List<CarMakeOption> _sortedMakes(List<CarMakeOption> makes) =>
    [...makes]..sort((a, b) => a.name.compareTo(b.name));

List<CarModelOption> _sortedModels(List<CarModelOption> models) =>
    [...models]..sort((a, b) => a.name.compareTo(b.name));

class ListingFormScreen extends ConsumerStatefulWidget {
  const ListingFormScreen({this.listingId, super.key});

  final String? listingId;

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  final _exchangeDescriptionController = TextEditingController();

  String? _categoryId;
  String? _wilayaId;
  String? _communeId;
  String? _makeId;
  String? _modelCode;
  int? _year;
  String _condition = 'like_new';
  bool _exchangeEnabled = false;
  List<ListingMediaSelection> _media = const <ListingMediaSelection>[];
  List<ListingPersistedMedia> _existingMedia = const <ListingPersistedMedia>[];
  bool _submitting = false;
  bool _submitted = false;
  ListingWorkflowAction _lastAction = ListingWorkflowAction.submit;
  bool _editHydrated = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _exchangeDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxonomy = ref.watch(discoveryFilterTaxonomyProvider);
    final sellerApplication = ref.watch(currentSellerApplicationProvider);
    final editListing = widget.listingId == null
        ? null
        : ref.watch(sellerManagedListingProvider(widget.listingId!));

    if (sellerApplication.hasValue &&
        sellerApplication.value?.isApproved != true) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.sellerStatusTitle,
          message: context.l10n.sellerStatusWorkspaceWaitingBody,
          action: FilledButton.tonal(
            onPressed: () => context.go('/seller/onboarding/status'),
            child: Text(context.l10n.sellerStatusContinueApplication),
          ),
        ),
      );
    }

    return taxonomy.when(
      data: (data) {
        final managedListing = switch (editListing) {
          AsyncData(:final value) => value,
          _ => null,
        };
        if (!_editHydrated && managedListing != null) {
          _titleController.text = managedListing.title;
          _priceController.text = managedListing.price.toString();
          _quantityController.text = managedListing.quantity.toString();
          _descriptionController.text = managedListing.description;
          _exchangeDescriptionController.text =
              managedListing.exchangeDescription ?? '';
          _categoryId = managedListing.categoryId;
          _wilayaId = managedListing.wilayaId;
          _communeId = managedListing.communeId;
          _makeId = managedListing.brand;
          _modelCode = managedListing.model;
          _year = managedListing.year;
          _condition = managedListing.condition;
          _exchangeEnabled = managedListing.exchangeEnabled;
          _existingMedia = managedListing.media
              .map(
                (item) => ListingPersistedMedia(
                  storagePath: item.storagePath,
                  publicUrl: item.publicUrl,
                  mimeType: item.mimeType,
                  sortOrder: item.sortOrder,
                ),
              )
              .toList(growable: false);
          _editHydrated = true;
        }
        final sortedCategories = [...data.categories]
          ..sort(
            (a, b) => context.l10n
                .discoveryCategoryLabel(a.slug)
                .compareTo(context.l10n.discoveryCategoryLabel(b.slug)),
          );
        final sortedWilayas = _sortedWilayas(context, data.wilayas);
        final selectedWilaya = _selectedWilaya(sortedWilayas);
        final sortedCommunes = _sortedCommunes(
          context,
          selectedWilaya?.communes ?? const <CommuneOption>[],
        );
        final sortedMakes = _sortedMakes(data.makes);
        final selectedMake = _selectedMake(sortedMakes);
        final sortedModels = _sortedModels(
          selectedMake?.models ?? const <CarModelOption>[],
        );
        final selectedCategory = _selectedCategory(sortedCategories);
        final selectedModel = _selectedModel(sortedMakes);
        final years = [...?selectedModel?.years]..sort();
        final submitLabel = selectedCategory?.requiresReview ?? true
            ? context.l10n.listingSubmitForReviewAction
            : context.l10n.listingPublishAction;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: qitakPagePadding,
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QitakPanel(
                      child: QitakSectionHeader(
                        eyebrow: context.l10n.sellerListingsEyebrow,
                        title: context.l10n.listingCreateTitle,
                        subtitle: widget.listingId == null
                            ? context.l10n.listingOneVehicleHint
                            : context.l10n.sellerListingsPreviewAction,
                      ),
                    ),
                    const SizedBox(height: 18),
                    QitakPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          QitakFormGroup(
                            label: context.l10n.listingTitleLabel,
                            child: TextFormField(
                              key: const Key('listing-title-field'),
                              controller: _titleController,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? context.l10n.listingTitleRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.categoryLabel,
                            child: QitakDropdownField<String>(
                              key: ValueKey(
                                'listing-category-field-${_categoryId ?? 'none'}',
                              ),
                              value:
                                  sortedCategories.any(
                                    (item) => item.id == _categoryId,
                                  )
                                  ? _categoryId
                                  : null,
                              items: [
                                for (final category in sortedCategories)
                                  DropdownMenuItem(
                                    value: category.id,
                                    child: Text(
                                      context.l10n.discoveryCategoryLabel(
                                        category.slug,
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _categoryId = value),
                              validator: (value) => value == null
                                  ? context.l10n.listingCategoryRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.wilayaLabel,
                            child: QitakDropdownField<String>(
                              key: ValueKey(
                                'listing-wilaya-field-${_wilayaId ?? 'none'}',
                              ),
                              value:
                                  sortedWilayas.any(
                                    (item) => item.id == _wilayaId,
                                  )
                                  ? _wilayaId
                                  : null,
                              items: [
                                for (final wilaya in sortedWilayas)
                                  DropdownMenuItem(
                                    value: wilaya.id,
                                    child: Text(context.displayWilaya(wilaya)),
                                  ),
                              ],
                              onChanged: (value) => setState(() {
                                _wilayaId = value;
                                _communeId = null;
                              }),
                              validator: (value) => value == null
                                  ? context.l10n.listingWilayaRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.communeLabel,
                            helper: _wilayaId == null
                                ? context.l10n.discoveryFilterCommuneHelper
                                : null,
                            child: QitakDropdownField<String>(
                              key: ValueKey(
                                'listing-commune-field-${_wilayaId ?? 'none'}-${_communeId ?? 'none'}',
                              ),
                              value:
                                  sortedCommunes.any(
                                    (item) => item.id == _communeId,
                                  )
                                  ? _communeId
                                  : null,
                              items: [
                                for (final commune in sortedCommunes)
                                  DropdownMenuItem(
                                    value: commune.id,
                                    child: Text(
                                      context.displayCommune(commune),
                                    ),
                                  ),
                              ],
                              onChanged: _wilayaId == null
                                  ? null
                                  : (value) =>
                                        setState(() => _communeId = value),
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.brandLabel,
                            child: QitakDropdownField<String>(
                              key: ValueKey(
                                'listing-make-field-${_makeId ?? 'none'}',
                              ),
                              value:
                                  sortedMakes.any((item) => item.id == _makeId)
                                  ? _makeId
                                  : null,
                              items: [
                                for (final make in sortedMakes)
                                  DropdownMenuItem(
                                    value: make.id,
                                    child: Text(make.name),
                                  ),
                              ],
                              onChanged: (value) => setState(() {
                                _makeId = value;
                                _modelCode = null;
                                _year = null;
                              }),
                              validator: (value) => value == null
                                  ? context.l10n.listingMakeRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.modelLabel,
                            helper: _makeId == null
                                ? context.l10n.discoveryFilterModelHelper
                                : null,
                            child: QitakDropdownField<String>(
                              key: ValueKey(
                                'listing-model-field-${_makeId ?? 'none'}-${_modelCode ?? 'none'}',
                              ),
                              value:
                                  sortedModels.any(
                                    (item) => item.name == _modelCode,
                                  )
                                  ? _modelCode
                                  : null,
                              items: [
                                for (final model in sortedModels)
                                  DropdownMenuItem(
                                    value: model.name,
                                    child: Text(model.name),
                                  ),
                              ],
                              onChanged: _makeId == null
                                  ? null
                                  : (value) => setState(() {
                                      _modelCode = value;
                                      _year = null;
                                    }),
                              validator: (value) => value == null
                                  ? context.l10n.listingModelRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.yearLabel,
                            helper: _modelCode == null
                                ? context.l10n.discoveryFilterYearHelper
                                : null,
                            child: QitakDropdownField<int>(
                              key: ValueKey(
                                'listing-year-field-${_makeId ?? 'none'}-${_modelCode ?? 'none'}-${_year ?? 'none'}',
                              ),
                              value: years.contains(_year) ? _year : null,
                              items: [
                                for (final item in years)
                                  DropdownMenuItem(
                                    value: item,
                                    child: Text(item.toString()),
                                  ),
                              ],
                              onChanged: _modelCode == null
                                  ? null
                                  : (value) => setState(() => _year = value),
                              validator: (value) => value == null
                                  ? context.l10n.listingYearRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: QitakFormGroup(
                                  label: context.l10n.listingPriceLabel,
                                  child: TextFormField(
                                    key: const Key('listing-price-field'),
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      final parsed = int.tryParse(
                                        (value ?? '').trim(),
                                      );
                                      if (parsed == null || parsed <= 0) {
                                        return context.l10n.listingPriceError;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: QitakFormGroup(
                                  label: context.l10n.quantityLabel,
                                  child: TextFormField(
                                    key: const Key('listing-quantity-field'),
                                    controller: _quantityController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      final parsed = int.tryParse(
                                        (value ?? '').trim(),
                                      );
                                      if (parsed == null || parsed <= 0) {
                                        return context
                                            .l10n
                                            .listingQuantityError;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ConditionSelector(
                            selected: _condition,
                            onChanged: (value) =>
                                setState(() => _condition = value),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.listingDescriptionTitle,
                            child: TextFormField(
                              key: const Key('listing-description-field'),
                              controller: _descriptionController,
                              maxLines: 4,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? context.l10n.listingDescriptionRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QitakFormGroup(
                            label: context.l10n.listingMediaSectionTitle,
                            helper: context.l10n.listingMediaSectionBody,
                            error:
                                _submitted && !_hasRequiredMediaFor(_lastAction)
                                ? _lastAction == ListingWorkflowAction.submit
                                      ? context.l10n.listingMediaMinimumRequired
                                      : context.l10n.listingMediaRequired
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Tooltip(
                                  message:
                                      context.l10n.listingMediaAttachAction,
                                  child: FilledButton.tonalIcon(
                                    key: const Key('listing-media-add-button'),
                                    onPressed: _submitting ? null : _pickMedia,
                                    icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                    ),
                                    label: Text(
                                      context.l10n.listingMediaAttachAction,
                                    ),
                                  ),
                                ),
                                if (_existingMedia.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  for (
                                    var index = 0;
                                    index < _existingMedia.length;
                                    index++
                                  )
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index == _existingMedia.length - 1
                                            ? 0
                                            : 10,
                                      ),
                                      child: QitakPanel(
                                        padding: const EdgeInsets.all(12),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    14,
                                                  ),
                                              child: SizedBox(
                                                width: 72,
                                                height: 72,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      _existingMedia[index]
                                                          .publicUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const QitakSkeletonBox(
                                                        width: 72,
                                                        height: 72,
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const _ListingMediaPreviewFallback(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _existingMedia[index]
                                                    .storagePath
                                                    .split('/')
                                                    .last,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: _submitting
                                                  ? null
                                                  : () => setState(() {
                                                      _existingMedia = [
                                                        ..._existingMedia.take(
                                                          index,
                                                        ),
                                                        ..._existingMedia.skip(
                                                          index + 1,
                                                        ),
                                                      ];
                                                    }),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                              ),
                                              tooltip: context
                                                  .l10n
                                                  .listingMediaRemoveAction,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                                if (_media.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  for (
                                    var index = 0;
                                    index < _media.length;
                                    index++
                                  )
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == _media.length - 1
                                            ? 0
                                            : 10,
                                      ),
                                      child: QitakPanel(
                                        padding: const EdgeInsets.all(12),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    14,
                                                  ),
                                              child: SizedBox(
                                                width: 72,
                                                height: 72,
                                                child: Image.memory(
                                                  _media[index].bytes,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _media[index].fileName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              key: Key(
                                                'listing-media-remove-$index',
                                              ),
                                              onPressed: _submitting
                                                  ? null
                                                  : () => setState(() {
                                                      _media = [
                                                        ..._media.take(index),
                                                        ..._media.skip(
                                                          index + 1,
                                                        ),
                                                      ];
                                                    }),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                              ),
                                              tooltip: context
                                                  .l10n
                                                  .listingMediaRemoveAction,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            key: const Key('listing-exchange-switch'),
                            contentPadding: EdgeInsets.zero,
                            value: _exchangeEnabled,
                            onChanged: (value) =>
                                setState(() => _exchangeEnabled = value),
                            title: Text(context.l10n.listingExchangeEnabled),
                          ),
                          if (_exchangeEnabled) ...[
                            const SizedBox(height: 12),
                            QitakFormGroup(
                              label:
                                  context.l10n.discoveryDealTypeBuyOrExchange,
                              child: TextFormField(
                                key: const Key(
                                  'listing-exchange-description-field',
                                ),
                                controller: _exchangeDescriptionController,
                                maxLines: 3,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  key: const Key('listing-save-draft-button'),
                                  onPressed: _submitting
                                      ? null
                                      : () => _submit(
                                          ListingWorkflowAction.saveDraft,
                                        ),
                                  child: Text(
                                    context.l10n.listingSaveDraftAction,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  key: const Key('listing-submit-button'),
                                  onPressed: _submitting
                                      ? null
                                      : () => _submit(
                                          ListingWorkflowAction.submit,
                                        ),
                                  child:
                                      _submitting &&
                                          _lastAction ==
                                              ListingWorkflowAction.submit
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(submitLabel),
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
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: qitakPagePadding,
        child: QitakPanel(
          child: QitakSkeletonBox(height: 56),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.discoveryFilterErrorBody,
        ),
      ),
    );
  }

  Future<void> _submit(ListingWorkflowAction action) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _submitted = true;
      _lastAction = action;
    });
    if (!_formKey.currentState!.validate() || !_hasRequiredMediaFor(action)) {
      return;
    }

    final taxonomyState = ref.read(discoveryFilterTaxonomyProvider);
    final taxonomy = switch (taxonomyState) {
      AsyncData<DiscoveryFilterTaxonomy>(:final value) => value,
      _ => null,
    };
    final selectedWilaya = taxonomy == null
        ? null
        : _selectedWilaya(taxonomy.wilayas);
    final selectedCommune = selectedWilaya?.communes
        .where((item) => item.id == _communeId)
        .firstOrNull;

    setState(() => _submitting = true);
    try {
      final profile = ref.read(authSessionProvider).profile;
      final result = await ref
          .read(listingRepositoryProvider)
          .submitListing(
            draft: ListingDraft(
              listingId: widget.listingId,
              title: _titleController.text.trim(),
              categoryId: _categoryId!,
              brandCode: _makeId!,
              modelCode: _modelCode!,
              year: _year!,
              price: int.parse(_priceController.text.trim()),
              quantity: int.parse(_quantityController.text.trim()),
              condition: _condition,
              description: _descriptionController.text.trim(),
              exchangeEnabled: _exchangeEnabled,
              exchangeDescription: _exchangeDescriptionController.text.trim(),
              media: _media,
              persistedMedia: _existingMedia,
              wilayaCode: _wilayaId,
              communeCode: _communeId,
              wilayaLabel: selectedWilaya.let(context.displayWilaya),
              communeLabel: selectedCommune.let(context.displayCommune),
            ),
            action: action,
          );
      ref
        ..invalidate(discoveryListingsProvider(0))
        ..invalidate(currentSellerApplicationProvider);
      if (profile != null) {
        ref.invalidate(sellerManagedListingsProvider(profile.id));
      }
      ref.invalidate(
        sellerManagedListingProvider(result.listingId),
      );
      if ((widget.listingId ?? '').isNotEmpty) {
        ref.invalidate(sellerManagedListingProvider(widget.listingId!));
      }
      if (!mounted) {
        return;
      }
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        context.go('/seller/listings');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.status == 'draft'
                ? context.l10n.listingDraftSavedSuccess
                : result.status == 'active'
                ? context.l10n.listingPublishedSuccess
                : context.l10n.listingSubmittedForReviewSuccess,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickMedia() async {
    final picker = ref.read(listingMediaPickerProvider);
    final picked = await picker.pickImages();
    if (!mounted || picked.isEmpty) {
      return;
    }
    setState(() {
      final next = [..._media, ...picked];
      _media = next.take(6).toList(growable: false);
    });
  }

  bool _hasRequiredMediaFor(ListingWorkflowAction action) {
    final minimum = switch (action) {
      ListingWorkflowAction.saveDraft => 1,
      ListingWorkflowAction.submit =>
        _selectedCategoryFromState()?.minPhotos ?? 2,
    };
    return (_media.length + _existingMedia.length) >= minimum;
  }

  DiscoveryCategoryOption? _selectedCategory(
    List<DiscoveryCategoryOption> categories,
  ) {
    for (final category in categories) {
      if (category.id == _categoryId) {
        return category;
      }
    }
    return null;
  }

  DiscoveryCategoryOption? _selectedCategoryFromState() {
    final taxonomyState = ref.read(discoveryFilterTaxonomyProvider);
    return switch (taxonomyState) {
      AsyncData<DiscoveryFilterTaxonomy>(:final value) => _selectedCategory(
        value.categories,
      ),
      _ => null,
    };
  }

  WilayaOption? _selectedWilaya(List<WilayaOption> wilayas) {
    for (final wilaya in wilayas) {
      if (wilaya.id == _wilayaId) {
        return wilaya;
      }
    }
    return null;
  }

  CarMakeOption? _selectedMake(List<CarMakeOption> makes) {
    for (final make in makes) {
      if (make.id == _makeId) {
        return make;
      }
    }
    return null;
  }

  CarModelOption? _selectedModel(List<CarMakeOption> makes) {
    final make = _selectedMake(makes);
    if (make == null) {
      return null;
    }
    for (final model in make.models) {
      if (model.name == _modelCode) {
        return model;
      }
    }
    return null;
  }
}

extension _NullableValueX<T> on T? {
  R? let<R>(R Function(T value) transform) {
    final value = this;
    if (value == null) {
      return null;
    }
    return transform(value);
  }
}

extension _IterableFirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _ListingMediaPreviewFallback extends StatelessWidget {
  const _ListingMediaPreviewFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}

class _ConditionSelector extends ConsumerWidget {
  const _ConditionSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QitakFormGroup(
      label: context.l10n.discoveryConditionFieldLabel,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final value in const ['new', 'like_new', 'used'])
            QitakChip(
              label: context.l10n.discoveryConditionLabel(value),
              selected: value == selected,
              onTap: () => onChanged(value),
            ),
        ],
      ),
    );
  }
}
