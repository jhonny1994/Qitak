import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SellerApplicationStatusScreen extends ConsumerWidget {
  const SellerApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(currentSellerApplicationProvider);
    final statusContracts = ref.watch(
      sellerVerificationStatusOptionsProvider,
    );
    final reasonPolicies = ref.watch(sellerVerificationReasonOptionsProvider);
    final documentPolicies = ref.watch(sellerStatusDocumentOptionsProvider);
    final profile = ref.watch(authSessionProvider).profile;
    final profileRoot = switch (profile?.role) {
      null => '/guest/account',
      AccountRole.seller => '/seller/profile',
      AccountRole.admin => '/admin/profile',
      AccountRole.superAdmin => '/admin/profile',
      _ => '/profile',
    };
    return application.when(
      data: (item) => ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: QitakSectionHeader(
              eyebrow: context.l10n.sellerStatusEyebrow,
              title: context.l10n.sellerStatusTitle,
              subtitle: context.l10n.sellerStatusSubtitle,
            ),
          ),
          const SizedBox(height: 18),
          QitakSignalStrip(
            label: context.l10n.sellerStatusTitle,
            value: _statusBadge(
              context,
              item?.verificationStatus,
              statusContracts.asData?.value,
            ),
            status: item == null
                ? context.l10n.sellerStatusProfileDraftBody
                : _statusSubtitle(
                    context,
                    item.verificationStatus,
                    statusContracts.asData?.value,
                  ),
          ),
          const SizedBox(height: 16),
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QitakTimelineBlock(
                  title: context.l10n.sellerStatusProfile,
                  subtitle: item == null
                      ? context.l10n.sellerStatusProfileDraftBody
                      : context.l10n.sellerStatusProfileBody,
                  isCurrent: true,
                ),
                QitakTimelineBlock(
                  title: context.l10n.sellerStatusVerification,
                  subtitle: _statusSubtitle(
                    context,
                    item?.verificationStatus,
                    statusContracts.asData?.value,
                  ),
                  isCurrent: item != null,
                ),
                QitakTimelineBlock(
                  title: context.l10n.sellerStatusWorkspace,
                  subtitle: item?.isApproved == true
                      ? context.l10n.sellerStatusWorkspaceApprovedBody
                      : context.l10n.sellerStatusWorkspaceWaitingBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QitakPanel(
            child: _requirementsPanel(context, item),
          ),
          if (item != null) ...[
            const SizedBox(height: 16),
            QitakPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.sellerStatusDocumentsTitle,
                    style:
                        Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (item.documents.isEmpty)
                    Text(context.l10n.sellerStatusDocumentsEmpty)
                  else
                    for (final document in item.documents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: QitakQueueRow(
                          title: _documentTypeLabel(
                            context,
                            document.documentType,
                            documentPolicies.asData?.value,
                          ),
                          meta: _documentDisplayName(document.storagePath),
                          status: context.l10n.sellerStatusSubmitted,
                        ),
                      ),
                  if ((item.reviewReasonCode ?? '').isNotEmpty ||
                      (item.reviewNote ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.sellerStatusReviewFeedbackTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        if ((item.reviewReasonCode ?? '').isNotEmpty)
                          _reasonLabel(
                            context,
                            item.reviewReasonCode!,
                            reasonPolicies.asData?.value,
                          ),
                        if ((item.reviewNote ?? '').isNotEmpty)
                          item.reviewNote!,
                      ].join(' • '),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  key: const Key('seller-status-primary-action'),
                  onPressed: () => context.go(_primaryActionPath(item)),
                  child: Text(
                    _primaryActionLabel(context, item),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  key: const Key('seller-status-profile-action'),
                  onPressed: () => context.go('$profileRoot/settings'),
                  child: Text(context.l10n.accountSettingsTitle),
                ),
              ),
            ],
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
            QitakPanel(child: QitakSkeletonBox(height: 84)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 220)),
          ],
        ),
      ),
    );
  }
}

