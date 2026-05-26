import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

final disputeDecisionPolicyOptionsProvider =
    FutureProvider<List<AppPolicyOption>>((ref) async {
      return ref.watch(disputeResolutionDecisionPolicyProvider.future);
    });

final disputeOutcomePolicyOptionsProvider =
    FutureProvider<List<AppPolicyOption>>((ref) async {
      return ref.watch(disputeResolutionOutcomeActionPolicyProvider.future);
    });

final disputeReasonPolicyOptionsProvider =
    FutureProvider<List<AppPolicyOption>>((ref) async {
      return ref.watch(disputeResolutionReasonPolicyProvider.future);
    });

class DisputeDetailScreen extends ConsumerStatefulWidget {
  const DisputeDetailScreen({required this.disputeId, super.key});

  final String disputeId;

  @override
  ConsumerState<DisputeDetailScreen> createState() =>
      _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  final _noteController = TextEditingController();
  String _decision = 'buyer';
  String _outcomeAction = 'no_action';
  String? _reasonCode;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispute = ref.watch(adminDisputeProvider(widget.disputeId));
    final decisionOptions = ref.watch(disputeDecisionPolicyOptionsProvider);
    final outcomeOptions = ref.watch(disputeOutcomePolicyOptionsProvider);
    final reasonOptions = ref.watch(disputeReasonPolicyOptionsProvider);

    final availableDecisionOptions =
        decisionOptions.asData?.value ?? const <AppPolicyOption>[];
    final availableOutcomeOptions =
        outcomeOptions.asData?.value ?? const <AppPolicyOption>[];
    final availableReasonOptions =
        reasonOptions.asData?.value ?? const <AppPolicyOption>[];

    final selectedDecision =
        availableDecisionOptions.any(
          (item) => item.code == _decision,
        )
        ? _decision
        : (availableDecisionOptions.isNotEmpty
              ? availableDecisionOptions.first.code
              : _decision);
    final selectedOutcomeAction =
        availableOutcomeOptions.any(
          (item) => item.code == _outcomeAction,
        )
        ? _outcomeAction
        : (availableOutcomeOptions.isNotEmpty
              ? availableOutcomeOptions.first.code
              : _outcomeAction);
    final selectedReasonCode =
        (_reasonCode != null &&
            availableReasonOptions.any((item) => item.code == _reasonCode))
        ? _reasonCode
        : null;

