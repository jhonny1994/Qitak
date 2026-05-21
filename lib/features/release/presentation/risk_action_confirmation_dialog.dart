import 'package:flutter/material.dart';
import 'package:qitak_app/core/l10n/l10n.dart';

Future<String?> showRiskActionConfirmationDialog(
  BuildContext context, {
  required String actionLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final rationale = controller.text.trim();
          return AlertDialog(
            title: Text(context.l10n.riskConfirmTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${context.l10n.riskConfirmBodyPrefix} $actionLabel',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: context.l10n.riskRationaleLabel,
                    errorText: rationale.isEmpty
                        ? context.l10n.riskRationaleLabel
                        : null,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.riskCancel),
              ),
              FilledButton(
                onPressed: rationale.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(rationale),
                child: Text(context.l10n.riskConfirmAction),
              ),
            ],
          );
        },
      );
    },
  );
}
