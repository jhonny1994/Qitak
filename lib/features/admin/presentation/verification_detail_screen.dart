import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/core/network/domain_key.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

// ignore: specify_nonobvious_property_types, reason: Riverpod family aliases are version-specific in this repo.
final verificationApplicationProvider =
    FutureProvider.family<SellerApplication?, String>((ref, applicationId) {
      return ref
          .read(sellerApplicationRepositoryProvider)
          .fetchById(applicationId);
    });

final verificationDocumentPolicyOptionsProvider =
    FutureProvider<List<({String code, String labelKey})>>((ref) async {
      final options = await ref
          .read(sellerApplicationRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.sellerDocumentType);
      return options
          .map((option) => (code: option.code, labelKey: option.labelKey))
          .toList(growable: false);
    });

final verificationReasonPolicyOptionsProvider =
    FutureProvider<List<({String code, String labelKey})>>((ref) async {
      final options = await ref
          .read(sellerApplicationRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.sellerVerificationReasonCode);
      return options
          .map((option) => (code: option.code, labelKey: option.labelKey))
          .toList(growable: false);
    });

final verificationStatusContractsProvider =
    FutureProvider<List<({String code, String? labelKey})>>((ref) async {
      final contracts = await ref.watch(
        sellerVerificationStatusContractsProvider.future,
      );
      return contracts
          .map((entry) => (code: entry.code, labelKey: entry.labelKey))
          .toList(growable: false);
    });

class VerificationDetailScreen extends ConsumerStatefulWidget {
  const VerificationDetailScreen({required this.verificationId, super.key});

  final String verificationId;