String _primaryActionPath(SellerApplication? item) {
  if (item?.isApproved == true) {
    return '/seller/home';
  }
  switch (item?.verificationStatus) {
    case 'submitted':
      return '/seller/profile';
    case 'rejected':
    case 'needs_more_info':
    case 'draft':
    default:
      return '/seller/onboarding';
  }
}

String _primaryActionLabel(BuildContext context, SellerApplication? item) {
  if (item?.isApproved == true) {
    return context.l10n.sellerStatusBackToWorkspace;
  }
  switch (item?.verificationStatus) {
    case 'submitted':
      return context.l10n.sellerStatusBackToProfile;
    case 'rejected':
      return context.l10n.sellerStatusRestartApplication;
    case 'needs_more_info':
    case 'draft':
    default:
      return context.l10n.sellerStatusContinueApplication;
  }
}

Widget _requirementsPanel(BuildContext context, SellerApplication? item) {
  final status = item?.verificationStatus;
  if (item == null) {
    return Text(context.l10n.sellerStatusProfileDraftBody);
  }
  if (status == 'needs_more_info') {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sellerStatusRequirementsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(_reasonLabelOrFallback(context, item, true)),
        if ((item.reviewNote ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(item.reviewNote!),
        ],
      ],
    );
  }
  if (status == 'rejected') {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sellerStatusRequirementsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(_reasonLabelOrFallback(context, item, false)),
        if ((item.reviewNote ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(item.reviewNote!),
        ],
      ],
    );
  }
  if (status == 'approved') {
    return Text(context.l10n.sellerStatusWorkspaceApprovedBody);
  }
  return Text(context.l10n.sellerStatusVerificationSubmittedBody);
}

String _statusSubtitle(
  BuildContext context,
  String? status,
  List<({String code, String? labelKey})>? contracts,
) {
  return _statusLabelFromKey(
    context,
    _findStatusLabelKey(status, contracts),
    fallbackStatus: status,
    subtitle: true,
  );
}

String _statusBadge(
  BuildContext context,
  String? status,
  List<({String code, String? labelKey})>? contracts,
) {
  return _statusLabelFromKey(
    context,
    _findStatusLabelKey(status, contracts),
    fallbackStatus: status,
    subtitle: false,
  );
}

String? _findStatusLabelKey(
  String? status,
  List<({String code, String? labelKey})>? contracts,
) {
  if (status == null || contracts == null) {
    return null;
  }
  for (final entry in contracts) {
    if (entry.code == status && (entry.labelKey ?? '').isNotEmpty) {
      return entry.labelKey;
    }
  }
  return null;
}

String _statusLabelFromKey(
  BuildContext context,
  String? labelKey, {
  required bool subtitle,
  String? fallbackStatus,
}) {
  switch (labelKey) {
    case 'sellerStatusApproved':
      return subtitle
          ? context.l10n.sellerStatusVerificationApprovedBody
          : context.l10n.sellerStatusApproved;
    case 'sellerStatusNeedsInfo':
      return subtitle
          ? context.l10n.sellerStatusVerificationNeedsInfoBody
          : context.l10n.sellerStatusNeedsInfo;
    case 'sellerStatusRejected':
      return subtitle
          ? context.l10n.sellerStatusVerificationRejectedBody
          : context.l10n.sellerStatusRejected;
    case 'sellerStatusSubmitted':
      return subtitle
          ? context.l10n.sellerStatusVerificationSubmittedBody
          : context.l10n.sellerStatusSubmitted;
    case 'sellerStatusNotStarted':
      return subtitle
          ? context.l10n.sellerStatusVerificationDraftBody
          : context.l10n.sellerStatusNotStarted;
    default:
      break;
  }
  switch (fallbackStatus) {
    case 'approved':
      return subtitle
          ? context.l10n.sellerStatusVerificationApprovedBody
          : context.l10n.sellerStatusApproved;
    case 'needs_more_info':
      return subtitle
          ? context.l10n.sellerStatusVerificationNeedsInfoBody
          : context.l10n.sellerStatusNeedsInfo;
    case 'rejected':
      return subtitle
          ? context.l10n.sellerStatusVerificationRejectedBody
          : context.l10n.sellerStatusRejected;
    case 'submitted':
      return subtitle
          ? context.l10n.sellerStatusVerificationSubmittedBody
          : context.l10n.sellerStatusSubmitted;
    default:
      return subtitle
          ? context.l10n.sellerStatusVerificationDraftBody
          : context.l10n.sellerStatusNotStarted;
  }
}

