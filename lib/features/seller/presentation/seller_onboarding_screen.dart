import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/providers/seller_document_picker_provider.dart';
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

class SellerOnboardingScreen extends ConsumerStatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  ConsumerState<SellerOnboardingScreen> createState() =>
      _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState
    extends ConsumerState<SellerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _sellerType = 'individual';
  String? _wilayaId;
  String? _communeId;
  int _step = 0;
  bool _acceptPolicies = false;
  bool _submitting = false;
  bool _submitted = false;
  bool _submittedForReview = false;
  List<SellerDocumentDraft> _documents = const <SellerDocumentDraft>[];
  bool _hydratedExisting = false;

  @override
  Widget build(BuildContext context) {
    final taxonomy = ref.watch(discoveryFilterTaxonomyProvider);
    final existingApplication = ref.watch(currentSellerApplicationProvider);
    final profile = ref.watch(authSessionProvider).profile;

    return SingleChildScrollView(
      padding: qitakPagePadding,
      child: taxonomy.when(
        data: (data) {
          final sortedWilayas = _sortedWilayas(context, data.wilayas);
          final selectedWilaya = _selectedWilaya(sortedWilayas);
          final sortedCommunes = _sortedCommunes(
            context,
            selectedWilaya?.communes ?? const <CommuneOption>[],
          );
          existingApplication.whenData((application) {
            if (application != null && !_hydratedExisting && !_submitting) {
              _sellerType = application.sellerType;
              _wilayaId = application.wilayaId;
              _communeId = application.communeId;
              _hydratedExisting = true;
            }
          });
          final existingDocs = switch (existingApplication) {
            AsyncData<SellerApplication?>(:final value) =>
              value?.documents ?? const <SellerDocument>[],
            _ => const <SellerDocument>[],
          };

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QitakPanel(
                  child: QitakSectionHeader(
                    eyebrow: context.l10n.profileRoleSeller,
                    title: context.l10n.sellerOnboardingTitle,
                    subtitle:
                        '${context.l10n.sellerOnboardingBody} • ${_step + 1}/5',
                  ),
                ),
                const SizedBox(height: 18),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._buildStepContent(
                        context,
                        profile,
                        sortedWilayas,
                        sortedCommunes,
                        existingDocs,
                      ),
                      if (_step == 4) ...[
                        const SizedBox(height: 18),
                        FilledButton(
                          key: const Key('seller-onboarding-status-button'),
                          onPressed: () =>
                              context.go('/seller/onboarding/status'),
                          child: Text(context.l10n.sellerOnboardingViewStatus),
                        ),
                      ] else ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            if (_step > 0)
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 52),
                                  ),
                                  onPressed: _submitting
                                      ? null
                                      : () => setState(() => _step -= 1),
                                  child: Text(
                                    context.l10n.sellerOnboardingBack,
                                  ),
                                ),
                              ),
                            if (_step > 0) const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 52),
                                ),
                                key: _step == 3
                                    ? const Key('seller-onboarding-submit')
                                    : const Key('seller-onboarding-next'),
                                onPressed: _submitting
                                    ? null
                                    : _step == 3
                                    ? _submit
                                    : _nextStep,
                                child: _submitting && _step == 3
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _step == 3
                                            ? context
                                                  .l10n
                                                  .sellerOnboardingSubmit
                                            : context.l10n.onboardingNext,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.discoveryErrorBody,
        ),
        loading: () => const Padding(
          padding: qitakPagePadding,
          child: Column(
            children: [
              QitakPanel(child: QitakSkeletonBox(height: 96)),
              SizedBox(height: 18),
              QitakPanel(child: QitakSkeletonBox(height: 280)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final genericFailure = context.l10n.createAccountFailure;
    setState(() => _submitted = true);
    if (!_acceptPolicies) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final profile = ref.read(authSessionProvider).profile;
      if (profile == null) {
        throw const AppException('Session not found.');
      }
      await ref
          .read(sellerApplicationRepositoryProvider)
          .submitApplication(
            userId: profile.id,
            draft: SellerApplicationDraft(
              sellerType: _sellerType,
              businessName: profile.fullName,
              phone: profile.phone,
              wilayaId: _wilayaId ?? '',
              communeId: _communeId ?? '',
              bio: '',
              policiesAccepted: _acceptPolicies,
              documents: _documents,
            ),
          );
      if (mounted) {
        setState(() {
          _submittedForReview = true;
          _step = 4;
        });
      }
    } on AppException catch (error) {
      _showSnack(error.message);
    } on Object {
      _showSnack(genericFailure);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _nextStep() {
    setState(() => _submitted = true);
    if (_step == 0 || _step == 1) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }
    final currentApplication = ref.read(currentSellerApplicationProvider);
    final existingDocuments = switch (currentApplication) {
      AsyncData<SellerApplication?>(:final value) =>
        value?.documents ?? const <SellerDocument>[],
      _ => const <SellerDocument>[],
    };
    if (_step == 3 && !_hasRequiredDocuments(existingDocuments)) {
      return;
    }
    setState(() => _step += 1);
  }

  Future<void> _pickDocument(String documentType) async {
    final document = await ref
        .read(sellerDocumentPickerProvider)
        .pickDocument(documentType: documentType);
    if (!mounted || document == null) {
      return;
    }
    setState(() {
      _documents = [
        for (final item in _documents)
          if (item.documentType != documentType) item,
        document,
      ];
    });
  }

  SellerDocumentDraft? _documentFor(String documentType) {
    for (final document in _documents) {
      if (document.documentType == documentType) {
        return document;
      }
    }
    return null;
  }

  List<Widget> _buildStepContent(
    BuildContext context,
    AccountProfile? profile,
    List<WilayaOption> sortedWilayas,
    List<CommuneOption> sortedCommunes,
    List<SellerDocument> existingDocuments,
  ) {
    switch (_step) {
      case 0:
        return [
          QitakTimelineBlock(
            title: context.l10n.sellerOnboardingStepTypeTitle,
            subtitle: context.l10n.sellerOnboardingStepTypeBody,
            isCurrent: true,
          ),
          QitakFormGroup(
            label: context.l10n.sellerTypeLabel,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final value in const ['individual', 'business'])
                  QitakChip(
                    label: value == 'business'
                        ? context.l10n.sellerTypeBusiness
                        : context.l10n.sellerTypeIndividual,
                    selected: _sellerType == value,
                    onTap: () => setState(() => _sellerType = value),
                  ),
              ],
            ),
          ),
        ];
      case 1:
        return [
          QitakTimelineBlock(
            title: context.l10n.sellerOnboardingStepProfileTitle,
            subtitle: context.l10n.sellerOnboardingStepProfileBody,
            isCurrent: true,
          ),
          if (profile != null) ...[
            Text(
              context.l10n.sellerOnboardingAccountIdentityNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            QitakQueueRow(
              title: context.l10n.fullNameLabel,
              meta: profile.fullName,
              status: _sellerType == 'business'
                  ? context.l10n.sellerTypeBusiness
                  : context.l10n.sellerTypeIndividual,
            ),
            const SizedBox(height: 12),
            QitakQueueRow(
              title: context.l10n.phoneLabel,
              meta: profile.phone,
              status: context.l10n.accountSettingsEyebrow,
            ),
            const SizedBox(height: 16),
          ],
          QitakFormGroup(
            label: context.l10n.wilayaLabel,
            child: QitakDropdownField<String>(
              value: _wilayaId,
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
              validator: (value) =>
                  value == null ? context.l10n.listingWilayaRequired : null,
            ),
          ),
          const SizedBox(height: 16),
          QitakFormGroup(
            label: context.l10n.communeLabel,
            helper: _wilayaId == null
                ? context.l10n.discoveryFilterCommuneHelper
                : null,
            child: QitakDropdownField<String>(
              key: ValueKey('seller-commune-${_wilayaId ?? 'none'}'),
              value: _communeId,
              items: [
                for (final commune in sortedCommunes)
                  DropdownMenuItem(
                    value: commune.id,
                    child: Text(context.displayCommune(commune)),
                  ),
              ],
              onChanged: _wilayaId == null
                  ? null
                  : (value) => setState(() => _communeId = value),
              validator: (value) =>
                  value == null ? context.l10n.sellerCommuneRequired : null,
            ),
          ),
        ];
      case 2:
        return [
          QitakTimelineBlock(
            title: context.l10n.sellerOnboardingStepDocumentsTitle,
            subtitle: context.l10n.sellerOnboardingStepDocumentsBody,
            isCurrent: true,
          ),
          Text(
            _sellerType == 'business'
                ? '${context.l10n.sellerDocumentIdFrontLabel} • ${context.l10n.sellerDocumentBusinessRegistrationLabel}'
                : context.l10n.sellerDocumentIdFrontLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _DocumentUploadField(
            title: context.l10n.sellerDocumentIdFrontLabel,
            selectedDocument: _documentFor('government_id_front'),
            existingDocument: _existingDocumentFor(
              'government_id_front',
              existingDocuments,
            ),
            onPick: () => _pickDocument('government_id_front'),
          ),
          if (_sellerType == 'business') ...[
            const SizedBox(height: 12),
            _DocumentUploadField(
              title: context.l10n.sellerDocumentBusinessRegistrationLabel,
              selectedDocument: _documentFor('business_registration'),
              existingDocument: _existingDocumentFor(
                'business_registration',
                existingDocuments,
              ),
              onPick: () => _pickDocument('business_registration'),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            context.l10n.sellerOnboardingDocumentsPrivacyNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_submitted && !_hasRequiredDocuments(existingDocuments)) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.sellerOnboardingDocumentsRequired,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ];
      case 3:
        return [
          QitakTimelineBlock(
            title: context.l10n.sellerOnboardingStepPolicyTitle,
            subtitle: context.l10n.sellerOnboardingStepPolicyBody,
            isCurrent: true,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acceptPolicies,
            onChanged: (value) =>
                setState(() => _acceptPolicies = value ?? false),
            title: Text(context.l10n.acceptTerms),
          ),
        ];
      default:
        return [
          QitakTimelineBlock(
            title: context.l10n.sellerOnboardingStepConfirmationTitle,
            subtitle: context.l10n.sellerOnboardingStepConfirmationBody,
            isCurrent: true,
          ),
          QitakSignalStrip(
            label: context.l10n.sellerStatusTitle,
            value: _submittedForReview
                ? context.l10n.sellerStatusSubmitted
                : context.l10n.sellerStatusNotStarted,
            status: context.l10n.sellerOnboardingReviewWindow,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.sellerOnboardingConfirmationBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ];
    }
  }

  bool _hasRequiredDocuments(List<SellerDocument> existingDocuments) {
    final requiredTypes = <String>{
      'government_id_front',
      if (_sellerType == 'business') 'business_registration',
    };
    final availableTypes = <String>{
      ...existingDocuments.map((item) => item.documentType),
      ..._documents.map((item) => item.documentType),
    };
    return requiredTypes.difference(availableTypes).isEmpty;
  }

  WilayaOption? _selectedWilaya(List<WilayaOption> wilayas) {
    for (final wilaya in wilayas) {
      if (wilaya.id == _wilayaId) {
        return wilaya;
      }
    }
    return null;
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  SellerDocument? _existingDocumentFor(
    String documentType,
    List<SellerDocument> existingDocuments,
  ) {
    for (final document in existingDocuments) {
      if (document.documentType == documentType) {
        return document;
      }
    }
    return null;
  }
}

class _DocumentUploadField extends StatelessWidget {
  const _DocumentUploadField({
    required this.title,
    required this.selectedDocument,
    required this.existingDocument,
    required this.onPick,
  });

  final String title;
  final SellerDocumentDraft? selectedDocument;
  final SellerDocument? existingDocument;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return QitakPanel(
      padding: const EdgeInsets.all(14),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            selectedDocument?.fileName ??
                existingDocument?.storagePath.split('/').last ??
                context.l10n.sellerOnboardingDocumentMissing,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onPick,
            child: Text(
              selectedDocument != null || existingDocument != null
                  ? context.l10n.sellerOnboardingDocumentReplaceAction
                  : context.l10n.sellerOnboardingDocumentAttachAction,
            ),
          ),
        ],
      ),
    );
  }
}