  @override
  ConsumerState<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState
    extends ConsumerState<VerificationDetailScreen> {
  final _noteController = TextEditingController();
  String? _reasonCode;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final application = ref.watch(
      verificationApplicationProvider(widget.verificationId),
    );
    final documentPolicies = ref.watch(
      verificationDocumentPolicyOptionsProvider,
    );
    final reasonPolicies = ref.watch(verificationReasonPolicyOptionsProvider);
    final statusContracts = ref.watch(verificationStatusContractsProvider);

    final documentPolicyMap = {
      for (final option
          in documentPolicies.asData?.value ??
              const <({String code, String labelKey})>[])
        option.code: option.labelKey,
    };
    final reasonOptions =
        reasonPolicies.asData?.value ??
        const <({String code, String labelKey})>[];
    final availableStatuses = <String>{
      for (final option
          in statusContracts.asData?.value ??
              const <({String code, String? labelKey})>[])
        option.code,
    };
    return AdminSurfaceScaffold(
      eyebrow: context.l10n.adminVerificationsQueueTitle,
      title: context.l10n.adminVerificationDetailTitle,
      subtitle: context.l10n.adminVerificationDetailSubtitle,
      children: application.when(
        data: (item) => item == null
            ? [
                QitakStateMessage(
                  title: context.l10n.adminVerificationDetailEmptyTitle,
                  message: context.l10n.adminVerificationDetailEmptyBody,
                ),
              ]
            : [
                QitakSignalStrip(
                  label: context.l10n.adminVerificationApplicantLabel,
                  value: item.businessName,
                  status: _statusLabel(context, item.verificationStatus),
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(context.l10n.phoneLabel, item.phone),
                      _detailRow(context.l10n.emailLabel, item.email),
                      _detailRow(
                        context.l10n.sellerTypeLabel,
                        item.sellerType == 'business'
                            ? context.l10n.sellerTypeBusiness
                            : context.l10n.sellerTypeIndividual,
                      ),
                      _detailRow(context.l10n.wilayaLabel, item.wilayaId),
                      _detailRow(context.l10n.communeLabel, item.communeId),
                      _detailRow(
                        context.l10n.listingDescriptionTitle,
                        item.bio.isEmpty ? '-' : item.bio,
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
                        context.l10n.adminVerificationDocumentsTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (item.documents.isEmpty)
                        Text(context.l10n.adminVerificationDocumentsEmpty)
                      else
                        for (final document in item.documents)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: document.publicUrl == null
                                  ? null
                                  : () => showDialog<void>(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            document.publicUrl!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                              borderRadius: BorderRadius.circular(18),
                              child: QitakQueueRow(
                                title: _documentTypeLabel(
                                  context,
                                  document.documentType,
                                  documentPolicyMap[document.documentType],
                                ),
                                meta: document.storagePath,
                                status: context.l10n.sellerStatusSubmitted,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                              ),
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
                      Text(
                        context.l10n.adminVerificationHistoryTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _detailRow(
                        context.l10n.adminVerificationSubmittedAtLabel,
                        item.submittedAt?.toLocal().toString() ?? '-',
                      ),
                      _detailRow(
                        context.l10n.adminVerificationReviewedAtLabel,
                        item.reviewedAt?.toLocal().toString() ?? '-',
                      ),
                      _detailRow(
                        context.l10n.adminVerificationReasonCodeLabel,
                        item.reviewReasonCode ?? '-',
                      ),
                      _detailRow(
                        context.l10n.adminVerificationReviewNoteLabel,
                        item.reviewNote?.isEmpty == false
                            ? item.reviewNote!
                            : '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QitakFormGroup(
                        label: context.l10n.adminVerificationReasonCodeLabel,
                        child: QitakDropdownField<String>(
                          value: _reasonCode,
                          items: [
                            for (final reason in reasonOptions)
                              DropdownMenuItem(
                                value: reason.code,
                                child: Text(
                                  _labelFromKey(context, reason.labelKey),
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _reasonCode = value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      QitakFormGroup(
                        label: context.l10n.adminModerationDecisionNoteLabel,
                        child: TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                context.l10n.adminModerationDecisionNoteHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (availableStatuses.isEmpty ||
                              availableStatuses.contains('approved'))
                            FilledButton(
                              onPressed: _submitting
                                  ? null
                                  : () => _updateStatus(status: 'approved'),
                              child: Text(
                                context.l10n.adminVerificationApproveAction,
                              ),
                            ),
                          if (availableStatuses.isEmpty ||
                              availableStatuses.contains('needs_more_info'))
                            OutlinedButton(
                              onPressed: _submitting
                                  ? null
                                  : () => _updateStatus(
                                      status: 'needs_more_info',
                                    ),
                              child: Text(
                                context.l10n.adminVerificationNeedsInfoAction,
                              ),
                            ),
                          if (availableStatuses.isEmpty ||
                              availableStatuses.contains('rejected'))
                            OutlinedButton(
                              onPressed: _submitting
                                  ? null
                                  : () => _updateStatus(status: 'rejected'),
                              child: Text(
                                context.l10n.adminVerificationRejectAction,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
        error: (error, stackTrace) => [
          QitakStateMessage(
            title: context.l10n.errorStateTitle,
            message: context.l10n.discoveryErrorBody,
          ),
        ],
        loading: () => const [QitakPanel(child: QitakSkeletonBox(height: 120))],
      ),
    );
  }

  Future<void> _updateStatus({required String status}) async {
    if ((status == 'needs_more_info' || status == 'rejected') &&
        (_reasonCode ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminVerificationReasonRequired)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sellerApplicationRepositoryProvider)
          .updateStatus(
            applicationId: widget.verificationId,
            status: status,
            reasonCode: _reasonCode,
            note: _noteController.text.trim(),
          );
      ref
        ..invalidate(adminPendingSellerApplicationsProvider)
        ..invalidate(verificationApplicationProvider(widget.verificationId));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminVerificationStatusUpdated)),
      );
      context.go('/admin/verifications');
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

String _statusLabel(BuildContext context, String status) {
  switch (status) {
    case 'approved':
      return context.l10n.sellerStatusApproved;
    case 'needs_more_info':
      return context.l10n.sellerStatusNeedsInfo;
    case 'rejected':
      return context.l10n.sellerStatusRejected;
    case 'submitted':
      return context.l10n.sellerStatusSubmitted;
    default:
      return context.l10n.sellerStatusNotStarted;
  }
}

String _documentTypeLabel(
  BuildContext context,
  String documentType,
  String? labelKey,
) {
  if (labelKey != null && labelKey.isNotEmpty) {
    return _labelFromKey(context, labelKey);
  }
  switch (documentType) {
    case 'government_id_front':
      return context.l10n.sellerDocumentIdFrontLabel;
    case 'government_id_back':
      return context.l10n.sellerDocumentIdBackLabel;
    case 'business_registration':
      return context.l10n.sellerDocumentBusinessRegistrationLabel;
    default:
      return documentType;
  }
}

String _labelFromKey(BuildContext context, String key) {
  switch (key) {
    case 'sellerDocumentIdFrontLabel':
      return context.l10n.sellerDocumentIdFrontLabel;
    case 'sellerDocumentIdBackLabel':
      return context.l10n.sellerDocumentIdBackLabel;
    case 'sellerDocumentBusinessRegistrationLabel':
      return context.l10n.sellerDocumentBusinessRegistrationLabel;
    case 'adminVerificationReasonUnreadable':
      return context.l10n.adminVerificationReasonUnreadable;
    case 'adminVerificationReasonIdentityMismatch':
      return context.l10n.adminVerificationReasonIdentityMismatch;
    case 'adminVerificationReasonMissingBusinessDocument':
      return context.l10n.adminVerificationReasonMissingBusinessDocument;
    default:
      return key;
  }
}
