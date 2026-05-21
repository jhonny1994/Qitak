import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/presentation/risk_action_confirmation_dialog.dart';
import 'package:qitak_app/features/release/providers/cutover_rollback_providers.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class CutoverRollbackScreen extends ConsumerWidget {
  const CutoverRollbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cutoverRollbackProvider);
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.releaseAreaOperations,
                title: context.l10n.cutoverTitle,
                subtitle: context.l10n.rollbackVerificationLabel,
              ),
              const SizedBox(height: 16),
              if (state.cutoverRun != null)
                QitakSignalStrip(
                  label: context.l10n.cutoverLabel,
                  value: state.cutoverRun!.status.name,
                  status: context.l10n.cutoverRun,
                ),
              if (state.cutoverRun != null) const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final rationale = await showRiskActionConfirmationDialog(
                    context,
                    actionLabel: context.l10n.cutoverRun,
                  );
                  if (rationale == null || !context.mounted) return;
                  await ref
                      .read(cutoverRollbackProvider.notifier)
                      .runCutover(prechecksPass: true);
                },
                child: Text(context.l10n.cutoverRun),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final rationale = await showRiskActionConfirmationDialog(
                    context,
                    actionLabel: context.l10n.rollbackRun,
                  );
                  if (rationale == null || !context.mounted) return;
                  await ref
                      .read(cutoverRollbackProvider.notifier)
                      .triggerRollback();
                },
                child: Text(context.l10n.rollbackRun),
              ),
              if (state.rollbackRun != null) ...[
                const SizedBox(height: 12),
                QitakSignalStrip(
                  label: context.l10n.rollbackLabel,
                  value: state.rollbackRun!.status.name,
                  status: context.l10n.rollbackRun,
                ),
              ],
              if (state.verificationReport != null) ...[
                const SizedBox(height: 12),
                QitakSignalStrip(
                  label: context.l10n.rollbackVerificationLabel,
                  value: state.verificationReport!.result
                      ? context.l10n.releaseDecisionReady
                      : context.l10n.releaseDecisionNotReady,
                  status: context.l10n.releaseObservabilitySignals,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
