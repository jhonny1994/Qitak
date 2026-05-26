import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

final reportDecisionPolicyOptionsProvider =
    FutureProvider<List<AppPolicyOption>>((ref) async {
      return ref.watch(reportResolutionDecisionPolicyProvider.future);
    });

final reportReasonPolicyOptionsProvider = FutureProvider<List<AppPolicyOption>>(
  (ref) async {
    return ref.watch(reportResolutionReasonPolicyProvider.future);
  },
);

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({required this.reportId, super.key});

  final String reportId;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _noteController = TextEditingController();
  String _decision = 'dismiss';
  String? _reasonCode;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(adminReportProvider(widget.reportId));
    final decisionOptions = ref.watch(reportDecisionPolicyOptionsProvider);
    final reasonOptions = ref.watch(reportReasonPolicyOptionsProvider);

    final availableDecisionOptions =
        decisionOptions.asData?.value ?? const <AppPolicyOption>[];
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
    final selectedReasonCode =
        (_reasonCode != null &&
            availableReasonOptions.any((item) => item.code == _reasonCode))
        ? _reasonCode
        : null;

    return report.when(
      data: (item) => AdminSurfaceScaffold(
        eyebrow: context.l10n.adminReportsQueueTitle,
        title: context.l10n.adminReportDetailTitle,
        subtitle: context.l10n.adminReportDetailSubtitle,
        children: item == null
            ? [
                QitakStateMessage(
                  title: context.l10n.adminReportDetailEmptyTitle,
                  message: context.l10n.adminReportDetailEmptyBody,
                ),
              ]
            : [
                QitakSignalStrip(
                  label: context.l10n.transactionRecordLabel,
                  value: item.id,
                  status: item.status,
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.adminReportReporterLabel}: '
                        '${item.reporterName.isEmpty ? item.reporterUserId : item.reporterName}',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${context.l10n.adminReportEntityLabel}: '
                        '${item.entityType} • ${item.entityPreview}',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${context.l10n.disputeReasonLabel}: ${item.reason}',
                      ),
                      const SizedBox(height: 10),
                      Text(item.description.isEmpty ? '-' : item.description),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.adminConversationRelatedContextTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${context.l10n.adminReportReporterHistoryLabel}: '
                        '${item.reporterHistoryCount}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${context.l10n.adminReportEntityHistoryLabel}: '
                        '${item.entityHistoryCount}',
                      ),
                    ],
                  ),
                ),
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
                            setState(() => _decision = value ?? 'dismiss'),
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
                          context.l10n.adminReportApplyDecisionAction,
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
            QitakPanel(child: QitakSkeletonBox(height: 240)),
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
        .read(adminReportsRepositoryProvider)
        .resolveReport(
          reportId: widget.reportId,
          decision: _decision,
          reasonCode: reasonCode,
          note: _noteController.text.trim(),
        );
    ref
      ..invalidate(adminReportsProvider)
      ..invalidate(adminReportProvider(widget.reportId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminReportDecisionSaved)),
    );
  }
}

String _policyLabel(BuildContext context, String labelKey) {
  switch (labelKey) {
    case 'adminReportDecisionDismiss':
      return context.l10n.adminReportDecisionDismiss;
    case 'adminReportDecisionWarnSeller':
      return context.l10n.adminReportDecisionWarnSeller;
    case 'adminReportDecisionRemoveListing':
      return context.l10n.adminReportDecisionRemoveListing;
    case 'adminReportDecisionSuspendSeller':
      return context.l10n.adminReportDecisionSuspendSeller;
    case 'adminReportReasonSpam':
      return context.l10n.adminReportReasonSpam;
    case 'adminReportReasonPolicyViolation':
      return context.l10n.adminReportReasonPolicyViolation;
    case 'adminReportReasonInsufficientEvidence':
      return context.l10n.adminReportReasonInsufficientEvidence;
    default:
      return labelKey;
  }
}