    return dispute.when(
      data: (item) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminDisputesQueueTitle,
        title: context.l10n.adminDisputeDetailTitle,
        subtitle: context.l10n.adminDisputeDetailSubtitle,
        children: item == null
            ? [
                QitakStateMessage(
                  title: context.l10n.adminDisputeDetailEmptyTitle,
                  message: context.l10n.adminDisputeDetailEmptyBody,
                ),
              ]
            : [
                QitakSignalStrip(
                  label: context.l10n.transactionRecordLabel,
                  value: item.transactionId,
                  status: item.status,
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.disputeReasonLabel}: ${item.reason}',
                      ),
                      const SizedBox(height: 10),
                      Text(item.description),
                      if (item.listingTitle.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${context.l10n.adminDisputeListingLabel}: '
                          '${item.listingTitle}',
                        ),
                      ],
                      if (item.buyerName.isNotEmpty ||
                          item.sellerName.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${context.l10n.adminDisputeBuyerLabel}: '
                          '${item.buyerName.isEmpty ? '-' : item.buyerName}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${context.l10n.adminDisputeSellerLabel}: '
                          '${item.sellerName.isEmpty ? '-' : item.sellerName}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.disputeEvidenceLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (item.evidence.isEmpty)
                        Text(context.l10n.disputeEvidenceValue)
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final evidence in item.evidence)
                              InkWell(
                                onTap: evidence.previewUrl.isEmpty
                                    ? null
                                    : () => showDialog<void>(
                                        context: context,
                                        builder: (dialogContext) => Dialog(
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              evidence.previewUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                child: SizedBox(
                                  width: 92,
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: evidence.previewUrl.isEmpty
                                              ? ColoredBox(
                                                  color: context
                                                      .qitakTokens
                                                      .stroke,
                                                )
                                              : Image.network(
                                                  evidence.previewUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        evidence.storagePath.split('/').last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if ((item.conversationId ?? '').isNotEmpty)
                  QitakPanel(
                    child: FilledButton.tonal(
                      onPressed: () => context.go(
                        '/admin/conversations/${item.conversationId}',
                      ),
                      child: Text(context.l10n.adminConversationOversightTitle),
                    ),
                  ),
                if ((item.conversationId ?? '').isNotEmpty)
                  const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QitakDropdownField<String>(
                        value: selectedDecision,
                        items: [
                          for (final option in availableDecisionOptions)
                            DropdownMenuItem(
                              value: option.code,
                              child: Text(
                                _policyLabel(context, option.labelKey),
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _decision = value ?? 'buyer'),
                      ),
                      const SizedBox(height: 12),
                      QitakDropdownField<String>(
                        value: selectedOutcomeAction,
                        items: [
                          for (final option in availableOutcomeOptions)
                            DropdownMenuItem(
                              value: option.code,
                              child: Text(
                                _policyLabel(context, option.labelKey),
                              ),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _outcomeAction = value ?? 'no_action',
                        ),
                      ),
                      const SizedBox(height: 12),
                      QitakDropdownField<String>(
                        value: selectedReasonCode,
                        items: [
                          for (final option in availableReasonOptions)
                            DropdownMenuItem(
                              value: option.code,
                              child: Text(
                                _policyLabel(context, option.labelKey),
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _reasonCode = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:
                              context.l10n.adminModerationDecisionNoteLabel,
                          hintText:
                              context.l10n.adminModerationDecisionNoteHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _reasonCode == null ? null : _resolve,
                        child: Text(
                          context.l10n.adminDisputeResolveAction,
                        ),
                      ),
                    ],
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
            QitakPanel(child: QitakSkeletonBox(height: 84)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 260)),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve() async {
    final reasonCode = _reasonCode;
    if (reasonCode == null) {
      return;
    }
    await ref
        .read(disputeRepositoryProvider)
        .resolve(
          disputeId: widget.disputeId,
          decision: _decision,
          reasonCode: reasonCode,
          outcomeAction: _outcomeAction,
          note: _noteController.text.trim(),
        );
    ref
      ..invalidate(adminDisputesProvider)
      ..invalidate(adminDisputeProvider(widget.disputeId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminDisputeDecisionSaved)),
    );
  }
}

String _policyLabel(BuildContext context, String labelKey) {
  switch (labelKey) {
    case 'adminDisputeDecisionBuyer':
      return context.l10n.adminDisputeDecisionBuyer;
    case 'adminDisputeDecisionSeller':
      return context.l10n.adminDisputeDecisionSeller;
    case 'adminDisputeDecisionDismiss':
      return context.l10n.adminDisputeDecisionDismiss;
    case 'adminDisputeOutcomeNoAction':
      return context.l10n.adminDisputeOutcomeNoAction;
    case 'adminDisputeOutcomeWarn':
      return context.l10n.adminDisputeOutcomeWarn;
    case 'adminDisputeOutcomeSuspend':
      return context.l10n.adminDisputeOutcomeSuspend;
    case 'adminDisputeOutcomeRemoveListing':
      return context.l10n.adminDisputeOutcomeRemoveListing;
    case 'adminDisputeReasonDamagedPart':
      return context.l10n.adminDisputeReasonDamagedPart;
    case 'adminDisputeReasonWrongPart':
      return context.l10n.adminDisputeReasonWrongPart;
    case 'adminDisputeReasonInsufficientEvidence':
      return context.l10n.adminDisputeReasonInsufficientEvidence;
    default:
      return labelKey;
  }
}