String _documentTypeLabel(
  BuildContext context,
  String documentType,
  List<({String code, String labelKey})>? documentPolicies,
) {
  if (documentPolicies != null) {
    for (final policy in documentPolicies) {
      if (policy.code == documentType) {
        return _documentLabelFromKey(context, policy.labelKey);
      }
    }
  }
  return _documentLabelFromKey(context, documentType);
}

String _documentDisplayName(String storagePath) {
  final normalized = storagePath.replaceAll(r'\', '/');
  final segments = normalized.split('/');
  if (segments.isEmpty) {
    return storagePath;
  }
  return segments.last;
}

String _documentLabelFromKey(BuildContext context, String key) {
  switch (key) {
    case 'sellerDocumentIdFrontLabel':
    case 'government_id_front':
      return context.l10n.sellerDocumentIdFrontLabel;
    case 'sellerDocumentIdBackLabel':
    case 'government_id_back':
      return context.l10n.sellerDocumentIdBackLabel;
    case 'sellerDocumentBusinessRegistrationLabel':
    case 'business_registration':
      return context.l10n.sellerDocumentBusinessRegistrationLabel;
    default:
      return key;
  }
}

String _reasonLabel(
  BuildContext context,
  String code,
  List<({String code, String labelKey})>? reasonPolicies,
) {
  if (reasonPolicies != null) {
    for (final reason in reasonPolicies) {
      if (reason.code == code) {
        return _reasonLabelFromKey(context, reason.labelKey);
      }
    }
  }
  return code;
}

String _reasonLabelFromKey(BuildContext context, String labelKey) {
  switch (labelKey) {
    case 'adminVerificationReasonUnreadable':
      return context.l10n.adminVerificationReasonUnreadable;
    case 'adminVerificationReasonIdentityMismatch':
      return context.l10n.adminVerificationReasonIdentityMismatch;
    case 'adminVerificationReasonMissingBusinessDocument':
      return context.l10n.adminVerificationReasonMissingBusinessDocument;
    default:
      return labelKey;
  }
}

String _reasonLabelOrFallback(
  BuildContext context,
  SellerApplication item,
  bool needsInfoFallback,
) {
  final code = item.reviewReasonCode;
  if (code != null && code.isNotEmpty) {
    return code;
  }
  return needsInfoFallback
      ? context.l10n.sellerStatusVerificationNeedsInfoBody
      : context.l10n.sellerStatusVerificationRejectedBody;
}

final sellerVerificationStatusOptionsProvider =
    FutureProvider<List<({String code, String? labelKey})>>((ref) async {
      final contracts = await ref.watch(
        sellerVerificationStatusContractsProvider.future,
      );
      return contracts
          .map((entry) => (code: entry.code, labelKey: entry.labelKey))
          .toList(growable: false);
    });

final sellerVerificationReasonOptionsProvider =
    FutureProvider<List<({String code, String labelKey})>>((ref) async {
      final policies = await ref.watch(
        sellerVerificationReasonPolicyProvider.future,
      );
      return policies
          .where((policy) => policy.active)
          .map((policy) => (code: policy.code, labelKey: policy.labelKey))
          .toList(growable: false);
    });

final sellerStatusDocumentOptionsProvider =
    FutureProvider<List<({String code, String labelKey})>>((ref) async {
      final policies = await ref.watch(sellerDocumentTypePolicyProvider.future);
      return policies
          .where((policy) => policy.active)
          .map((policy) => (code: policy.code, labelKey: policy.labelKey))
          .toList(growable: false);
    });
